import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/sim_card.dart';
import '../models/enums.dart';
import '../models/tag.dart';
import 'filter_provider.dart';

/// SIM卡状态管理
class SimCardProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<SimCard> _simCards = [];
  List<SimCard> _archivedCards = [];
  List<Tag> _tags = [];
  bool _isLoading = false;

  // ── Getters ──

  List<SimCard> get simCards => List.unmodifiable(_simCards);
  List<SimCard> get archivedCards => List.unmodifiable(_archivedCards);
  List<Tag> get tags => List.unmodifiable(_tags);
  bool get isLoading => _isLoading;

  int get totalCount => _simCards.length;
  int get archivedCount => _archivedCards.length;

  int get activeCount =>
      _simCards.where((c) => c.status == SimStatus.active).length;
  int get expiredCount =>
      _simCards.where((c) => c.status == SimStatus.expired).length;
  int get expiringCount =>
      _simCards.where((c) => c.needsReminder).length;

  // ── 数据加载 ──

  /// 加载所有数据（卡片 + 归档 + 标签）
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _simCards = await _db.getAllSimCards();
      _archivedCards = await _db.getArchivedSimCards();
      _tags = await _db.getAllTags();

      // 自动更新已过期状态
      _autoUpdateExpiredStatus();
    } catch (e) {
      debugPrint('加载数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 自动将已过期卡片的状态更新为 expired
  void _autoUpdateExpiredStatus() {
    bool hasChanges = false;

    for (final card in _simCards) {
      if (card.isExpired &&
          card.status != SimStatus.expired &&
          card.status != SimStatus.archived) {
        card.status = SimStatus.expired;
        _db.updateSimCard(card); // 异步更新数据库，不等待
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  // ── SIM卡 CRUD ──

  /// 添加SIM卡
  Future<int> addSimCard(SimCard card) async {
    final id = await _db.insertSimCard(card);
    card.id = id;
    _simCards.insert(0, card);
    notifyListeners();
    return id;
  }

  /// 更新SIM卡
  Future<void> updateSimCard(SimCard card) async {
    card.updatedAt = DateTime.now();
    await _db.updateSimCard(card);

    final index = _simCards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _simCards[index] = card;
    }

    // 也可能在归档列表中
    final archiveIndex = _archivedCards.indexWhere((c) => c.id == card.id);
    if (archiveIndex != -1) {
      _archivedCards[archiveIndex] = card;
    }

    notifyListeners();
  }

  /// 归档SIM卡
  Future<void> archiveSimCard(int id) async {
    await _db.archiveSimCard(id);

    final index = _simCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final card = _simCards.removeAt(index);
      card.status = SimStatus.archived;
      card.updatedAt = DateTime.now();
      _archivedCards.insert(0, card);
    }

    notifyListeners();
  }

  /// 恢复SIM卡
  Future<void> restoreSimCard(int id) async {
    await _db.restoreSimCard(id);

    final index = _archivedCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final card = _archivedCards.removeAt(index);
      card.status = SimStatus.active;
      card.updatedAt = DateTime.now();
      _simCards.insert(0, card);
    }

    notifyListeners();
  }

  /// 永久删除SIM卡
  Future<void> permanentlyDelete(int id) async {
    await _db.permanentlyDeleteSimCard(id);
    _simCards.removeWhere((c) => c.id == id);
    _archivedCards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// 标记为已使用（滚动有效期）
  Future<void> markAsUsed(int id) async {
    await _db.markAsUsed(id);

    // 更新本地状态
    final index = _simCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      _simCards[index].markAsUsed();
    }

    notifyListeners();
  }

  // ── 标签 CRUD ──

  Future<int> addTag(Tag tag) async {
    final id = await _db.insertTag(tag);
    tag.id = id;
    _tags.insert(0, tag);
    notifyListeners();
    return id;
  }

  Future<void> updateTag(Tag tag) async {
    await _db.updateTag(tag);
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
    }
    notifyListeners();
  }

  Future<void> deleteTag(int id) async {
    await _db.deleteTag(id);
    _tags.removeWhere((t) => t.id == id);

    // 同时从所有卡片中移除该标签引用
    for (final card in _simCards) {
      card.tagIds.remove(id);
    }
    for (final card in _archivedCards) {
      card.tagIds.remove(id);
    }

    notifyListeners();
  }

  // ── 按 ID 查找 ──

  SimCard? getSimCardById(int id) {
    try {
      return _simCards.firstWhere((c) => c.id == id);
    } catch (_) {
      try {
        return _archivedCards.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Tag? getTagById(int id) {
    try {
      return _tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── 筛选与排序 ──

  /// 根据筛选条件获取过滤后并排序的卡片列表
  List<SimCard> getFilteredAndSorted(FilterProvider filterProvider) {
    List<SimCard> result = List.from(_simCards);

    // 搜索过滤
    if (filterProvider.searchQuery.isNotEmpty) {
      final query = filterProvider.searchQuery.toLowerCase();
      result = result.where((card) {
        return card.carrierName.toLowerCase().contains(query) ||
            card.phoneNumbers.any(
                (p) => p.toLowerCase().contains(query)) ||
            (card.iccid?.toLowerCase().contains(query) ?? false) ||
            (card.notes?.toLowerCase().contains(query) ?? false) ||
            (card.source?.toLowerCase().contains(query) ?? false) ||
            card.countryCode.toLowerCase().contains(query);
      }).toList();
    }

    // 状态筛选
    if (filterProvider.statusFilter != null) {
      result = result
          .where((c) => c.status == filterProvider.statusFilter)
          .toList();
    }

    // 国家筛选
    if (filterProvider.countryFilter != null) {
      result = result
          .where((c) => c.countryCode == filterProvider.countryFilter)
          .toList();
    }

    // 运营商筛选
    if (filterProvider.carrierFilter != null) {
      result = result
          .where((c) =>
              c.carrierCode == filterProvider.carrierFilter ||
              c.carrierName == filterProvider.carrierFilter)
          .toList();
    }

    // 标签筛选（包含任一选中标签即可）
    if (filterProvider.tagFilters.isNotEmpty) {
      result = result.where((c) {
        return c.tagIds.any(
            (tagId) => filterProvider.tagFilters.contains(tagId));
      }).toList();
    }

    // 排序
    result.sort((a, b) {
      int comparison;
      switch (filterProvider.sortBy) {
        case SortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
        case SortBy.expirationDate:
          final aDate = a.effectiveExpirationDate;
          final bDate = b.effectiveExpirationDate;
          if (aDate == null && bDate == null) {
            comparison = 0;
          } else if (aDate == null) {
            comparison = 1; // 无到期日排在后面
          } else if (bDate == null) {
            comparison = -1;
          } else {
            comparison = aDate.compareTo(bDate);
          }
        case SortBy.carrierName:
          comparison = a.carrierName.compareTo(b.carrierName);
        case SortBy.countryCode:
          comparison = a.countryCode.compareTo(b.countryCode);
      }

      return filterProvider.sortOrder == SortOrder.ascending
          ? comparison
          : -comparison;
    });

    return result;
  }

  /// 获取所有卡片正在使用的颜色集合（用于分配新卡片颜色）
  Set<int> get usedCardColors =>
      _simCards.map((c) => c.cardColor).toSet();
}
