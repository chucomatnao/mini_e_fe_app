import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    // Gọi API lấy danh sách đơn hàng khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng DefaultTabController để tạo 3 tab
    return DefaultTabController(
      length: 3, // Tổng số tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng của tôi'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          // --- THANH TAB BAR ---
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Chờ thanh toán'),
              Tab(text: 'Đang vận chuyển'),
              Tab(text: 'Đã nhận'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final allOrders = orderProvider.myOrders;

            // --- LỌC DỮ LIỆU CHO TỪNG TAB ---
            // 1. Chờ thanh toán (PENDING, UNPAID)
            final pendingOrders = allOrders.where((o) =>
            o.status == 'PENDING' ||
                o.status == 'AWAITING_PAYMENT' ||
                o.paymentStatus == 'UNPAID'
            ).toList();

            // 2. Đang vận chuyển (CONFIRMED, SHIPPED, DELIVERING)
            final shippingOrders = allOrders.where((o) =>
            o.status == 'CONFIRMED' ||
                o.status == 'SHIPPED' ||
                o.status == 'DELIVERING' ||
                (o.status == 'PAID' && o.status != 'COMPLETED') // Đã thanh toán nhưng chưa hoàn thành
            ).toList();

            // 3. Đã nhận / Hoàn thành (COMPLETED, DELIVERED, CANCELLED)
            final completedOrders = allOrders.where((o) =>
            o.status == 'COMPLETED' ||
                o.status == 'DELIVERED' ||
                o.status == 'CANCELLED'
            ).toList();

            // --- NỘI DUNG TỪNG TAB ---
            return TabBarView(
              children: [
                _buildOrderList(pendingOrders, 'Chưa có đơn hàng chờ thanh toán'),
                _buildOrderList(shippingOrders, 'Chưa có đơn hàng đang vận chuyển'),
                _buildOrderList(completedOrders, 'Chưa có đơn hàng hoàn thành'),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget hiển thị danh sách đơn hàng (Dùng chung cho cả 3 tab)
  Widget _buildOrderList(List<OrderModel> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(order);
      },
    );
  }

  // Widget hiển thị chi tiết 1 Card đơn hàng
  Widget _buildOrderItem(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mã đơn + Trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.code}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Ngày đặt + Tổng tiền
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng thanh toán:'),
              Text(
                currencyFormat.format(order.total),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nút hành động (Tùy theo trạng thái mà hiện nút khác nhau)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to Order Detail
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('Xem chi tiết', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 8),
              if (order.status == 'COMPLETED')
                ElevatedButton(
                  onPressed: () {
                    // Logic mua lại
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Mua lại'),
                ),
              if (order.status == 'PENDING')
                ElevatedButton(
                  onPressed: () {
                    // Logic thanh toán tiếp
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: const Text('Thanh toán'),
                ),
            ],
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'UNPAID':
        return Colors.orange;
      case 'PAID':
      case 'CONFIRMED':
      case 'SHIPPED':
        return Colors.blue;
      case 'COMPLETED':
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {

    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}