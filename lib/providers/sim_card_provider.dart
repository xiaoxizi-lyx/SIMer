import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../data/countries.dart';
import '../database/database_helper.dart';
import '../models/calendar_date.dart';
import '../models/enums.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import 'filter_provider.dart';

/// SIM卡状态管理
class SimCardProvider extends ChangeNotifier {
  SimCardProvider({DatabaseHelper? database})
    : _db = database ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  List<SimCard> _simCards = [];
  List<SimCard> _archivedCards = [];
  List<Tag> _tags = [];
  bool _isLoading = false;

  /// 卡片数据发生变化（增删改、归档、导入后重新加载）时调用，用于重排提醒等。
  VoidCallback? onCardsChanged;

  // ── Getters ──

  UnmodifiableListView<SimCard> get simCards => UnmodifiableListView(_simCards);
  UnmodifiableListView<SimCard> get archivedCards =>
      UnmodifiableListView(_archivedCards);
  UnmodifiableListView<Tag> get tags => UnmodifiableListView(_tags);
  bool get isLoading => _isLoading;

  /// 未归档卡片中满足 [filter] 的数量（用于筛选项计数）。
  int countFor(StatusFilter filter, {DateTime? today}) {
    final day = today ?? CalendarDate.today();
    return _simCards.where((c) => _matchesStatus(c, filter, day)).length;
  }

  // ── 数据加载 ──

