// lib/screens/shop_register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

// Thay thế toàn bộ nội dung file
class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _checkingName = false;
  bool _nameExists = false;

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tên shop
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên shop *',
                  suffixIcon: _checkingName ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
                onChanged: (value) async {
                  if (value.trim().length > 2) {
                    setState(() => _checkingName = true);
                    _nameExists = await shopProvider.checkNameExists(value.trim());
                    setState(() => _checkingName = false);
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                  if (_nameExists) return 'Tên shop đã tồn tại';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bắt buộc';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Mô tả *'),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: shopProvider.isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    await shopProvider.register({
                      'name': _nameCtrl.text.trim(),
                      'email': _emailCtrl.text.trim().toLowerCase(),
                      'description': _descCtrl.text.trim(),
                    });
                    if (shopProvider.error == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đăng ký thành công! Chờ duyệt...')),
                      );
                    }
                  }
                },
                child: shopProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng ký Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}