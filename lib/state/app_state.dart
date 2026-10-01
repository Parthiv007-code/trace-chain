import 'package:flutter/foundation.dart';

import '../models/batch.dart';
import '../models/user_role.dart';
import '../services/chain_service.dart';
import '../services/mock_chain_service.dart';

class AppState extends ChangeNotifier {
  AppState({ChainService? chainService})
      : _service = chainService ?? MockChainService() {
    _loadBatches();
  }

  final ChainService _service;

  UserRole? _currentRole;
  String _currentUserName = '';
  List<Batch> _batches = [];
  bool _isLoading = true;
  bool _isDarkMode = false;
  String? _errorMessage;

  UserRole? get currentRole => _currentRole;
  String get currentUserName => _currentUserName;
  List<Batch> get batches => List.unmodifiable(_batches);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;
  ChainService get service => _service;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> _loadBatches() async {
    _isLoading = true;
    notifyListeners();
    try {
      _batches = await _service.fetchAllBatches();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Could not reach the ledger. Showing cached data.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadBatches();

  void selectRole(UserRole role, String userName) {
    _currentRole = role;
    _currentUserName = userName.trim().isEmpty
        ? _defaultNameFor(role)
        : userName.trim();
    notifyListeners();
  }

  void signOut() {
    _currentRole = null;
    _currentUserName = '';
    notifyListeners();
  }

  String _defaultNameFor(UserRole role) {
    switch (role) {
      case UserRole.manufacturer:
        return 'Harvest Mills Pvt. Ltd.';
      case UserRole.distributor:
        return 'Southern Distributors Co.';
      case UserRole.retailer:
        return 'FreshMart Retail';
      case UserRole.regulator:
        return 'Regional Food Safety Authority';
      case UserRole.consumer:
        return 'Guest Consumer';
    }
  }

  List<Batch> batchesForCurrentRole() {
    if (_currentRole == null) return const [];
    switch (_currentRole!) {
      case UserRole.regulator:
        return _batches;
      case UserRole.manufacturer:
        return _batches
            .where((b) => b.manufacturerName == _currentUserName)
            .toList();
      case UserRole.distributor:
      case UserRole.retailer:
        return _batches
            .where((b) => b.currentHolderRole == _currentRole)
            .toList();
      case UserRole.consumer:
        return const [];
    }
  }

  Future<Batch> registerBatch({
    required String productName,
    required String category,
    required List<String> rawMaterials,
    required String originLocation,
  }) async {
    final batch = await _service.registerBatch(
      productName: productName,
      category: category,
      rawMaterials: rawMaterials,
      manufacturerName: _currentUserName,
      originLocation: originLocation,
    );
    _batches = [batch, ..._batches];
    notifyListeners();
    return batch;
  }

  Future<Batch> transferCustody({
    required String batchId,
    required String toEntity,
    required UserRole toRole,
    required String location,
    required bool conditionsOk,
  }) async {
    final updated = await _service.transferCustody(
      batchId: batchId,
      toEntity: toEntity,
      toRole: toRole,
      location: location,
      conditionsOk: conditionsOk,
    );
    _replace(updated);
    return updated;
  }

  Future<Batch> flagRecall({
    required String batchId,
    required String reason,
  }) async {
    final role = _currentRole;
    if (role != UserRole.distributor && role != UserRole.retailer) {
      throw StateError('Only distributors and retailers can flag recalls.');
    }

    final updated = await _service.flagRecall(
      batchId: batchId,
      reason: reason,
      flaggedBy: _currentUserName,
      flaggedByRole: role!,
    );
    _replace(updated);
    return updated;
  }

  Future<Batch> recallBatch({
    required String batchId,
    required String reason,
  }) async {
    if (_currentRole != UserRole.regulator) {
      throw StateError('Only regulators can execute a recall.');
    }

    final updated = await _service.recallBatch(
      batchId: batchId,
      reason: reason,
    );
    _replace(updated);
    return updated;
  }

  Future<Batch?> verifyProduct(String batchId) =>
      _service.verifyProduct(batchId);

  void _replace(Batch updated) {
    _batches = _batches
        .map((b) => b.id == updated.id ? updated : b)
        .toList();
    notifyListeners();
  }
}
