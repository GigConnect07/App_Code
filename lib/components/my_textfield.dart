import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String label;
  final controller;
  final bool obscureText;
  final TextInputType keyboardType;
  const MyTextfield({super.key,required this.label,required this.controller,required this.obscureText,required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,focusColor: Colors.grey[400],
                  enabledBorder : OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700)
                  ),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400),),
                  
                ),

              ),
            );
  }
}