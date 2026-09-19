import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/sim_card.dart';
import '../providers/sim_card_provider.dart';
import '../providers/filter_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sim_card_flip.dart';
import '../widgets/filter_chips.dart' as fc;
import '../widgets/sort_menu.dart';
import 'add_edit_sim_screen.dart';
import 'settings_screen.dart';

/// 首页 – SIM卡列表
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── 筛选栏 ──
          _buildFilterBar(),
          // ── 卡片列表 ──
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final filterProvider = context.watch<FilterProvider>();

    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              filterProvider.setSearchQuery('');
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索运营商、号码、ICCID…',
            hintStyle: GoogleFonts.inter(fontSize: 15),
            border: InputBorder.none,
            filled: false,
          ),
          style: GoogleFonts.inter(fontSize: 15),
          onChanged: (value) {
            filterProvider.setSearchQuery(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                filterProvider.clearSearch();
              },
            ),
        ],
      );
    }

    return AppBar(
      title: Text(
        'SIMer',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: '搜索',
          onPressed: () {
            setState(() => _isSearching = true);
          },
        ),
        SortMenu(
          currentSortBy: filterProvider.sortBy,
          currentSortOrder: filterProvider.sortOrder,
          onSortByChanged: (sortBy) {
            filterProvider.setSortBy(sortBy);
          },
          onSortOrderChanged: (order) {
            filterProvider.setSortOrder(order);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: '设置',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final simCardProvider = context.watch<SimCardProvider>();
    final filterProvider = context.watch<FilterProvider>();

    // 统计可用的国家（不含归档）
    final countries = <String>{};
    for (final card in simCardProvider.simCards) {
      countries.add(card.countryCode);
    }

    // 可用标签
    final tagEntries = simCardProvider.tags
        .where((t) => t.id != null)
        .map((t) => MapEntry(t.id!, t.name))
        .toList();

    return fc.FilterChips(
      statusFilter: filterProvider.statusFilter,
      countryFilter: filterProvider.countryFilter,
      tagFilters: filterProvider.tagFilters,
      availableCountries: countries,
      availableTags: tagEntries,
      onStatusChanged: (status) {
        filterProvider.setStatusFilter(status);
      },
      onCountryChanged: (country) {
        filterProvider.setCountryFilter(country);
      },
      onTagsChanged: (tags) {
        filterProvider.setTagFilters(tags);
      },
    );
  }

  Widget _buildBody() {
    final simCardProvider = context.watch<SimCardProvider>();
    final filterProvider = context.watch<FilterProvider>();

    if (simCardProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    // 使用 SimCardProvider 内置的筛选/排序
    final filteredCards = simCardProvider.getFilteredAndSorted(filterProvider);

    if (filteredCards.isEmpty) {
      final hasFilters = filterProvider.hasActiveFilters ||
          filterProvider.searchQuery.isNotEmpty;
      return _buildEmptyState(hasFilters);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await simCardProvider.loadAll();
      },
      color: AppColors.primary,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ListView.builder(
          key: ValueKey('${filterProvider.sortBy}_${filterProvider.sortOrder}'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: filteredCards.length,
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SimCardFlip(
                key: ValueKey(card.uuid),
                simCard: card,
                tags: simCardProvider.tags,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditSimScreen(simCard: card),
                    ),
                  );
                },
                onArchive: () {
                  _confirmArchive(context, card);
                },
                onMarkAsUsed: () {
                  simCardProvider.markAsUsed(card.id!);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.filter_list_off_rounded
                  : Icons.sim_card_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? '没有匹配的SIM卡' : '还没有SIM卡记录',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters ? '试试调整筛选条件' : '点击下方按钮添加你的第一张SIM卡',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            ),

            if (hasFilters) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.read<FilterProvider>().clearAll();
                },
                child: const Text('清除筛选'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAdd(),
      icon: const Icon(Icons.add_rounded),
      label: Text(
        '添加SIM/eSIM信息',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditSimScreen()),
    );
  }

  void _confirmArchive(BuildContext context, SimCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('归档SIM卡'),
        content: Text('确定要将 ${card.carrierName} 的SIM卡归档吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SimCardProvider>().archiveSimCard(card.id!);
              Navigator.of(ctx).pop();
            },
            child: const Text('归档'),
          ),
        ],
      ),
    );
  }
}
