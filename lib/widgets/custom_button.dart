// File chứa widget button tùy chỉnh
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed; // Đổi thành VoidCallback? để chấp nhận null

  const CustomButton({
    required this.text,
    required this.isLoading,
    required this.onPressed, // Đổi thành VoidCallback?
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Sử dụng null khi loading
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text),
    );
  }
}