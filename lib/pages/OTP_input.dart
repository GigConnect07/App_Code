import 'package:flutter/material.dart';
import 'package:gig_connect/services/send_OTP.dart';
import 'package:gig_connect/services/verify_OTP.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({
    super.key, 
    required this.phoneNumber,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String otpCode = "";
  bool _isVerifying = false;
  String _statusMessage = "";
  bool _isSuccess = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit code sent to +91${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 40,
              style: TextStyle(fontSize: 17),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              onChanged: (pin) {
                // Update the code as the user types
                setState(() {
                  otpCode = pin;
                });
              },
              onCompleted: (pin) {
                setState(() {
                  otpCode = pin;
                });
                // Auto-verify when all digits are entered
                _verifyOTP();
              },
            ),
            SizedBox(height: 20),
            
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
            SizedBox(height: 10),
            
            _isVerifying
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: otpCode.length == 6 ? _verifyOTP : null,
                        child: Text("Verify OTP"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: _resendOTP,
                        child: Text("Resend OTP"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (otpCode.length != 6) {
      setState(() {
        _statusMessage = "Please enter a valid 6-digit OTP";
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _statusMessage = "Verifying...";
      _isSuccess = false;
    });

    try {
      // Call your verification function
      await verifyOTP(otpCode);
      
      setState(() {
        _isVerifying = false;
        _statusMessage = "Verification successful!";
        _isSuccess = true;
      });
      
      // Navigate to your home screen or next page after success
      // Add a slight delay for the user to see the success message
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed('/home'); // Replace with your home route
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _statusMessage = "Verification failed: ${e.toString()}";
        _isSuccess = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isVerifying = true;
      _statusMessage = "Sending new OTP...";
      _isSuccess = false;
    });

    try {
      // Import and call your sendOTP function

      await sendOTP(widget.phoneNumber);
      
      setState(() {
        _isVerifying = false;
        _statusMessage = "New OTP sent successfully!";
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _statusMessage = "Failed to send new OTP: ${e.toString()}";
        _isSuccess = false;
      });
    }
  }
}