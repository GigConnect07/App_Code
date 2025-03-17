
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:gig_connect/components/square_tile.dart';
import 'package:gig_connect/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  void Function()? onTap;
  RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controller
  final emailController=TextEditingController();

  final passwordController=TextEditingController();

  final confirmpasswordController=TextEditingController();

  void signUserUp(BuildContext context) async{
    //show loading circle
    showDialog(context: context, builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },);
    //try signing up
    try {
      //check if conform password and password are same
      if (passwordController.text == confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text,
        
      );
      }
      else{
        // pop loading circle
      Navigator.of(context).pop();
        // Show Password dont match error
        showErrorMessage("Passwords dont match!");
        return;
      }
      //pop loading circle
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {

      //pop loading circle
      Navigator.of(context).pop();
      //WRONG EMAIL OR PASSWORD
      
      showErrorMessage(e.message);
      
    }
    }

    //handle error message
    void showErrorMessage(String? message){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message ?? 'Something went wrong.'),
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
              child: Text("Lets Create an Account for You",
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),),
            ),
            const SizedBox(height: 25),
            //username 
            MyTextfield(label: "Email", controller: emailController, obscureText: false,keyboardType: TextInputType.emailAddress,),
            const SizedBox(height: 25),
            //password
            MyTextfield(label: "Password", controller: passwordController, obscureText: true,keyboardType: TextInputType.text,),
            const SizedBox(height: 25),
            //confirm password
            MyTextfield(label: "Confirm Password", controller: confirmpasswordController, obscureText: true,keyboardType: TextInputType.text,),
            const SizedBox(height: 10),
            
            const SizedBox(height: 25),
            //sign in button
            MyButton(onTap: () => signUserUp(context),text: "Sign Up",),
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
                SquareTile(imagepath: 'lib/images/download_transparent.png',onTap: () => AuthService().signInWithGoogle()),
                SquareTile(imagepath: "lib/images/phone.png", onTap: (){},)
              ],
            ),
          const SizedBox(height: 50,),
        //not a member ? register now?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account",style: TextStyle(
                color: Colors.grey[700],
              ),),
              const SizedBox(width: 4,),
              GestureDetector(
                onTap:widget.onTap ,
                child: Text("Login Now",style: TextStyle(
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