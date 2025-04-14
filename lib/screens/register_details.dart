// // screens/registration_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';
//
// class RegistrationScreen extends StatefulWidget {
//   final bool isRecruiter;
//   const RegistrationScreen({super.key, required this.isRecruiter});
//
//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   final PageController _pageController = PageController();
//   late AnimationController _animationController;
//   final _formKey = GlobalKey<FormState>();
//
//   int _currentStep = 1;
//   Map<String, List<String>> _selectedSkills = {};
//   List<String> _cities = ['Mumbai', 'Thane', 'Navi Mumbai'];
//   String? _selectedCity;
//
//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _pinCodeController = TextEditingController();
//   final TextEditingController _businessController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//
//   final Map<String, List<String>> _workerSkills = {
//     'Electrician': ['Residential Wiring', 'Commercial Installations', 'Circuit Repairs'],
//     'Welder': ['Arc Welding', 'MIG Welding', 'TIG Welding'],
//     'Plumber': ['Pipe Installation', 'Fixture Repair', 'Drain Clearing'],
//     'Carpenter': ['Framing', 'Cabinetry', 'Finish Work'],
//     'Machine Operator': ['CNC Operation', 'Lathe Operation', 'Milling'],
//     'HVAC Technician': ['Installation', 'Maintenance', 'Repair'],
//     'Painter': ['Interior Painting', 'Exterior Painting', 'Surface Preparation'],
//     'Roofer': ['Shingle Installation', 'Metal Roofing', 'Roof Repair'],
//     'Mason': ['Bricklaying', 'Stonework', 'Concrete Finishing'],
//     'General Contractor': ['Project Management', 'Cost Estimation', 'Subcontractor Coordination'],
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _animationController.forward();
//   }
//
//   Future<void> _register() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final originalEmail = _emailController.text;
//         final uniqueEmail = '${originalEmail.split('@')[0]}+${DateTime.now().millisecondsSinceEpoch}@${originalEmail.split('@')[1]}';
//
//         UserCredential user = await _auth.createUserWithEmailAndPassword(
//           email: uniqueEmail,
//           password: _passwordController.text,
//         );
//
//         final userData = GigUser(
//           uid: user.user!.uid,
//           name: _nameController.text,
//           email: originalEmail,
//           authEmail: originalEmail,
//           createdAt: DateTime.now(),
//           skills: _selectedSkills,
//           userType: widget.isRecruiter ? 'recruiter' : 'worker',
//           phone: _phoneController.text,
//           city: _selectedCity!,
//           pinCode: _pinCodeController.text,
//         );
//
//         await _firestore.collection('users').doc(user.user!.uid).set(userData.toMap());
//
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, '/home');
//         }
//       } on FirebaseAuthException catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? 'Registration failed')),
//           );
//         }
//       }
//     }
//   }
//
//   Widget _buildStep1() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _animationController.value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - _animationController.value) * 20),
//             child: child,
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email Address'),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                     return 'Invalid email format';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: 'Phone Number'),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
//                     return 'Invalid phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _selectedCity,
//                 decoration: const InputDecoration(labelText: 'City'),
//                 items: _cities.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 validator: (value) => value == null ? 'Please select a city' : null,
//                 onChanged: (newValue) {
//                   setState(() => _selectedCity = newValue);
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _pinCodeController,
//                 decoration: const InputDecoration(labelText: 'Pin Code'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
//                     return 'Invalid 6-digit pin code';
//                   }
//                   return null;
//                 },
//               ),
//               if (widget.isRecruiter) ...[
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _businessController,
//                   decoration: const InputDecoration(labelText: 'Business Name'),
//                 ),
//               ],
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   if (value.length < 6) return 'Minimum 6 characters';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: const InputDecoration(labelText: 'Confirm Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Required';
//                   if (value != _passwordController.text) return 'Passwords do not match';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _pageController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFBA55D3),
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: const Text('Next'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStep2() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _animationController.value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - _animationController.value) * 20),
//             child: child,
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text(
//               'Types of Workers Needed',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView(
//                 children: _workerSkills.keys.map((type) {
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 10),
//                     child: ExpansionTile(
//                       title: Row(
//                         children: [
//                           Text(type),
//                           if (_selectedSkills[type]?.isNotEmpty ?? false)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: Chip(
//                                 label: Text('${_selectedSkills[type]?.length ?? 0}'),
//                                 backgroundColor: Colors.purple.withOpacity(0.1),
//                               ),
//                             ),
//                         ],
//                       ),
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Column(
//                             children: _workerSkills[type]!.map((skill) {
//                               return CheckboxListTile(
//                                 title: Text(skill),
//                                 value: _selectedSkills[type]?.contains(skill) ?? false,
//                                 onChanged: (selected) {
//                                   setState(() {
//                                     _selectedSkills.update(
//                                       type,
//                                           (skills) => selected!
//                                           ? [...skills, skill]
//                                           : skills..remove(skill),
//                                       ifAbsent: () => selected! ? [skill] : [],
//                                     );
//                                   });
//                                 },
//                                 controlAffinity: ListTileControlAffinity.leading,
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _register,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFBA55D3),
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               child: const Text('Create Account'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Step $_currentStep/2'),
//         backgroundColor: const Color(0xFFBA55D3),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => _pageController.previousPage(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           ),
//         ),
//       ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         onPageChanged: (step) {
//           setState(() => _currentStep = step + 1);
//           _animationController.reset();
//           _animationController.forward();
//         },
//         children: [
//           _buildStep1(),
//           if (widget.isRecruiter) _buildStep2(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }