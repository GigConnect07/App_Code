import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  void Function()? onTap;
  final String imagepath;
  SquareTile({super.key,required this.imagepath,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200]
        ),
        child: Image.asset(imagepath,height: 70,),
      ),
    );
  }
}