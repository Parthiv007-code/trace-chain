import '../models/batch.dart';
import '../models/batch_status.dart';
import '../models/custody_event.dart';
import '../models/document_ref.dart';
import '../models/sensor_event.dart';
import '../models/user_role.dart';
import 'id_generator.dart';

/// Seed batches so every dashboard has realistic data to demo against,
/// instead of an empty state on first launch. Timestamps are relative to
/// "now" so the app always looks current.
List<Batch> buildSeedBatches() {
  final now = DateTime.now();

  final batch1 = Batch(
    id: 'TC-BATCH-A1F00291',
    productName: 'Organic Basmati Rice — 25kg sacks',
    category: 'Grains & Cereals',
    rawMaterials: const ['Paddy (Farm Cluster 4, Thanjavur)', 'Jute sacking'],
    manufacturerName: 'Harvest Mills Pvt. Ltd.',
    originLocation: 'Thanjavur, TN',
    registeredAt: now.subtract(const Duration(days: 6)),
    registrationTxHash: IdGenerator.txHash(),
    currentHolderName: 'Southern Distributors Co.',
    currentHolderRole: UserRole.distributor,
    status: BatchStatus.inTransit,
    custodyHistory: [
      CustodyEvent(
        id: IdGenerator.eventId(),
        fromEntity: 'Harvest Mills Pvt. Ltd.',
        toEntity: 'Southern Distributors Co.',
        timestamp: now.subtract(const Duration(days: 4, hours: 3)),
        location: 'Thanjavur Warehouse',
        conditionsOk: true,
        txHash: IdGenerator.txHash(),
      ),
    ],
    sensorEvents: List.generate(6, (i) {
      final t = now.subtract(Duration(hours: (6 - i) * 8));
      return SensorEvent(
        id: IdGenerator.eventId(),
        timestamp: t,
        temperatureC: 24 + (i.isEven ? 1.4 : -0.8),
        humidityPct: 55 + (i * 1.2),
        location: i < 3 ? 'Thanjavur Warehouse' : 'NH-45 Transit',
        txHash: IdGenerator.txHash(),
      );
    }),
    documents: [
      DocumentRef(
        name: 'Certificate of Origin.pdf',
        ipfsHash: IdGenerator.ipfsHash(),
        uploadedBy: 'Harvest Mills Pvt. Ltd.',
        timestamp: now.subtract(const Duration(days: 6)),
      ),
    ],
  );

  final batch2 = Batch(
    id: 'TC-BATCH-77CE10AB',
    productName: 'Cold-Pressed Sunflower Oil — 5L cans',
    category: 'Edible Oils',
    rawMaterials: const ['Sunflower seed (Farm Cluster 1)'],
    manufacturerName: 'Harvest Mills Pvt. Ltd.',
    originLocation: 'Salem, TN',
    registeredAt: now.subtract(const Duration(days: 12)),
    registrationTxHash: IdGenerator.txHash(),
    currentHolderName: 'FreshMart Retail',
    currentHolderRole: UserRole.retailer,
    status: BatchStatus.delivered,
    custodyHistory: [
      CustodyEvent(
        id: IdGenerator.eventId(),
        fromEntity: 'Harvest Mills Pvt. Ltd.',
        toEntity: 'Southern Distributors Co.',
        timestamp: now.subtract(const Duration(days: 10)),
        location: 'Salem Plant',
        conditionsOk: true,
        txHash: IdGenerator.txHash(),
      ),
      CustodyEvent(
        id: IdGenerator.eventId(),
        fromEntity: 'Southern Distributors Co.',
        toEntity: 'FreshMart Retail',
        timestamp: now.subtract(const Duration(days: 7)),
        location: 'Chennai Distribution Hub',
        conditionsOk: true,
        txHash: IdGenerator.txHash(),
      ),
    ],
    sensorEvents: List.generate(4, (i) {
      final t = now.subtract(Duration(days: 9 - i * 2));
      return SensorEvent(
        id: IdGenerator.eventId(),
        timestamp: t,
        temperatureC: 22 + i * 0.5,
        humidityPct: 48.0 + i,
        location: 'Chennai Distribution Hub',
        txHash: IdGenerator.txHash(),
      );
    }),
    documents: [
      DocumentRef(
        name: 'Quality Inspection Report.pdf',
        ipfsHash: IdGenerator.ipfsHash(),
        uploadedBy: 'Southern Distributors Co.',
        timestamp: now.subtract(const Duration(days: 8)),
      ),
    ],
  );

  final batch3 = Batch(
    id: 'TC-BATCH-3E902CDF',
    productName: 'A2 Ghee — 1L jars',
    category: 'Dairy',
    rawMaterials: const ['Raw milk (Gir cattle farm, Erode)'],
    manufacturerName: 'Harvest Mills Pvt. Ltd.',
    originLocation: 'Erode, TN',
    registeredAt: now.subtract(const Duration(days: 2)),
    registrationTxHash: IdGenerator.txHash(),
    currentHolderName: 'Harvest Mills Pvt. Ltd.',
    currentHolderRole: UserRole.manufacturer,
    status: BatchStatus.registered,
    custodyHistory: const [],
    sensorEvents: List.generate(2, (i) {
      final t = now.subtract(Duration(hours: (2 - i) * 6));
      return SensorEvent(
        id: IdGenerator.eventId(),
        timestamp: t,
        temperatureC: 18 + i * 0.3,
        humidityPct: 40.0 + i,
        location: 'Erode Cold Store',
        txHash: IdGenerator.txHash(),
      );
    }),
    documents: const [],
  );

  final batch4 = Batch(
    id: 'TC-BATCH-9B120E45',
    productName: 'Frozen Prawns — 2kg vacuum packs',
    category: 'Seafood',
    rawMaterials: const ['Wild-caught prawns (Nagapattinam coast)'],
    manufacturerName: 'Coastal Catch Exports',
    originLocation: 'Nagapattinam, TN',
    registeredAt: now.subtract(const Duration(days: 9)),
    registrationTxHash: IdGenerator.txHash(),
    currentHolderName: 'FreshMart Retail',
    currentHolderRole: UserRole.retailer,
    status: BatchStatus.recalled,
    recallReason:
        'Cold-chain breach detected — temperature exceeded 4°C for over 40 minutes during transit.',
    recallFlagged: true,
    recallFlagReason:
        'Cold-chain breach detected — temperature exceeded 4°C for over 40 minutes during transit.',
    recallFlaggedBy: 'FreshMart Retail',
    recallFlaggedByRole: UserRole.retailer,
    recallFlaggedAt: now.subtract(const Duration(days: 4)),
    recallFlagTxHash: IdGenerator.txHash(),
    recalledAt: now.subtract(const Duration(days: 3)),
    recallTxHash: IdGenerator.txHash(),
    custodyHistory: [
      CustodyEvent(
        id: IdGenerator.eventId(),
        fromEntity: 'Coastal Catch Exports',
        toEntity: 'Southern Distributors Co.',
        timestamp: now.subtract(const Duration(days: 7)),
        location: 'Nagapattinam Cold Store',
        conditionsOk: true,
        txHash: IdGenerator.txHash(),
      ),
      CustodyEvent(
        id: IdGenerator.eventId(),
        fromEntity: 'Southern Distributors Co.',
        toEntity: 'FreshMart Retail',
        timestamp: now.subtract(const Duration(days: 5)),
        location: 'Chennai Distribution Hub',
        conditionsOk: false,
        txHash: IdGenerator.txHash(),
      ),
    ],
    sensorEvents: List.generate(5, (i) {
      final t = now.subtract(Duration(days: 6, hours: i * 4));
      return SensorEvent(
        id: IdGenerator.eventId(),
        timestamp: t,
        temperatureC: i == 3 ? 6.8 : 2.5,
        humidityPct: 70.0 + i,
        location: 'NH-45 Transit',
        txHash: IdGenerator.txHash(),
      );
    }),
    documents: [
      DocumentRef(
        name: 'Cold Chain Log.pdf',
        ipfsHash: IdGenerator.ipfsHash(),
        uploadedBy: 'Southern Distributors Co.',
        timestamp: now.subtract(const Duration(days: 5)),
      ),
    ],
  );

  return [batch1, batch2, batch3, batch4];
}
