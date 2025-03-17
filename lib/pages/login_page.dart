
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:gig_connect/components/square_tile.dart';
import 'package:gig_connect/pages/phone_login.dart';
import 'package:gig_connect/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  void Function()? onTap;
  LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailController=TextEditingController();

  final passwordController=TextEditingController();

  void signUserIn(BuildContext context) async{
    //show loading circle
    showDialog(context: context, builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },);
    //try signing in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      //pop loading circle
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {

      //pop loading circle
      Navigator.of(context).pop();
      //WRONG EMAIL
      
      // Handle any other error (optional)
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.message ?? 'Something went wrong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    }

  
  




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
            MyTextfield(label: "Email", controller: emailController, obscureText: false,keyboardType: TextInputType.emailAddress,),
            const SizedBox(height: 25),
            //password
            MyTextfield(label: "Password", controller: passwordController, obscureText: true,keyboardType: TextInputType.text,),
            const SizedBox(height: 10),
            //forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(  
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text("forgot password?",style: TextStyle(color: Colors.blue),),
                ),
              ],
            ),
            const SizedBox(height: 25),
            //sign in button
            MyButton(onTap: () => signUserIn(context),text: "Sign In",),
            const SizedBox(height: 50),
            //or continue 
            Row(
              children: [
                Expanded
            (child: Divider(thickness: 0.5,color: Colors.grey[400],)
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text("Or continue with"),
            ),
            Expanded
            (child: Divider(thickness: 0.5,color: Colors.grey[400],)
            ),
            
            //google sign in  
           
           
            
            
          ],
        ),
        const SizedBox(height: 10,),
        //google sign in  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
                //google button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SquareTile(imagepath: 'lib/images/download_transparent.png',onTap: () => AuthService().signInWithGoogle(),),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SquareTile(imagepath: "lib/images/phone.png", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerify(),)),),
                  
                )
              ],
            ),
          const SizedBox(height: 50,),
        //not a member ? register now?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Not A Member",style: TextStyle(
                color: Colors.grey[700],
              ),),
              const SizedBox(width: 4,),
              GestureDetector(
                onTap:widget.onTap ,
                child: Text("Register Now",style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold
                ),),
              )
            ],
          )
      ]
      ),
    ));
  }
}