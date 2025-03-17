import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_drawer.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});
  final User = FirebaseAuth.instance.currentUser!;
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        title: Text('Home Page',style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
        ),
        drawer: MyDrawer(),
      body: Center(child: Text("Logged In as : ${User.email}",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary))
    ));
  }
}