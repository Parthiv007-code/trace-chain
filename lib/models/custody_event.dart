/// One custody handoff in a batch's chain of custody. In production this
/// corresponds to a `transferCustody()` chaincode invocation and would be
/// read back from the Fabric ledger rather than held in memory.
class CustodyEvent {
  final String id;
  final String fromEntity;
  final String toEntity;
  final DateTime timestamp;
  final String location;
  final bool conditionsOk;
  final String txHash;

  const CustodyEvent({
    required this.id,
    required this.fromEntity,
    required this.toEntity,
    required this.timestamp,
    required this.location,
    required this.conditionsOk,
    required this.txHash,
  });
}
