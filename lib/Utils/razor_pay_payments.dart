import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
class PaymentController {
  late Razorpay _razorpay;
  VoidCallback? onSuccess;

  PaymentController({this.onSuccess}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({required int amountInINR, VoidCallback? onSuccess}) {
  this.onSuccess = onSuccess;
  var options = {
    'key': 'rzp_test_Rp0NK7nOJ859cL',
    'amount': amountInINR,
    'name': 'Expense Tracker',
    'description': 'Expense Payment',
    'prefill': {
      'contact': '9730028611',
      'email': 'amolshinde1297@gmail.com',
    },
    'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      }
  };
  try {
    _razorpay.open(options);
  } catch (e) {
    debugPrint("Error opening Razorpay: $e");
  }
}

void _handlePaymentSuccess(PaymentSuccessResponse response) {
  Get.snackbar(
    "Success",
    "Payment Successful! ID: ${response.paymentId}",
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );
  if (onSuccess != null) onSuccess!(); // notify UI
}

  // void openCheckout({required int amountInINR, VoidCallback? onSuccess}) {
  //   this.onSuccess = onSuccess;
  //   var options = {
  //     'key': 'rzp_test_Rp0NK7nOJ859cL', // replace with your key
  //     'amount': amountInINR * 100, // in paise
  //     'name': 'Expense Tracker',
  //     'description': 'Expense Payment',
  //     'timeout': 300,
  //     'prefill': {'contact': '9730028611', 'email': 'amolshinde1297@gmail.com'}
  //   };
  //   _razorpay.open(options);
  // }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      "Payment Failed",
      "Error: ${response.code} - ${response.message}",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      "Wallet Selected",
      "${response.walletName}",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
