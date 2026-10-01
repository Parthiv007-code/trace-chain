import 'package:flutter/material.dart';

/// The five stakeholder roles identified in the TraceChain permissions
/// matrix (Section 3 of the project report). Each role maps to a
/// distinct identity in the eventual Hyperledger Fabric MSP — for the
/// frontend demo it simply drives which screens and data a user sees.
enum UserRole { manufacturer, distributor, retailer, regulator, consumer }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.manufacturer:
        return 'Manufacturer';
      case UserRole.distributor:
        return 'Distributor';
      case UserRole.retailer:
        return 'Retailer';
      case UserRole.regulator:
        return 'Regulator';
      case UserRole.consumer:
        return 'Consumer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.manufacturer:
        return 'Registers new batches and records raw material origin.';
      case UserRole.distributor:
        return 'Accepts custody, moves stock, logs condition checks, and can flag recalls.';
      case UserRole.retailer:
        return 'Receives shipments, prepares them for sale, and can flag recalls.';
      case UserRole.regulator:
        return 'Reviews recall flags and has authority to execute recalls.';
      case UserRole.consumer:
        return 'Scans a product QR code to verify its full provenance.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.manufacturer:
        return Icons.factory_outlined;
      case UserRole.distributor:
        return Icons.local_shipping_outlined;
      case UserRole.retailer:
        return Icons.storefront_outlined;
      case UserRole.regulator:
        return Icons.gavel_outlined;
      case UserRole.consumer:
        return Icons.qr_code_scanner_outlined;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.manufacturer:
        return const Color(0xFF2563EB);
      case UserRole.distributor:
        return const Color(0xFF7C3AED);
      case UserRole.retailer:
        return const Color(0xFFEA580C);
      case UserRole.regulator:
        return const Color(0xFFB91C1C);
      case UserRole.consumer:
        return const Color(0xFF0F766E);
    }
  }
}
