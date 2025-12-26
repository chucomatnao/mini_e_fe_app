import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  final bool selectMode; // ✅ mới
  final int? initialSelectedId; // ✅ mới (để highlight)

  const AddressListScreen({
    Key? key,
    this.selectMode = false,
    this.initialSelectedId,
  }) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshList();
    });
  }

  Future<void> _refreshList() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.accessToken != null) {
      await Provider.of<AddressProvider>(context, listen: false)
          .fetchAddresses(auth.accessToken!);
    }
  }

  Future<void> _deleteAddress(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
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
        await Provider.of<AddressProvider>(context, listen: false)
            .deleteAddress(auth.accessToken!, id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa địa chỉ thành công')),
        );

        // nếu đang chọn mà bị xóa thì clear chọn
        if (_selectedId == id) setState(() => _selectedId = null);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _setAsDefault(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AddressProvider>(context, listen: false);

    try {
      await provider.updateAddress(auth.accessToken!, id, {'isDefault': true});
      await _refreshList();

      if (!mounted) return;
      Navigator.pop(context); // đóng modal detail
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt làm địa chỉ mặc định')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddressDetail(AddressModel addr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Thông tin địa chỉ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                        Text(
                          'Đây là địa chỉ mặc định',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: addr.isDefault
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          onPressed: null,
                          child: const Text('Đã là mặc định',
                              style: TextStyle(color: Colors.white)),
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
    final title = widget.selectMode ? 'Chọn địa chỉ' : 'Địa chỉ của tôi';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Thêm địa chỉ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
              ).then((_) => _refreshList());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chưa có địa chỉ nào'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                        ).then((_) => _refreshList());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm địa chỉ mới'),
                    )
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.addresses.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (ctx, i) {
              final addr = provider.addresses[i];
              final isPicked = _selectedId == addr.id;

              return ListTile(
                onTap: () {
                  if (widget.selectMode) {
                    setState(() => _selectedId = addr.id);
                    Navigator.pop(context, addr); // ✅ trả về địa chỉ đã chọn
                  } else {
                    _showAddressDetail(addr);
                  }
                },
                leading: widget.selectMode
                    ? Icon(
                        isPicked ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isPicked ? Colors.blue : Colors.grey,
                      )
                    : null,
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
                        child: const Text('Mặc định',
                            style: TextStyle(color: Colors.red, fontSize: 10)),
                      )
                  ],
                ),
                isThreeLine: true,

                // ✅ selectMode thì ẩn edit/delete (tránh rối)
                trailing: widget.selectMode
                    ? null
                    : Row(
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
