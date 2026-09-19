// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/sim_card.dart';
import '../models/enums.dart';
import '../models/feature_set.dart';
import '../providers/sim_card_provider.dart';
import '../data/carriers.dart';
import '../data/countries.dart';
import '../theme/app_colors.dart';
import '../widgets/feature_toggle_tile.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/carrier_picker_sheet.dart';
import '../widgets/country_picker_sheet.dart';
import 'qr_scanner_screen.dart';

/// 添加 / 编辑 SIM 卡页面
class AddEditSimScreen extends StatefulWidget {
  final SimCard? simCard;

  const AddEditSimScreen({super.key, this.simCard});

  bool get isEditing => simCard != null;

  @override
  State<AddEditSimScreen> createState() => _AddEditSimScreenState();
}

class _AddEditSimScreenState extends State<AddEditSimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // ── 基本信息 ──
  SimType _simType = SimType.physicalSim;
  String? _carrierCode;
  String _carrierName = '';
  String _countryCode = 'CN';
  String _iccid = '';
  final List<TextEditingController> _phoneControllers = [];
  String _source = '';
  String _notes = '';

  // ── 有效期 ──
  ValidityType _validityType = ValidityType.noExpiration;
  DateTime? _activationDate;
  DateTime? _expirationDate;
  int _rollingDays = 30;
  int _reminderDays = 7;

  // ── 用量 ──
  String _dataBalance = '';
  String _dataTotal = '';
  String _voiceRemaining = '';
  String _voiceTotal = '';
  String _smsRemaining = '';
  String _smsTotal = '';
  String _balance = '';
  String _balanceCurrency = '';

  // ── 功能 ──
  late FeatureSet _features;

  // ── eSIM ──
  String _rspServer = '';
  String _activationCode = '';
  String _confirmationCode = '';
  final TextEditingController _rspServerController = TextEditingController();
  final TextEditingController _activationCodeController = TextEditingController();
  final TextEditingController _confirmationCodeController = TextEditingController();

  // ── 外观 ──
  late Color _cardColor;
  List<int> _selectedTagIds = [];

  // ── 展开的 section 索引 ──
  int _expandedSection = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _populateFromCard(widget.simCard!);
    } else {
      _features = FeatureSet();
      final provider = context.read<SimCardProvider>();
      _cardColor = AppColors.pickUniqueColor(provider.usedCardColors);
      _phoneControllers.add(TextEditingController());
    }
  }

  void _populateFromCard(SimCard card) {
    _simType = card.type;
    _carrierCode = card.carrierCode;
    _carrierName = card.carrierName;
    _countryCode = card.countryCode;
    _iccid = card.iccid ?? '';
    _source = card.source ?? '';
    _notes = card.notes ?? '';

    for (final number in card.phoneNumbers) {
      _phoneControllers.add(TextEditingController(text: number));
    }
    if (_phoneControllers.isEmpty) {
      _phoneControllers.add(TextEditingController());
    }

    _validityType = card.validityType;
    _activationDate = card.activationDate;
    _expirationDate = card.expirationDate;
    _rollingDays = card.rollingDays ?? 30;
    _reminderDays = card.reminderDaysBefore;

    _dataBalance = card.dataBalanceMB?.toString() ?? '';
    _dataTotal = card.dataTotalMB?.toString() ?? '';
    _voiceRemaining = card.voiceMinutesRemaining?.toString() ?? '';
    _voiceTotal = card.voiceMinutesTotal?.toString() ?? '';
    _smsRemaining = card.smsRemaining?.toString() ?? '';
    _smsTotal = card.smsTotal?.toString() ?? '';
    _balance = card.balance?.toString() ?? '';
    _balanceCurrency = card.balanceCurrency ?? '';

    _features = card.features.copyWith();

    _rspServer = card.rspServerAddress ?? '';
    _rspServerController.text = _rspServer;
    _activationCode = card.activationCode ?? '';
    _activationCodeController.text = _activationCode;
    _confirmationCode = card.confirmationCode ?? '';
    _confirmationCodeController.text = _confirmationCode;

    _cardColor = Color(card.cardColor);
    _selectedTagIds = List.from(card.tagIds);
  }

  @override
  void dispose() {
    for (final c in _phoneControllers) {
      c.dispose();
    }
    _rspServerController.dispose();
    _activationCodeController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑SIM卡' : '添加SIM/eSIM信息'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              '保存',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _buildSection(
              index: 0,
              title: '基本信息',
              icon: Icons.sim_card_outlined,
              children: _buildBasicInfoSection(),
            ),
            const SizedBox(height: 8),
            _buildSection(
              index: 1,
              title: '有效期',
              icon: Icons.calendar_today_rounded,
              children: _buildValiditySection(),
            ),
            const SizedBox(height: 8),
            _buildSection(
              index: 2,
              title: '用量记录',
              icon: Icons.data_usage_rounded,
              children: _buildUsageSection(),
            ),
            const SizedBox(height: 8),
            _buildSection(
              index: 3,
              title: '功能支持',
              icon: Icons.checklist_rounded,
              children: _buildFeaturesSection(),
            ),
            if (_simType == SimType.esim) ...[
              const SizedBox(height: 8),
              _buildSection(
                index: 4,
                title: 'eSIM信息',
                icon: Icons.qr_code_rounded,
                children: _buildEsimSection(),
              ),
            ],
            const SizedBox(height: 8),
            _buildSection(
              index: 5,
              title: '外观与分类',
              icon: Icons.palette_rounded,
              children: _buildAppearanceSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required int index,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSection == index;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : theme.dividerTheme.color ?? AppColors.lightDivider,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── 标题行 ──
          InkWell(
            onTap: () {
              setState(() => _expandedSection = isExpanded ? -1 : index);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── 内容 ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Section 1: 基本信息
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildBasicInfoSection() {
    return [
      // SIM 类型
      _label('SIM卡类型'),
      SegmentedButton<SimType>(
        segments: SimType.values.map((t) {
          return ButtonSegment(
            value: t,
            label: Text(t.label, style: GoogleFonts.inter(fontSize: 13)),
            icon: Icon(
              t == SimType.esim
                  ? Icons.qr_code_rounded
                  : Icons.sim_card_outlined,
              size: 18,
            ),
          );
        }).toList(),
        selected: {_simType},
        onSelectionChanged: (sel) {
          setState(() => _simType = sel.first);
        },
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 运营商
      _label('运营商'),
      _buildCarrierPicker(),
      const SizedBox(height: 16),

      // 国家/地区
      _label('国家/地区'),
      _buildCountryPicker(),
      const SizedBox(height: 16),

      // ICCID
      _label('ICCID'),
      TextFormField(
        initialValue: _iccid,
        decoration: const InputDecoration(
          hintText: '18-22位数字',
          prefixIcon: Icon(Icons.credit_card_rounded, size: 20),
        ),
        keyboardType: TextInputType.number,
        maxLength: 22,
        style: GoogleFonts.robotoMono(fontSize: 14),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!RegExp(r'^\d{18,22}$').hasMatch(value)) {
              return 'ICCID 应为 18-22 位纯数字';
            }
          }
          return null;
        },
        onChanged: (v) => _iccid = v.trim(),
      ),
      const SizedBox(height: 8),

      // 号码列表
      _label('电话号码'),
      ..._phoneControllers.asMap().entries.map((entry) {
        final i = entry.key;
        final ctrl = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: i == 0 ? '主号码' : '号码 ${i + 1}',
                    prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              if (_phoneControllers.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      color: AppColors.countdownDanger),
                  onPressed: () {
                    setState(() {
                      _phoneControllers[i].dispose();
                      _phoneControllers.removeAt(i);
                    });
                  },
                ),
            ],
          ),
        );
      }),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            setState(() => _phoneControllers.add(TextEditingController()));
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('添加号码'),
        ),
      ),
    ];
  }

  Widget _buildCarrierPicker() {
    return InkWell(
      onTap: () => _showCarrierPicker(),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.cell_tower_rounded, size: 20),
          suffixIcon: Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          _carrierName.isEmpty ? '选择运营商' : _carrierName,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _carrierName.isEmpty
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _showCarrierPicker() async {
    final result = await CarrierPickerSheet.show(context);

    if (result != null) {
      setState(() {
        _carrierCode = result.code;
        _carrierName = result.name;
        _countryCode = result.countryCode;
        _cardColor = result.themeColor;
      });
    }
  }

  Widget _buildCountryPicker() {
    return InkWell(
      onTap: () => _showCountryPicker(),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.public_rounded, size: 20),
          suffixIcon: Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          CountryData.displayName(_countryCode),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _showCountryPicker() async {
    final result = await CountryPickerSheet.show(context);

    if (result != null) {
      setState(() => _countryCode = result);
    }
  }

  // ══════════════════════════════════════════════════════════
  // Section 2: 有效期
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildValiditySection() {
    return [
      _label('有效期类型'),
      ...ValidityType.values.map((type) {
        return RadioListTile<ValidityType>(
          title: Text(type.label, style: GoogleFonts.inter(fontSize: 14)),
          subtitle: Text(type.description,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5))),
          value: type,
          groupValue: _validityType,
          dense: true,
          onChanged: (v) {
            if (v != null) setState(() => _validityType = v);
          },
          contentPadding: EdgeInsets.zero,
        );
      }),
      const SizedBox(height: 12),

      // 激活日期
      _label('激活日期'),
      _buildDatePicker(
        date: _activationDate,
        hint: '选择激活日期',
        onPicked: (d) => setState(() => _activationDate = d),
      ),
      const SizedBox(height: 12),

      // 固定到期日
      if (_validityType == ValidityType.fixedDate) ...[
        _label('到期日期'),
        _buildDatePicker(
          date: _expirationDate,
          hint: '选择到期日期',
          onPicked: (d) => setState(() => _expirationDate = d),
        ),
        const SizedBox(height: 12),
      ],

      // 滚动天数
      if (_validityType == ValidityType.rolling) ...[
        _label('滚动天数'),
        TextFormField(
          initialValue: _rollingDays.toString(),
          decoration: const InputDecoration(
            hintText: '例如 30',
            suffixText: '天',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _rollingDays = int.tryParse(v) ?? 30;
          },
        ),
        const SizedBox(height: 12),
      ],

      // 提醒天数
      _label('提前提醒天数'),
      TextFormField(
        initialValue: _reminderDays.toString(),
        decoration: const InputDecoration(
          hintText: '到期前几天提醒',
          suffixText: '天',
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          _reminderDays = int.tryParse(v) ?? 7;
        },
      ),
    ];
  }

  Widget _buildDatePicker({
    DateTime? date,
    required String hint,
    required ValueChanged<DateTime> onPicked,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.event_rounded, size: 20),
          suffixIcon: Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          date != null ? dateFormat.format(date) : hint,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: date == null
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)
                : null,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Section 3: 用量记录
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildUsageSection() {
    return [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('流量剩余 (MB)'),
                TextFormField(
                  initialValue: _dataBalance,
                  decoration: const InputDecoration(hintText: '例如 1024'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _dataBalance = v,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('流量总量 (MB)'),
                TextFormField(
                  initialValue: _dataTotal,
                  decoration: const InputDecoration(hintText: '例如 5120'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _dataTotal = v,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('通话剩余（分钟）'),
                TextFormField(
                  initialValue: _voiceRemaining,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _voiceRemaining = v,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('通话总量（分钟）'),
                TextFormField(
                  initialValue: _voiceTotal,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _voiceTotal = v,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('短信剩余'),
                TextFormField(
                  initialValue: _smsRemaining,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _smsRemaining = v,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('短信总量'),
                TextFormField(
                  initialValue: _smsTotal,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _smsTotal = v,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('话费余额'),
                TextFormField(
                  initialValue: _balance,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _balance = v,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('币种'),
                TextFormField(
                  initialValue: _balanceCurrency,
                  decoration: const InputDecoration(hintText: 'CNY'),
                  onChanged: (v) => _balanceCurrency = v,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════
  // Section 4: 功能支持
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildFeaturesSection() {
    return _features.entries.map((entry) {
      return FeatureToggleTile(
        featureName: entry.key,
        featureItem: entry.value,
        onChanged: (item) {
          setState(() {
            _features.updateByKey(entry.key, item);
          });
        },
      );
    }).toList();
  }

  // ══════════════════════════════════════════════════════════
  // Section 5: eSIM 信息
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildEsimSection() {
    return [
      _label('SM-DP+ 服务器地址'),
      TextFormField(
        controller: _rspServerController,
        decoration: const InputDecoration(
          hintText: '例如 rsp.example.com',
        ),
        onChanged: (v) => _rspServer = v,
      ),
      const SizedBox(height: 12),
      _label('激活码（匹配ID）'),
      TextFormField(
        controller: _activationCodeController,
        decoration: const InputDecoration(
          hintText: '匹配ID',
        ),
        onChanged: (v) => _activationCode = v,
      ),
      const SizedBox(height: 12),
      _label('确认码'),
      TextFormField(
        controller: _confirmationCodeController,
        onChanged: (v) => _confirmationCode = v,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          final result = await Navigator.of(context).push<Map<String, String>>(
            MaterialPageRoute(builder: (_) => const QrScannerScreen()),
          );
          if (result != null) {
            setState(() {
              _rspServer = result['rspServer'] ?? _rspServer;
              _rspServerController.text = _rspServer;
              _activationCode = result['activationCode'] ?? _activationCode;
              _activationCodeController.text = _activationCode;
              _confirmationCode = result['confirmationCode'] ?? _confirmationCode;
              _confirmationCodeController.text = _confirmationCode;
            });
          }
        },
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('扫描QR码'),
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════
  // Section 6: 外观与分类
  // ══════════════════════════════════════════════════════════

  List<Widget> _buildAppearanceSection() {
    final provider = context.watch<SimCardProvider>();

    // 运营商默认色
    Color? carrierDefault;
    if (_carrierCode != null) {
      final carrier = CarrierData.findByCode(_carrierCode!);
      carrierDefault = carrier?.themeColor;
    }

    return [
      // 颜色选择
      _label('卡片颜色'),
      InkWell(
        onTap: () async {
          final picked = await ColorPickerDialog.show(
            context,
            currentColor: _cardColor,
            carrierDefaultColor: carrierDefault,
            carrierName: _carrierName,
          );
          if (picked != null) {
            setState(() => _cardColor = picked);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.chevron_right_rounded),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _cardColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('更改颜色', style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 标签
      _label('标签'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: provider.tags.map((tag) {
          final isSelected = _selectedTagIds.contains(tag.id);
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(tag.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(tag.name),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedTagIds.add(tag.id!);
                } else {
                  _selectedTagIds.remove(tag.id!);
                }
              });
            },
            showCheckmark: false,
          );
        }).toList(),
      ),
      const SizedBox(height: 16),

      // 来源
      _label('来源渠道'),
      TextFormField(
        initialValue: _source,
        decoration:
            const InputDecoration(hintText: '例如: 淘宝代购、线下门店'),
        onChanged: (v) => _source = v,
      ),
      const SizedBox(height: 12),

      // 备注
      _label('备注'),
      TextFormField(
        initialValue: _notes,
        decoration: const InputDecoration(hintText: '其他备忘信息'),
        maxLines: 3,
        onChanged: (v) => _notes = v,
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════
  // 保存
  // ══════════════════════════════════════════════════════════

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_carrierName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择或输入运营商')),
      );
      return;
    }

    final phoneNumbers = _phoneControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final card = SimCard(
      id: widget.simCard?.id,
      uuid: widget.simCard?.uuid ?? _uuid.v4(),
      type: _simType,
      status: widget.simCard?.status ?? SimStatus.inactive,
      iccid: _iccid.isNotEmpty ? _iccid : null,
      carrierName: _carrierName,
      carrierCode: _carrierCode,
      countryCode: _countryCode,
      phoneNumbers: phoneNumbers,
      source: _source.isNotEmpty ? _source : null,
      notes: _notes.isNotEmpty ? _notes : null,
      validityType: _validityType,
      activationDate: _activationDate,
      expirationDate: _expirationDate,
      rollingDays:
          _validityType == ValidityType.rolling ? _rollingDays : null,
      lastUsedDate: widget.simCard?.lastUsedDate,
      reminderDaysBefore: _reminderDays,
      dataBalanceMB: double.tryParse(_dataBalance),
      dataTotalMB: double.tryParse(_dataTotal),
      voiceMinutesRemaining: double.tryParse(_voiceRemaining),
      voiceMinutesTotal: double.tryParse(_voiceTotal),
      smsRemaining: int.tryParse(_smsRemaining),
      smsTotal: int.tryParse(_smsTotal),
      balance: double.tryParse(_balance),
      balanceCurrency:
          _balanceCurrency.isNotEmpty ? _balanceCurrency : null,
      features: _features,
      rspServerAddress: _rspServer.isNotEmpty ? _rspServer : null,
      activationCode:
          _activationCode.isNotEmpty ? _activationCode : null,
      confirmationCode:
          _confirmationCode.isNotEmpty ? _confirmationCode : null,
      cardColor: _cardColor.toARGB32(),
      tagIds: _selectedTagIds,
      photoPath: widget.simCard?.photoPath,
      createdAt: widget.simCard?.createdAt,
    );

    final provider = context.read<SimCardProvider>();
    if (widget.isEditing) {
      await provider.updateSimCard(card);
    } else {
      await provider.addSimCard(card);
    }

    if (mounted) Navigator.of(context).pop();
  }

  // ── 工具方法 ──

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
