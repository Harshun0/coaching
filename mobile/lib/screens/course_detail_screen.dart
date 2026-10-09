import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/api_client.dart';
import '../theme.dart';
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
  bool _statusIsError = false;
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
        _statusIsError = true;
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
        _statusIsError = false;
        _enrolled = true;
      });
    } catch (e) {
      setState(() {
        _status = 'Payment captured but verification failed: $e';
        _statusIsError = true;
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() {
      _status = 'Payment failed: ${response.message}';
      _statusIsError = true;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 60, 16),
                    child: Text(
                      course['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList.list(
              children: [
                Text('About this course', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(course['description'], style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text("What's included", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _Feature(icon: Icons.play_circle_outline_rounded, label: 'Full video lessons'),
                _Feature(icon: Icons.all_inclusive_rounded, label: 'Lifetime access'),
                _Feature(icon: Icons.lock_outline_rounded, label: 'Single-device secure login'),
                if (_status != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusIsError ? const Color(0xFFFFEBEE) : const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _status!,
                      style: TextStyle(
                        color: _statusIsError ? const Color(0xFFC62828) : AppColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (!_enrolled) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '₹${(course['priceInPaise'] / 100).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: _enrolled
                    ? ElevatedButton(
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
                    : ElevatedButton(
                        onPressed: _busy ? null : _buy,
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Buy now'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
