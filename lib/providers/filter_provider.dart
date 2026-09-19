import 'package:flutter/foundation.dart';
import '../models/enums.dart';

/// 筛选与排序状态管理
class FilterProvider extends ChangeNotifier {
  SimStatus? _statusFilter;
  String? _countryFilter;
  String? _carrierFilter;
  List<int> _tagFilters = [];
  SortBy _sortBy = SortBy.createdAt;
  SortOrder _sortOrder = SortOrder.descending;
  String _searchQuery = '';

  // ── Getters ──

  SimStatus? get statusFilter => _statusFilter;
  String? get countryFilter => _countryFilter;
  String? get carrierFilter => _carrierFilter;
  List<int> get tagFilters => List.unmodifiable(_tagFilters);
  SortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;

  /// 是否有激活的筛选条件
  bool get hasActiveFilters =>
      _statusFilter != null ||
      _countryFilter != null ||
      _carrierFilter != null ||
      _tagFilters.isNotEmpty;

  /// 激活的筛选条件总数（用于显示角标）
  int get activeFilterCount {
    int count = 0;
    if (_statusFilter != null) count++;
    if (_countryFilter != null) count++;
    if (_carrierFilter != null) count++;
    count += _tagFilters.length;
    return count;
  }

  // ── 设置筛选条件 ──

  void setStatusFilter(SimStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void setCountryFilter(String? countryCode) {
    if (_countryFilter == countryCode) return;
    _countryFilter = countryCode;
    notifyListeners();
  }

  void setCarrierFilter(String? carrier) {
    if (_carrierFilter == carrier) return;
    _carrierFilter = carrier;
    notifyListeners();
  }

  void setTagFilters(List<int> tagIds) {
    _tagFilters = List.from(tagIds);
    notifyListeners();
  }

  void addTagFilter(int tagId) {
    if (!_tagFilters.contains(tagId)) {
      _tagFilters.add(tagId);
      notifyListeners();
    }
  }

  void removeTagFilter(int tagId) {
    if (_tagFilters.remove(tagId)) {
      notifyListeners();
    }
  }

  void toggleTagFilter(int tagId) {
    if (_tagFilters.contains(tagId)) {
      _tagFilters.remove(tagId);
    } else {
      _tagFilters.add(tagId);
    }
    notifyListeners();
  }

  // ── 排序 ──

  void setSortBy(SortBy sortBy) {
    if (_sortBy == sortBy) return;
    _sortBy = sortBy;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder.toggled;
    notifyListeners();
  }

  // ── 搜索 ──

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  // ── 清除 ──

  /// 清除所有筛选条件（不清除搜索和排序）
  void clearFilters() {
    _statusFilter = null;
    _countryFilter = null;
    _carrierFilter = null;
    _tagFilters = [];
    notifyListeners();
  }

  /// 清除所有（筛选 + 搜索 + 排序重置）
  void clearAll() {
    _statusFilter = null;
    _countryFilter = null;
    _carrierFilter = null;
    _tagFilters = [];
    _sortBy = SortBy.createdAt;
    _sortOrder = SortOrder.descending;
    _searchQuery = '';
    notifyListeners();
  }
}
