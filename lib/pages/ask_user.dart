import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/pages/home_page.dart';
import 'package:gig_connect/pages/login_or_register_page.dart';
import 'package:gig_connect/pages/login_page.dart';
import 'package:gig_connect/pages/register_page.dart';

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Select User Type'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            
            MyButton(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterFlow(onLoginTap: () => HomePage())),
              );
            }, text: "New User!"),
            MyButton(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(onTap: () => HomePage())),
              );
            }, text: "Existing User!")
            // ElevatedButton(
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            //     textStyle: TextStyle(fontSize: 24),
            //   ),
            //   child: Text('New User'),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            //     textStyle: TextStyle(fontSize: 24),
            //   ),
            //   child: Text('Existing User'),
            // ),
          ],
        ),
      ),
    );
  }
}