  /// 加载所有数据（卡片 + 归档 + 标签）
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cards = await _db.getSimCards();
      _simCards = cards.where((c) => !c.isArchived).toList();
      _archivedCards = cards.where((c) => c.isArchived).toList()
        ..sort((a, b) => b.archivedAt!.compareTo(a.archivedAt!));
      _tags = await _db.getAllTags();
    } on Exception catch (e) {
      debugPrint('加载数据失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      onCardsChanged?.call();
    }
  }

  // ── SIM卡 ──

  Future<int> addSimCard(SimCard card) async {
    final id = await _db.insertSimCard(card);
    card.id = id;
    _simCards.insert(0, card);
    _changed();
    return id;
  }

  Future<void> updateSimCard(SimCard card) async {
    card.touch();
    await _db.updateSimCard(card);
    _replace(_simCards, card);
    _replace(_archivedCards, card);
    _changed();
  }

  /// 归档：保留激活状态，只记录归档时间。
  Future<void> archiveSimCard(int id) async {
    final now = clock.now().toUtc();
    await _db.archiveSimCard(id, now);
    final index = _simCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final card = _simCards.removeAt(index)
        ..archivedAt = now
        ..touch();
      _archivedCards.insert(0, card);
    }
    _changed();
  }

  /// 取消归档，恢复为归档前的激活状态。
  Future<void> restoreSimCard(int id) async {
    await _db.restoreSimCard(id);
    final index = _archivedCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final card = _archivedCards.removeAt(index)
        ..archivedAt = null
        ..touch();
      _simCards.insert(0, card);
    }
    _changed();
  }

  Future<void> permanentlyDelete(int id) async {
    await _db.permanentlyDeleteSimCard(id);
    _simCards.removeWhere((c) => c.id == id);
    _archivedCards.removeWhere((c) => c.id == id);
    _changed();
  }

  /// 设置滚动有效期的上次使用日（「我已使用」及其撤销）。
  Future<void> setLastUsedDate(int id, DateTime? date) async {
    final card = getSimCardById(id);
    if (card == null) return;
    final value = date == null ? null : CalendarDate.of(date);
    await _db.setLastUsedDate(id, value);
    card
      ..lastUsedDate = value
      ..touch();
    _changed();
  }

  /// 记录今天已使用（滚动有效期续期）。
  Future<void> markAsUsed(int id) => setLastUsedDate(id, CalendarDate.today());

  // ── 标签 ──

  /// 是否已有同名标签（不区分大小写）。
  bool isTagNameTaken(String name, {int? exceptId}) {
    final key = name.trim().toLowerCase();
    return _tags.any((t) => t.id != exceptId && t.name.toLowerCase() == key);
  }

  Future<int> addTag(Tag tag) async {
    final id = await _db.insertTag(tag);
    tag.id = id;
    _tags.insert(0, tag);
    notifyListeners();
    return id;
  }

  Future<void> updateTag(Tag tag) async {
    await _db.updateTag(tag);
    _tags = [for (final t in _tags) t.id == tag.id ? tag : t];
    notifyListeners();
  }

  Future<void> deleteTag(int id) async {
    await _db.deleteTag(id);
    _tags.removeWhere((t) => t.id == id);
    for (final card in [..._simCards, ..._archivedCards]) {
      card.tagIds.remove(id);
    }
    notifyListeners();
  }

  // ── 按 ID 查找 ──

  SimCard? getSimCardById(int id) {
    for (final card in [..._simCards, ..._archivedCards]) {
      if (card.id == id) return card;
    }
    return null;
  }

  SimCard? getSimCardByUuid(String uuid) {
    for (final card in [..._simCards, ..._archivedCards]) {
      if (card.uuid == uuid) return card;
    }
    return null;
  }

  Tag? getTagById(int id) {
    for (final tag in _tags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  // ── 筛选与排序 ──

  /// 根据筛选条件获取过滤后并排序的（未归档）卡片列表
  List<SimCard> getFilteredAndSorted(FilterProvider filter, {DateTime? today}) {
    final day = today ?? CalendarDate.today();
    final query = filter.searchQuery.trim().toLowerCase();
    final tagNames = {for (final t in _tags) t.id: t.name.toLowerCase()};

    final result = _simCards.where((card) {
      if (query.isNotEmpty && !_matchesQuery(card, query, tagNames)) {
        return false;
      }
      final status = filter.statusFilter;
      if (status != null && !_matchesStatus(card, status, day)) return false;
      if (filter.countryFilter != null &&
          card.countryCode != filter.countryFilter) {
        return false;
      }
      if (filter.carrierFilter != null &&
          card.carrierName != filter.carrierFilter) {
        return false;
      }
      if (filter.tagFilters.isNotEmpty &&
          !card.tagIds.any(filter.tagFilters.contains)) {
        return false;
      }
      return true;
    }).toList();

    result.sort((a, b) {
      final comparison = switch (filter.sortBy) {
        SortBy.createdAt => a.createdAt.compareTo(b.createdAt),
        SortBy.expirationDate => _compareExpiration(a, b),
        SortBy.carrierName => a.carrierName.compareTo(b.carrierName),
        SortBy.countryCode => a.countryCode.compareTo(b.countryCode),
      };
      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    return result;
  }

  /// 所有卡片正在使用的颜色集合（用于为新卡片分配不冲突的颜色）
  Set<int> get usedCardColors => {
    for (final card in [..._simCards, ..._archivedCards]) card.cardColor,
  };

  // ── 私有方法 ──

  void _changed() {
    notifyListeners();
    onCardsChanged?.call();
  }

  static void _replace(List<SimCard> list, SimCard card) {
    final index = list.indexWhere((c) => c.id == card.id);
    if (index != -1) list[index] = card;
  }

  static bool _matchesStatus(
    SimCard card,
    StatusFilter filter,
    DateTime day,
  ) => switch (filter) {
    StatusFilter.active => card.activationStatus == ActivationStatus.active,
    StatusFilter.inactive => card.activationStatus == ActivationStatus.inactive,
    StatusFilter.expiringSoon =>
      card.validityStateOn(day) == ValidityState.expiringSoon,
    StatusFilter.expired => card.validityStateOn(day) == ValidityState.expired,
  };

  static bool _matchesQuery(
    SimCard card,
    String query,
    Map<int?, String> tagNames,
  ) {
    bool has(String? value) => value?.toLowerCase().contains(query) ?? false;
    final digitsQuery = query.replaceAll(RegExp(r'[\s\-()]'), '');
    bool hasDigits(String? value) =>
        digitsQuery.isNotEmpty &&
        (value?.replaceAll(RegExp(r'[\s\-()]'), '').contains(digitsQuery) ??
            false);

    return has(card.carrierName) ||
        card.phoneNumbers.any((p) => has(p) || hasDigits(p)) ||
        has(card.iccid) ||
        hasDigits(card.iccid) ||
        has(card.notes) ||
        has(card.source) ||
        has(card.countryCode) ||
        has(CountryData.countries[card.countryCode]) ||
        has(card.rspServerAddress) ||
        card.tagIds.any((id) => tagNames[id]?.contains(query) ?? false);
  }

  /// 按到期日排序，没有到期日的卡片排在最后。
  static int _compareExpiration(SimCard a, SimCard b) {
    final aDate = a.effectiveExpirationDate;
    final bDate = b.effectiveExpirationDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }
}
