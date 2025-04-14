import 'package:final5/screens/profile_screen.dart';
import 'package:flutter/material.dart';

abstract class WorkerCard extends StatelessWidget {
  final Map<String, dynamic> worker;
  final Function(Map<String, dynamic>) onSelectWorker;
  final Function(Map<String, dynamic>) onSendOffer;

  const WorkerCard({
    Key? key,
    required this.worker,
    required this.onSelectWorker,
    required this.onSendOffer,
  });