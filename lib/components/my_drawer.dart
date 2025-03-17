
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gig_connect/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //logo
          Column(
            children: [
              DrawerHeader(
                
                child: Icon(Icons.people_alt,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 40,)),
              //home list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title:  Text("H O M E",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  leading:  Icon(Icons.home,color: Theme.of(context).colorScheme.inversePrimary),
                  onTap: () {
                    //pop drawer
                    Navigator.pop(context);
                  },
                ),
              ),
              //settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title:  Text("S E T T I N G S",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  leading:  Icon(Icons.settings,color: Theme.of(context).colorScheme.inversePrimary),
                  onTap: () {
                    //pop drawer
                    Navigator.pop(context);
                    //navigate to settings page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
                  },
                ),
              ),
            ],
          ),
          //logout tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0,bottom: 25),
            child: ListTile(
              title:  Text("L O G O U T",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              leading:  Icon(Icons.logout,color: Theme.of(context).colorScheme.inversePrimary),
              onTap: () => signUserOut(),
            ),
          )
        ],
      ),
    );
  }
}