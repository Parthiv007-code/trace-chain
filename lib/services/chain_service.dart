import '../models/batch.dart';
import '../models/user_role.dart';

/// Contract used by the UI. Each method maps to a future chaincode function.
abstract class ChainService {
  Future<List<Batch>> fetchAllBatches();

  Future<Batch> registerBatch({
    required String productName,
    required String category,
    required List<String> rawMaterials,
    required String manufacturerName,
    required String originLocation,
  });

  Future<Batch> transferCustody({
    required String batchId,
    required String toEntity,
    required UserRole toRole,
    required String location,
    required bool conditionsOk,
  });

  Future<Batch> recordSensorEvent({
    required String batchId,
    required double temperatureC,
    required double humidityPct,
    required String location,
  });

  Future<Batch?> verifyProduct(String batchId);

  /// Distributor/retailer reports a suspected problem. This does NOT recall.
  Future<Batch> flagRecall({
    required String batchId,
    required String reason,
    required String flaggedBy,
    required UserRole flaggedByRole,
  });

  /// Regulator executes the actual recall after reviewing a flag.
  Future<Batch> recallBatch({
    required String batchId,
    required String reason,
  });
}
