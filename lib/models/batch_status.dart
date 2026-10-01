import 'package:flutter/material.dart';

enum BatchStatus { registered, inTransit, delivered, recalled }

extension BatchStatusX on BatchStatus {
  String get label {
    switch (this) {
      case BatchStatus.registered:
        return 'Registered';
      case BatchStatus.inTransit:
        return 'In Transit';
      case BatchStatus.delivered:
        return 'Delivered';
      case BatchStatus.recalled:
        return 'Recalled';
    }
  }

  Color get color {
    switch (this) {
      case BatchStatus.registered:
        return const Color(0xFF64748B);
      case BatchStatus.inTransit:
        return const Color(0xFFCA8A04);
      case BatchStatus.delivered:
        return const Color(0xFF16A34A);
      case BatchStatus.recalled:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case BatchStatus.registered:
        return Icons.inventory_2_outlined;
      case BatchStatus.inTransit:
        return Icons.local_shipping_outlined;
      case BatchStatus.delivered:
        return Icons.check_circle_outline;
      case BatchStatus.recalled:
        return Icons.report_gmailerrorred_outlined;
    }
  }
}
