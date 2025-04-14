// // screens/role_selection_screen.dart
// import 'package:final5/screens/register_details.dart';
// import 'package:flutter/material.dart';
// import 'register_details.dart';
//
// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.work, size: 80, color: Color(0xFFBA55D3)),
//             const SizedBox(height: 20),
//             const Text('Welcome to Gig-Connect',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 40),
//             _buildRoleCard(context, 'Worker'),
//             const SizedBox(height: 20),
//             _buildRoleCard(context, 'Recruiter'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRoleCard(BuildContext context, String title) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(15),
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => RegistrationScreen(isRecruiter: title == 'Recruiter'),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Icon(
//                 title == 'Worker' ? Icons.person : Icons.business,
//                 size: 40,
//                 color: const Color(0xFFBA55D3),
//               ),
//               const SizedBox(width: 20),
//               Text(title, style: const TextStyle(fontSize: 20)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }