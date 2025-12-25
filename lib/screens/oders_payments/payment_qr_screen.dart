import 'dart:async';
import 'dart:convert'; // Dùng để decode Base64 ảnh
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class PaymentQrScreen extends StatefulWidget {
  static const routeName = '/payment-gateway';

  // Các tham số nhận từ CheckoutScreen
  final String qrData;       // Chuỗi Base64 QR code
  final double amount;       // Số tiền
  final String sessionCode;  // Mã phiên thanh toán (VNPay Ref)
  final String orderIdToCheck; // ID đơn hàng để polling API

  const PaymentQrScreen({
    Key? key,
    required this.qrData,
    required this.amount,
    required this.sessionCode,
    required this.orderIdToCheck,
  }) : super(key: key);

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  late Timer _timer;         // Timer đếm ngược
  late Timer _pollingTimer;  // Timer gọi API check status
  int _timeLeft = 900;       // 15 phút = 900 giây
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();

    // 1. Bắt đầu đếm ngược 15 phút
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer.cancel();
        _pollingTimer.cancel(); // Hết giờ thì dừng check luôn
        // Có thể navigate sang trang báo lỗi timeout tại đây
      }
    });

    // 2. Bắt đầu Polling: Check status mỗi 3 giây
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  // Hàm gọi Provider để check trạng thái đơn hàng
  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return; // Tránh gọi chồng chéo
    _isChecking = true;

    try {
      // Gọi hàm checkOrderStatus trong OrderProvider (cần đảm bảo bạn đã viết hàm này trong Provider)
      final isPaid = await Provider.of<OrderProvider>(context, listen: false)
          .checkOrderStatus(widget.orderIdToCheck);

      if (isPaid) {
        _navigateToResult(true);
      }
    } catch (e) {
      print("Polling error: $e");
    } finally {
      _isChecking = false;
    }
  }

  void _navigateToResult(bool success) {
    _pollingTimer.cancel();
    _timer.cancel();
    Navigator.pushReplacementNamed(context, '/payment-result', arguments: {
      'success': success,
      'message': success ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
      'orderId': widget.sessionCode
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    if (_pollingTimer.isActive) _pollingTimer.cancel();
    super.dispose();
  }

  // Format giây thành mm:ss
  String get _timerString {
    final minutes = (_timeLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Xử lý chuỗi Base64: Backend NestJS thường trả về "data:image/png;base64,....."
    // Dart convert base64Decode chỉ cần phần sau dấu phẩy
    final base64String = widget.qrData.contains(',')
        ? widget.qrData.split(',').last
        : widget.qrData;

    return Scaffold(
      backgroundColor: Colors.blue[50], // Nền sáng nhẹ
      appBar: AppBar(
        title: const Text("Thanh toán VNPAY", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CARD QR CODE ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Logo VNPAY giả lập (Text hoặc Image Asset)
                    const Text('VNPAY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Giao dịch bảo mật', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // QR CODE IMAGE
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: base64String.isNotEmpty
                          ? Image.memory(
                        base64Decode(base64String),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            Text("Lỗi ảnh QR"),
                          ],
                        ),
                      )
                          : const Center(child: Text("Không có dữ liệu QR")),
                    ),
                    const SizedBox(height: 24),

                    // SỐ TIỀN & MÃ GD
                    Text(
                      currencyFormat.format(widget.amount),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text('Mã GD: ${widget.sessionCode}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 12),
                    const Text('Sử dụng App Ngân hàng hoặc VNPAY để quét mã', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- COUNTDOWN TIMER ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.orange.shade200)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Hết hạn sau: $_timerString',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- POLLING STATUS ---
              // Hiển thị loading nhỏ để user biết App đang check
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text("Đang chờ xác nhận thanh toán...", style: TextStyle(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 20),

              // Nút giả lập (Dùng khi test server local không kết nối vnpay được)
              // Bạn có thể comment lại khi deploy product
              TextButton(
                  onPressed: () => _navigateToResult(true),
                  child: const Text("(DEV ONLY) Giả lập: Đã thanh toán", style: TextStyle(color: Colors.grey, fontSize: 12))
              )
            ],
          ),
        ),
      ),
    );
  }
}