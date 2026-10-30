import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/payment_error_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebview extends StatelessWidget {
  final String transactionUrl;
  final Function(String) onPaymentComplete;
  const PaymentWebview({
    super.key,
    required this.transactionUrl,
    required this.onPaymentComplete,
  });

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade50,
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 40.sp,
                    color: Colors.red.shade600,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  translate('paymentFailed'),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Error Message
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.red.shade100,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red.shade800,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      onPaymentComplete('Payment failed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      translate('confirm'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  NavigationDecision _handleNavigation(String url, BuildContext context) {
    final paymentStatus = _determinePaymentStatus(url);
    if (paymentStatus != null) {
      if (paymentStatus == 'Payment success') {
        onPaymentComplete(paymentStatus);
      } else {
        _showErrorDialog(context, paymentStatus);
      }
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  String? _determinePaymentStatus(String url) {
    // Check for success
    if (url.contains(AppConstants.approved) ||
        (url.contains('status=') && url.contains('status=success'))) {
      return 'Payment success';
    }

    // Parse URL parameters for status and message
    try {
      final uri = Uri.parse(url);

      // Check for status parameter
      final status = uri.queryParameters['status'];
      if (status == 'failed') {
        // Get the error message from URL parameter if available
        final errorMessageParam = uri.queryParameters['message'];
        if (errorMessageParam != null) {
          // Decode the message (it might be URL encoded)
          final decodedMessage = Uri.decodeComponent(errorMessageParam);

          // Use the payment error handler to get user-friendly message
          final userFriendlyMessage =
              PaymentErrorHandler.getErrorMessage(decodedMessage);
          return userFriendlyMessage ??
              PaymentErrorHandler.getErrorMessage(url);
        }
      }
    } catch (e) {
      // If URL parsing fails, continue with normal error detection
    }

    // Use comprehensive payment error handler
    final errorMessage = PaymentErrorHandler.getErrorMessage(url);
    return errorMessage;
  }

  WebViewController _initializeController(BuildContext context) {
    return WebViewController()
      ..loadRequest(Uri.parse(transactionUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              _handleNavigation(request.url, context),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, 60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.payment),
          isTextOnly: false,
        ),
      ),
      body: WebViewWidget(
        controller: _initializeController(context),
      ),
    );
  }
}
