
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:gig_connect/pages/OTP_input.dart';
import 'package:gig_connect/services/send_OTP.dart';

class OtpVerify extends StatelessWidget {
   OtpVerify({super.key});
  final phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Otp Verification'),
      ),
      body: SafeArea(
        child: ListView(
          
          children: [
            const SizedBox(height: 50),
            //logo  
            Center(child: const Icon(Icons.account_balance,size: 100,)),
            const SizedBox(height: 50),
            //welcome back
            Center(
              child: Text("Welcome To Our App",
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),),  
            ),
            const SizedBox(height: 25),
            //username 
            MyTextfield(label: "Phone Number", controller: phoneController, obscureText: false,keyboardType: TextInputType.number,),
            
            const SizedBox(height: 25),
            //sign in button
            MyButton(onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) =>OTPVerificationScreen() ,));
              sendOTP(phoneController.text);
            } ,
            text: "Send OTP",
            ),
          ]
          
    )
    ));
  }
}