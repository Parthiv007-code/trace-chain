# TraceChain — Flutter Frontend (Milestone 1)

A Flutter implementation of the frontend for **TraceChain**, the
blockchain-based supply-chain traceability system described in the
project report (Hyperledger Fabric primary ledger, Ethereum anchor,
IPFS off-chain storage).

## What's in this build

This milestone is the **complete frontend**, running against a mock
ledger service (`MockChainService`) that mirrors the exact chaincode
functions described in the report:

- `registerBatch()`
- `transferCustody()`
- `recordSensorEvent()`
- `verifyProduct()`
- `flagRecall()`

Every screen talks to these functions through the `ChainService`
interface (`lib/services/chain_service.dart`) — never directly to the
mock. That's the seam: once the Fabric network, chaincode and Node.js
bridge exist, a `FabricChainService` implementing the same interface
replaces `MockChainService` in `lib/state/app_state.dart`, and no
screen needs to change.

### Screens

| Role | Screens |
|---|---|
| Manufacturer | Dashboard, Register Batch |
| Distributor / Retailer | Dashboard, Transfer Custody |
| Regulator | Dashboard (all batches, filters), Flag Recall |
| Consumer | Scan (simulated) / manual ID entry, Verification Result |
| All roles | Batch Detail (history, condition chart, custody timeline, IPFS docs, QR code) |

The role-select screen simulates the identity step that, on the real
network, comes from each organization's Fabric MSP.

## Running it

```bash
flutter pub get
flutter run
```

Requires Flutter 3.19+ / Dart 3.0+. No native permissions or platform
setup are required — the QR "scanner" is a simulated UI (tap a demo
product to simulate a scan) so the demo doesn't depend on camera
hardware or permission wiring. Real QR codes for each batch ARE
generated and shown on the batch detail screen via `qr_flutter`.

## What's next (Milestone 2)

- Deploy the Hyperledger Fabric test network (peers, orderer, CAs)
- Implement the five chaincode functions in Node.js
- Build the oracle bridge for simulated IoT sensor events
- Implement IPFS upload/pin for documents
- Write a `FabricChainService` and swap it in via `AppState`
- Wire a real camera scanner (e.g. `mobile_scanner`) into `ScanScreen`
- Deploy the small Solidity anchoring contract (Hardhat) on an Ethereum
  testnet
