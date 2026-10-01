import 'dart:math';

/// Generates plausible-looking IDs and transaction hashes so the demo UI
/// reads like a real ledger. Every real call site is isolated to
/// [MockChainService] — once the actual Fabric/Hardhat integration lands,
/// these are simply replaced by the hashes the network returns.
class IdGenerator {
  static final Random _rng = Random();
  static const _hexChars = '0123456789abcdef';

  /// e.g. TC-BATCH-0F3A9C21
  static String batchId() {
    return 'TC-BATCH-${_hex(8).toUpperCase()}';
  }

  /// e.g. 0x8f2a1c...e91b (mimics a Fabric/Ethereum transaction hash)
  static String txHash() => '0x${_hex(64)}';

  /// e.g. Qm... style short mock IPFS CID
  static String ipfsHash() => 'Qm${_alphaNum(44)}';

  static String eventId() => _hex(12);

  static String _hex(int length) {
    return List.generate(length, (_) => _hexChars[_rng.nextInt(16)]).join();
  }

  static String _alphaNum(int length) {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
    return List.generate(length, (_) => chars[_rng.nextInt(chars.length)])
        .join();
  }
}
