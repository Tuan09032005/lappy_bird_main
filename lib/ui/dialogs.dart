// lib/ui/dialogs.dart
import 'package:flutter/material.dart';

Future<void> showNoInternetDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Không có mạng'),
      content: const Text('Không thể kết nối Internet. Vui lòng kiểm tra kết nối và thử lại.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(c).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
