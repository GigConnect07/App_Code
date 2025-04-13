import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:gig_connect/pages/OTP_input.dart';
import 'package:gig_connect/services/send_OTP.dart';

class OtpVerify extends StatefulWidget {
   OtpVerify({super.key});

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 50),
              //logo  
              Center(child: const Icon(Icons.account_balance, size: 100)),
              const SizedBox(height: 50),
              //welcome back
              Center(
                child: Text(
                  "Welcome To Our App",
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),  
              ),
              const SizedBox(height: 25),
              //username 
              MyTextfield(
                label: "Phone Number", 
                controller: phoneController, 
                obscureText: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter 10 digit phone number';
                  }
                  return null;
                },
              ),
              
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              const SizedBox(height: 25),
              
              // Show loading indicator or button
              _isLoading 
                ? Center(child: CircularProgressIndicator())
                : MyButton(
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return; // Validation failed, exit early
                      }
                      
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      
                      try {
                        // Send OTP first, then navigate to verification screen
                        await sendOTP(phoneController.text);
                        
                        // If we reach here, OTP was sent successfully
                      Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => OTPVerificationScreen(
                          phoneNumber: phoneController.text,
                        ),
                      ),

                        );
                      } catch (e) {
                        setState(() {
                          _errorMessage = 'Failed to send OTP: ${e.toString()}';
                        });
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    text: "Send OTP",
                  ),
            ],
          ),
        ),
      ),
    );
  }
}