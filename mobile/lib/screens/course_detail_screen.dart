import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/api_client.dart';
import 'lesson_list_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _api = ApiClient();
  final _razorpay = Razorpay();
  String? _orderId;
  String? _status;
  bool _busy = false;
  bool _enrolled = false;

  @override
  void initState() {
    super.initState();
    _enrolled = widget.course['enrolled'] == true;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _buy() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final order = await _api.createOrder(widget.course['id']);
      _orderId = order['orderId'];

      _razorpay.open(
        {
          'key': order['keyId'],
          'amount': order['amount'],
          'currency': order['currency'],
          'order_id': order['orderId'],
          'name': 'Coaching',
          'description': widget.course['title'],
        },
      );
    } catch (e) {
      setState(() {
        _status = e.toString();
        _busy = false;
      });
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _api.verifyPayment(
        orderId: _orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
      );
      setState(() {
        _status = 'Enrolled! You can now watch the lessons.';
        _enrolled = true;
      });
    } catch (e) {
      setState(() => _status = 'Payment captured but verification failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() {
      _status = 'Payment failed: ${response.message}';
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(title: Text(course['title'])),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course['description']),
            const SizedBox(height: 16),
            Text('₹${(course['priceInPaise'] / 100).toStringAsFixed(0)}'),
            const SizedBox(height: 24),
            if (_enrolled)
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LessonListScreen(
                      courseId: course['id'],
                      courseTitle: course['title'],
                    ),
                  ),
                ),
                child: const Text('Go to lessons'),
              )
            else
              ElevatedButton(
                onPressed: _busy ? null : _buy,
                child: _busy ? const CircularProgressIndicator() : const Text('Buy now'),
              ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!),
            ],
          ],
        ),
      ),
    );
  }
}
