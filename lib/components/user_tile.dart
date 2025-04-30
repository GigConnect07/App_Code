import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  UserTile({super.key,required this.text,required this.onTap});
  final String text;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            //icon
            Icon(Icons.account_circle,color: Theme.of(context).colorScheme.inversePrimary),
            SizedBox(width: 10),
            //username
            Text(text,style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary))
          ],
        )
      ),
    );
  }
}