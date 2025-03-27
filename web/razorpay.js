window.paymentSuccess = function (response) {
    console.log("Payment successful!", response);
    // Pass the response back to Flutter
    window.flutter_inappwebview.callHandler('paymentSuccess', response);
};

function openRazorpayCheckout(amount) {
    var options = {
        "key": "rzp_test_YJpRN2tDnFgOld", // Replace with your Razorpay API Key
        "amount": amount * 100, // Convert to paise
        "currency": "INR",
        "name": "GreenFund Connect",
        "description": "Project Contribution",
        "handler": function (response) {
            console.log("Payment successful: ", response);
            // You can call a Flutter function here if needed
            window.paymentSuccess(response.razorpay_payment_id);
        },
        "prefill": {
            "email": "test@example.com",
            "contact": "9999999999"
        },
        "theme": {
            "color": "#3399cc"
        }
    };

    var rzp1 = new Razorpay(options);
    rzp1.open();
}
