import '../models/batch.dart';
import '../models/batch_status.dart';
import '../models/custody_event.dart';
import '../models/sensor_event.dart';
import '../models/user_role.dart';
import '../utils/id_generator.dart';
import '../utils/mock_data.dart';
import 'chain_service.dart';

class MockChainService implements ChainService {
  final List<Batch> _ledger = buildSeedBatches();

  static const _simulatedLatency = Duration(milliseconds: 650);

  @override
  Future<List<Batch>> fetchAllBatches() async {
    await Future.delayed(_simulatedLatency);
    return List.unmodifiable(_ledger);
  }

  @override
  Future<Batch> registerBatch({
    required String productName,
    required String category,
    required List<String> rawMaterials,
    required String manufacturerName,
    required String originLocation,
  }) async {
    await Future.delayed(_simulatedLatency);
    final batch = Batch(
      id: IdGenerator.batchId(),
      productName: productName,
      category: category,
      rawMaterials: rawMaterials,
      manufacturerName: manufacturerName,
      originLocation: originLocation,
      registeredAt: DateTime.now(),
      registrationTxHash: IdGenerator.txHash(),
      currentHolderName: manufacturerName,
      currentHolderRole: UserRole.manufacturer,
      status: BatchStatus.registered,
    );
    _ledger.insert(0, batch);
    return batch;
  }

  @override
  Future<Batch> transferCustody({
    required String batchId,
    required String toEntity,
    required UserRole toRole,
    required String location,
    required bool conditionsOk,
  }) async {
    await Future.delayed(_simulatedLatency);
    final batch = _find(batchId);

    if (batch.status == BatchStatus.recalled) {
      throw StateError('A recalled batch cannot be transferred.');
    }
    if (batch.recallFlagged) {
      throw StateError(
        'This batch is flagged for recall and is awaiting regulator review.',
      );
    }

    final event = CustodyEvent(
      id: IdGenerator.eventId(),
      fromEntity: batch.currentHolderName,
      toEntity: toEntity,
      timestamp: DateTime.now(),
      location: location,
      conditionsOk: conditionsOk,
      txHash: IdGenerator.txHash(),
    );
    batch.custodyHistory.add(event);
    batch.currentHolderName = toEntity;
    batch.currentHolderRole = toRole;
    batch.status = toRole == UserRole.retailer
        ? BatchStatus.delivered
        : BatchStatus.inTransit;
    return batch;
  }

  @override
  Future<Batch> recordSensorEvent({
    required String batchId,
    required double temperatureC,
    required double humidityPct,
    required String location,
  }) async {
    await Future.delayed(_simulatedLatency);
    final batch = _find(batchId);
    batch.sensorEvents.add(
      SensorEvent(
        id: IdGenerator.eventId(),
        timestamp: DateTime.now(),
        temperatureC: temperatureC,
        humidityPct: humidityPct,
        location: location,
        txHash: IdGenerator.txHash(),
      ),
    );
    return batch;
  }

  @override
  Future<Batch?> verifyProduct(String batchId) async {
    await Future.delayed(_simulatedLatency);
    try {
      return _find(batchId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Batch> flagRecall({
    required String batchId,
    required String reason,
    required String flaggedBy,
    required UserRole flaggedByRole,
  }) async {
    await Future.delayed(_simulatedLatency);
    final batch = _find(batchId);

    if (flaggedByRole != UserRole.distributor &&
        flaggedByRole != UserRole.retailer) {
      throw StateError('Only distributors and retailers can flag recalls.');
    }
    if (batch.status == BatchStatus.recalled) {
      throw StateError('This batch has already been recalled.');
    }
    if (batch.currentHolderRole != flaggedByRole ||
        batch.currentHolderName != flaggedBy) {
      throw StateError('Only the current custodian can flag this batch.');
    }
    if (batch.recallFlagged) {
      throw StateError('This batch already has an active recall flag.');
    }

    batch.recallFlagged = true;
    batch.recallFlagReason = reason;
    batch.recallFlaggedBy = flaggedBy;
    batch.recallFlaggedByRole = flaggedByRole;
    batch.recallFlaggedAt = DateTime.now();
    batch.recallFlagTxHash = IdGenerator.txHash();
    return batch;
  }

  @override
  Future<Batch> recallBatch({
    required String batchId,
    required String reason,
  }) async {
    await Future.delayed(_simulatedLatency);
    final batch = _find(batchId);

    if (batch.status == BatchStatus.recalled) {
      throw StateError('This batch has already been recalled.');
    }
    if (!batch.recallFlagged) {
      throw StateError(
        'A recall flag must be reviewed before the regulator can recall this batch.',
      );
    }

    batch.status = BatchStatus.recalled;
    batch.recallReason = reason.trim().isEmpty
        ? batch.recallFlagReason
        : reason.trim();
    batch.recalledAt = DateTime.now();
    batch.recallTxHash = IdGenerator.txHash();
    return batch;
  }

  Batch _find(String batchId) =>
      _ledger.firstWhere((b) => b.id == batchId);
}
