import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/components/my_drawer.dart';
import 'package:gig_connect/pages/ProfilePage.dart';

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
        title: Center(child: Text('Worker Page',style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),)),
        actions: [IconButton(onPressed:() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),)), icon: Icon(Icons.person))],
        
        ),
        drawer: MyDrawer(),
      body: Center(child: Text("Logged In as : ${User.email}",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary))
    ));
  }
}