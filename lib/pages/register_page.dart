import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gig_connect/components/my_button.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/components/square_tile.dart';
import 'package:gig_connect/pages/ProfilePage.dart';
import 'package:gig_connect/pages/directing_page.dart';
import 'package:gig_connect/pages/home_page.dart';
import 'package:gig_connect/pages/phone_login.dart';
import 'package:gig_connect/services/auth_service.dart' show AuthService;

class RegisterFlow extends StatefulWidget {
  final void Function()? onLoginTap;
  const RegisterFlow({super.key, required this.onLoginTap});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  final PageController _pageController = PageController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final skillController = TextEditingController();
  final expController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  String? selectedAvailability;
  String? selectedRole;
  String? selectedSkill;
  final _formKey = GlobalKey<FormState>();


  void nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void signUserUp() async {
    if (!_formKey.currentState!.validate()) {
    return; // Validation failed, exit early
  }
  showDialog(
    context: context,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    if (passwordController.text == confirmpasswordController.text) {
      // Firebase Authentication me user create karna
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // User ID nikalna
      String uid = userCredential.user!.uid;

      // Firestore me user ka data store karna
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'role': selectedRole,
        'skills': selectedRole != "Worker" ? null : skillController.text,
        'experience': expController.text,
        'location': locationController.text,
        'availability': selectedAvailability,
        'created_at': FieldValue.serverTimestamp(),
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => DirectingPage(),));

    } else {
      Navigator.of(context).pop();
      showErrorMessage("Passwords don't match!");
    }
  } on FirebaseAuthException catch (e) {

    showErrorMessage(e.message);
  }
}


Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  } 

  return await Geolocator.getCurrentPosition();
}

Future<void> getCurrentLocation() async {
  try {
    Position position = await _determinePosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    
    Placemark place = placemarks[0];
    String address = "${place.locality}, ${place.administrativeArea}, ${place.country}";

    setState(() {
      locationController.text = address;
    });
  } catch (e) {
    showErrorMessage("Location error: $e");
  }
}

  void showErrorMessage(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message ?? 'Something went wrong.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            buildAskNamePage(),
            // Page 2 - Role & Experience
            buildRoleExperiencePage(),
            // Page 3 - Location & Availability
            buildLocationAvailabilityPage(),
            buildSignInMethod(),
            // Page 1 - Email & Password
            buildEmailPasswordPage(),
          ],
        ),
      ),
    );
  }

Widget buildSignInMethod(){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Sign in with", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 20),
      MyButton(onTap: nextPage, text: "Email and Password"),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SquareTile(imagepath: 'lib/images/download_transparent.png',onTap: () async {
            try {
              final userCred = await AuthService().signInWithGoogle();
              // Sign-in ke turant baad
              final user = userCred.user;
              final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);

              final docSnapshot = await userDoc.get();
              if (!docSnapshot.exists) {
                await userDoc.set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': selectedRole,
                  'skills': selectedRole != "Worker" ? null : skillController.text,
                  'experience': expController.text,
                  'location': locationController.text,
                  'availability': selectedAvailability,
                  'created_at': FieldValue.serverTimestamp(),
                });
              }

              if (userCred.user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const  DirectingPage()),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login failed: $e")),
              );
            }
}
),
          SquareTile(imagepath: "lib/images/phone.png", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerify(),)),),
        ]
      ),
      const SizedBox(height: 20,),
      MyButton(onTap: previousPage, text: "Previous")

    ]
  );
}
Widget buildAskNamePage() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text('Enter Your Name',style: TextStyle(fontSize: 32),),
        // const SizedBox(height: 10,),
        MyTextfield(label: "Full Name", controller: nameController, obscureText: false, keyboardType: TextInputType.name),
        const SizedBox(height: 25,),
        MyButton(onTap: nextPage, text: "Next"),
      ]
    )
  );
}
Widget buildEmailPasswordPage() {
  return Padding(
    
    padding: EdgeInsets.all(20),
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
              //logo  
              Center(child: const Icon(Icons.account_balance,size: 100,)),
              const SizedBox(height: 50),
              //welcome back
              Center(
                child: Text("Welcome To Our App",
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),),  
              ),
              const SizedBox(height: 25),
            MyTextfield(label: "Email", controller: emailController, obscureText: false, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 20),
            MyTextfield(
              label: "Phone Number", 
              controller: phoneController, 
              obscureText: false, 
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length != 10) {
                  return 'Please enter 10 digit phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            MyTextfield(label: "Password", controller: passwordController, obscureText: true, keyboardType: TextInputType.text),
            SizedBox(height: 20),
            MyTextfield(label: "Confirm Password", controller: confirmpasswordController, obscureText: true, keyboardType: TextInputType.text),
            SizedBox(height: 20),
            MyButton(onTap: signUserUp, text: "Sign Up"),
        
            // // Or continue
            // Row(
            //   children: [
            //     Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 25.0),
            //       child: Text("Or continue with"),
            //     ),
            //     Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
            //   ],
            // ),
            // const SizedBox(height: 10),
        
            // // Google Sign-In and Phone Sign-In
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SquareTile(imagepath: 'lib/images/download_transparent.png', onTap: () => AuthService().signInWithGoogle()),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SquareTile(imagepath: "lib/images/phone.png", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerify()))),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 50),
        
            // Not a member? Register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already A Member?", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onLoginTap,
                  child: Text("Login to Your Account", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildRoleExperiencePage() {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: InputDecoration(labelText: "Select Role", border: OutlineInputBorder()),
          items: ["Contractor", "Worker"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue;
              // Reset skills if role is changed
              selectedSkill = null;
              skillController.clear();
            });
          },
        ),
        SizedBox(height: 20),

        if (selectedRole == "Worker") ...[
          DropdownButtonFormField<String>(
            value: selectedSkill,
            decoration: InputDecoration(labelText: "Select Skill", border: OutlineInputBorder()),
            items: ["Labour", "Car Wash", "Mechanic", "Carpenter", "Painter", "Others"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSkill = newValue;
                if (newValue != "Others") {
                  skillController.text = newValue!;
                } else {
                  skillController.clear();
                }
              });
            },
          ),
          SizedBox(height: 20),

          // Show custom skill input only if "Others" is selected
          if (selectedSkill == "Others")
            MyTextfield(
              label: "Enter Your Skill",
              controller: skillController,
              obscureText: false,
              keyboardType: TextInputType.text,
            ),
        ],

        SizedBox(height: 20),
        MyTextfield(
          label: "Experience in years",
          controller: expController,
          obscureText: false,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyButton(onTap: previousPage, text: "Back"),
            MyButton(onTap: nextPage, text: "Next"),
          ],
        ),
      ],
    ),
  );
}


  Widget buildLocationAvailabilityPage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      MyTextfield(label: "Location", controller: locationController, obscureText: false, keyboardType: TextInputType.text),

    SizedBox(height: 10),

    ElevatedButton.icon(
      onPressed: getCurrentLocation,
      icon: Icon(Icons.my_location,color: Colors.blue[700],),
      label: Text("Use Current Location",style: TextStyle(color: Colors.blue[700]),),
      
    ),

          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedAvailability,
            decoration: InputDecoration(labelText: "Availability (Full-time/Part-time)", border: OutlineInputBorder()),
            items: ["Full-time", "Part-time"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedAvailability = newValue;
              });
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyButton(onTap: previousPage, text: "Back"),
              MyButton(onTap: nextPage, text: "Next"),
            ],
          ),
        ],
      ),
    );
  }
}