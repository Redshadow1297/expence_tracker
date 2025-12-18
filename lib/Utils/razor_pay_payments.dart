import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController {
  late Razorpay _razorpay;
  VoidCallback? onSuccess;
  String? scannedUpiId;

  MobileScannerController mobileScannerController =
      MobileScannerController(
        autoZoom: true,
    formats: [BarcodeFormat.qrCode],
    torchEnabled: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  PaymentController({this.onSuccess}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // void openCheckout({
  //   required int amountInINR,
  //   required String orderId,
  //   VoidCallback? onSuccess,
  // }) {
  //   this.onSuccess = onSuccess;
  //   // var options = {
  //   //   'key': 'rzp_test_Rp0NK7nOJ859cL',
  //   //   'amount': amountInINR * 100, // Convert INR to paise
  //   //   'name': 'Expense Tracker',
  //   //   'order_id': orderId,
  //   //   'description': 'Expense Payment via QR Scan',
  //   //   'prefill': {'contact': '9730028611', 'email': 'amolshinde1297@gmail.com'},
  //   //   'method': {'upi': true, 'card': true, 'netbanking': true, 'wallet': true},
  //   // };
  //   var options = {
  //     'key': 'rzp_test_Rp0NK7nOJ859cL',
  //     'amount': amountInINR * 100,
  //     'name': 'Expense Tracker',
  //     'description': 'Expense Payment',
  //     'method': {
  //       'upi': true,
  //       'card': false,
  //       'netbanking': false,
  //       'wallet': false,
  //     },
  //   };
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   }
  // }
  
  void openUpiCheckout({
  required int amountInINR,
  required String upiId,
  VoidCallback? onSuccess,
}) {
  this.onSuccess = onSuccess;

  var options = {
    'key': 'rzp_test_Rp0NK7nOJ859cL',
    'amount': amountInINR * 100,
    'name': 'Expense Tracker',
    'description': 'UPI Expense Payment',
    'method': {'upi': true},
    'upi': {
      'vpa': upiId,
    }
  };
  _razorpay.open(options);
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
