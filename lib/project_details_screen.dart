import 'dart:js' as js;
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final Razorpay _razorpay = Razorpay();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      js.context.callMethod('addEventListener', [
        'flutter_inappwebview.paymentSuccess',
        js.allowInterop((event) {
          final jsObject = js.JsObject.fromBrowserObject(event)['detail'];
          if (jsObject is js.JsObject) {
            final responseMap = {
              'razorpay_payment_id': jsObject.hasProperty('razorpay_payment_id') ? jsObject['razorpay_payment_id'] : null,
              'razorpay_order_id': jsObject.hasProperty('razorpay_order_id') ? jsObject['razorpay_order_id'] : null,
              'razorpay_signature': jsObject.hasProperty('razorpay_signature') ? jsObject['razorpay_signature'] : null,
            };
            _handlePaymentSuccess(responseMap);
          }
        })
      ]);
    } else {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    amountController.dispose();
    super.dispose();
  }

  /// Handles successful payments
  void _handlePaymentSuccess(dynamic response) async {
    String? paymentId;
    double amount = double.parse(amountController.text);

    if (response is PaymentSuccessResponse) {
      paymentId = response.paymentId;
    } else if (response is Map<String, dynamic>) {
      paymentId = response['razorpay_payment_id'];
    } else if (response is String) {
      Map<String, dynamic> decodedResponse = jsonDecode(response);
      paymentId = decodedResponse['razorpay_payment_id'];
    }

    if (paymentId != null) {
      await _updateFirestore(paymentId, amount);
    }
  }

  /// Handles failed payments
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed! Please try again.")),
    );
  }

  /// Handles external wallets
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  /// Updates Firestore with payment details
  Future<void> _updateFirestore(String? transactionId, double amount) async {
    if (transactionId == null) return;

    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    try {
      await FirebaseFirestore.instance.collection('investments').add({
        'projectId': widget.projectId,
        'investorId': userId,
        'amount': amount,
        'transactionId': transactionId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      DocumentReference projectRef = FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) throw Exception("Project not found!");

        double newAmount = (snapshot['currentAmountRaised'] ?? 0) + amount;
        transaction.update(projectRef, {'currentAmountRaised': newAmount});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful! ₹$amount added.")),
      );
      amountController.clear();
    } catch (e) {
      print("Firestore update failed: $e");
    }
  }

  /// Initiates the payment process
  void initiatePayment() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid amount!")),
      );
      return;
    }

    if (kIsWeb) {
      var options = js.JsObject.jsify({
        "key": "rzp_test_YJpRN2tDnFgOld",
        "amount": amount * 100,
        "currency": "INR",
        "name": "GreenFund Connect",
        "description": "Support Green Initiatives",
        "handler": js.allowInterop((response) {
          final responseMap = {
            'razorpay_payment_id': response['razorpay_payment_id'],
            'razorpay_order_id': response['razorpay_order_id'],
            'razorpay_signature': response['razorpay_signature'],
          };
          _handlePaymentSuccess(responseMap);
        }),
      });

      js.JsObject razorpay = js.JsObject(js.context['Razorpay'], [options]);
      razorpay.callMethod('open');
    } else {
      var options = {
        'key': 'rzp_test_YJpRN2tDnFgOld',
        'amount': amount * 100,
        'currency': 'INR',
        'name': 'GreenFund Connect',
        'description': 'Project Contribution',
        'prefill': {
          'email': FirebaseAuth.instance.currentUser?.email ?? "",
          'contact': '1234567890',
        },
        'external': {'wallets': ['paytm']}
      };

      _razorpay.open(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Project Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').doc(widget.projectId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Project not found!"));
          }

          var projectData = snapshot.data!.data() as Map<String, dynamic>?;

          if (projectData == null) {
            return Center(child: Text("Project data is missing!"));
          }

          String projectOwnerId = projectData['ownerId'] ?? "";
          String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
          bool isOwner = projectOwnerId == currentUserId;

          double goalAmount = projectData['goalAmount'].toDouble();
          double currentAmountRaised = projectData['currentAmountRaised'].toDouble();
          double progress = (currentAmountRaised / goalAmount).clamp(0.0, 1.0);
          String? imageUrl = projectData['imageUrl'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 200, width: double.infinity, color: Colors.grey[300]),

                SizedBox(height: 10),
                Text(projectData['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(projectData['description']),
                SizedBox(height: 20),
                Text("Goal: ₹$goalAmount"),
                Text("Raised: ₹$currentAmountRaised"),
                LinearProgressIndicator(value: progress),
                SizedBox(height: 20),

                if (!isOwner) ...[
                  TextField(controller: amountController, decoration: InputDecoration(labelText: "Enter Amount (₹)")),
                  SizedBox(height: 10),
                  ElevatedButton(onPressed: initiatePayment, child: Text("Contribute")),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
