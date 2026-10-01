import 'batch_status.dart';
import 'custody_event.dart';
import 'document_ref.dart';
import 'sensor_event.dart';
import 'user_role.dart';

/// The core on-chain record. Mirrors what registerBatch() creates and what
/// transferCustody(), recordSensorEvent(), flagRecall() and recallBatch()
/// mutate on the eventual ledger.
class Batch {
  final String id;
  final String productName;
  final String category;
  final List<String> rawMaterials;
  final String manufacturerName;
  final String originLocation;
  final DateTime registeredAt;
  final String registrationTxHash;

  String currentHolderName;
  UserRole currentHolderRole;
  BatchStatus status;
  String? recallReason;

  /// A distributor or retailer can report a suspected problem. This is
  /// deliberately separate from a completed recall.
  bool recallFlagged;
  String? recallFlagReason;
  String? recallFlaggedBy;
  UserRole? recallFlaggedByRole;
  DateTime? recallFlaggedAt;
  String? recallFlagTxHash;

  /// Populated when a regulator executes the actual recall.
  DateTime? recalledAt;
  String? recallTxHash;

  final List<CustodyEvent> custodyHistory;
  final List<SensorEvent> sensorEvents;
  final List<DocumentRef> documents;

  Batch({
    required this.id,
    required this.productName,
    required this.category,
    required this.rawMaterials,
    required this.manufacturerName,
    required this.originLocation,
    required this.registeredAt,
    required this.registrationTxHash,
    required this.currentHolderName,
    required this.currentHolderRole,
    required this.status,
    this.recallReason,
    this.recallFlagged = false,
    this.recallFlagReason,
    this.recallFlaggedBy,
    this.recallFlaggedByRole,
    this.recallFlaggedAt,
    this.recallFlagTxHash,
    this.recalledAt,
    this.recallTxHash,
    List<CustodyEvent>? custodyHistory,
    List<SensorEvent>? sensorEvents,
    List<DocumentRef>? documents,
  })  : custodyHistory = custodyHistory ?? [],
        sensorEvents = sensorEvents ?? [],
        documents = documents ?? [];

  SensorEvent? get lastSensorReading =>
      sensorEvents.isEmpty ? null : sensorEvents.last;

  bool get hasConditionBreach =>
      custodyHistory.any((e) => !e.conditionsOk);
}
