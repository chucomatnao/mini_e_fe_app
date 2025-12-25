import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart'; // Import Model
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshList();
    });
  }

  Future<void> _refreshList() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.accessToken != null) {
      await Provider.of<AddressProvider>(context, listen: false).fetchAddresses(auth.accessToken!);
    }
  }

  // Hàm xóa (như cũ)
  Future<void> _deleteAddress(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(child: const Text('Hủy'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      try {
        await Provider.of<AddressProvider>(context, listen: false).deleteAddress(auth.accessToken!, id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa địa chỉ thành công')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // --- HÀM MỚI: ĐẶT LÀM MẶC ĐỊNH ---
  Future<void> _setAsDefault(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AddressProvider>(context, listen: false);

    try {
      // Gọi API update với isDefault = true
      // Lưu ý: Backend cần xử lý logic tự động tắt các default khác
      await provider.updateAddress(auth.accessToken!, id, {'isDefault': true});

      // Tải lại danh sách để cập nhật giao diện
      await _refreshList();

      if (mounted) {
        Navigator.pop(context); // Đóng modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt làm địa chỉ mặc định')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM MỚI: HIỂN THỊ CHI TIẾT ---
  void _showAddressDetail(AddressModel addr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép modal điều chỉnh chiều cao linh hoạt hơn
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // Bọc SingleChildScrollView để tránh lỗi Overflow khi nội dung dài
        return SingleChildScrollView(
          child: Padding(
            // Thêm padding bottom theo viewInsets để tránh bị che bởi phím ảo (nếu có)
            // hoặc thanh điều hướng hệ thống
            padding: EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text('Thông tin địa chỉ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    )
                ),
                const Divider(),
                const SizedBox(height: 10),

                _buildDetailRow(Icons.person, 'Người nhận', addr.fullName),
                _buildDetailRow(Icons.phone, 'Số điện thoại', addr.phone),
                _buildDetailRow(Icons.location_on, 'Địa chỉ', addr.formattedAddress),

                if (addr.isDefault)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Đây là địa chỉ mặc định', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Nút chức năng
                SizedBox(
                  width: double.infinity,
                  child: addr.isDefault
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: null,
                    child: const Text('Đã là mặc định', style: TextStyle(color: Colors.white)),
                  )
                      : ElevatedButton(
                    onPressed: () => _setAsDefault(addr.id),
                    child: const Text('Đặt làm mặc định'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ của tôi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          ).then((_) => _refreshList()); // Refresh khi quay lại
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.addresses.isEmpty) {
            return const Center(child: Text('Chưa có địa chỉ nào'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.addresses.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (ctx, i) {
              final addr = provider.addresses[i];
              return ListTile(
                // THÊM: Sự kiện click vào item
                onTap: () => _showAddressDetail(addr),

                title: Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addr.phone),
                    Text(
                      addr.formattedAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (addr.isDefault)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Mặc định', style: TextStyle(color: Colors.red, fontSize: 10)),
                      )
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddAddressScreen(address: addr),
                          ),
                        ).then((_) => _refreshList());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAddress(addr.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}