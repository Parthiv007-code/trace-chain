/// Reference to an off-chain document (certificate, inspection photo).
/// Only [ipfsHash] is ever written on-chain — the file itself lives in
/// IPFS, exactly as described in Section 5 of the project report.
class DocumentRef {
  final String name;
  final String ipfsHash;
  final String uploadedBy;
  final DateTime timestamp;

  const DocumentRef({
    required this.name,
    required this.ipfsHash,
    required this.uploadedBy,
    required this.timestamp,
  });
}
