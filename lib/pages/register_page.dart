import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gig_connect/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gig_connect/components/square_tile.dart';
import 'package:gig_connect/pages/directing_page.dart';
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
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

        // If user is a worker, create worker profile
        if (selectedRole == "Worker") {
          await FirebaseFirestore.instance
              .collection('worker_profiles')
              .doc(uid)
              .set({
            'uid': uid,
            'username': nameController.text,
            'role': skillController.text,
            'personalInfo': 'No personal info provided yet.',
            'skills': skillController.text,
            'workHistory': 'No work history provided yet.',
            'experience': expController.text,
            'location': locationController.text,
            'availability': selectedAvailability,
          });
        }

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DirectingPage(),
            ));
      } else {
        Navigator.of(context).pop();
        showErrorMessage("Passwords don't match!");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String address =
          "${place.locality}, ${place.administrativeArea}, ${place.country}";

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
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: buildAskNamePage(),
              ),
              SingleChildScrollView(
                child: buildRoleExperiencePage(),
              ),
              SingleChildScrollView(
                child: buildLocationAvailabilityPage(),
              ),
              SingleChildScrollView(
                child: buildSignInMethod(),
              ),
              buildEmailPasswordPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAskNamePage() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add,
              size: 80,
              color: Colors.purple.shade800,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Create Your Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Let's get started with your name",
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 30),
          Form(
            key: _formKey,
            child: MyTextfield(
              label: "Full Name",
              controller: nameController,
              obscureText: false,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: widget.onLoginTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.purple.shade800, width: 2),
                    ),
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      nextPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRoleExperiencePage() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work,
              size: 80,
              color: Colors.purple.shade800,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Your Role & Experience",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tell us about your professional background",
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 30),
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              labelText: "Select Role",
              labelStyle: TextStyle(color: Colors.purple.shade800),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800, width: 2),
              ),
            ),
            items: ["Contractor", "Worker"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRole = newValue;
                selectedSkill = null;
                skillController.clear();
              });
            },
          ),
          SizedBox(height: 20),
          if (selectedRole == "Worker") ...[
            DropdownButtonFormField<String>(
              value: selectedSkill,
              decoration: InputDecoration(
                labelText: "Select Skill",
                labelStyle: TextStyle(color: Colors.purple.shade800),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.purple.shade800),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.purple.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      BorderSide(color: Colors.purple.shade800, width: 2),
                ),
              ),
              items: [
                "Labour",
                "Car Wash",
                "Mechanic",
                "Carpenter",
                "Painter",
                "Others"
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
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
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.purple.shade800, width: 2),
                    ),
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLocationAvailabilityPage() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              size: 80,
              color: Colors.purple.shade800,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Location & Availability",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tell us where and when you're available",
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 30),
          MyTextfield(
            label: "Location",
            controller: locationController,
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: getCurrentLocation,
            icon: Icon(
              Icons.my_location,
              color: Colors.purple.shade800,
            ),
            label: Text(
              "Use Current Location",
              style: TextStyle(color: Colors.purple.shade800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.purple.shade800, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedAvailability,
            decoration: InputDecoration(
              labelText: "Availability (Full-time/Part-time)",
              labelStyle: TextStyle(color: Colors.purple.shade800),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.purple.shade800, width: 2),
              ),
            ),
            items: ["Full-time", "Part-time"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedAvailability = newValue;
              });
            },
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.purple.shade800, width: 2),
                    ),
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSignInMethod() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.purple.shade800,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Choose Sign In Method",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Select how you want to sign in",
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Email and Password",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SquareTile(
            imagepath: 'lib/images/download_transparent.png',
            onTap: () async {
              try {
                final userCred = await AuthService().signInWithGoogle();
                final user = userCred.user;
                final userDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid);

                final docSnapshot = await userDoc.get();
                if (!docSnapshot.exists) {
                  await userDoc.set({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'skills':
                        selectedRole != "Worker" ? null : skillController.text,
                    'experience': expController.text,
                    'location': locationController.text,
                    'availability': selectedAvailability,
                    'created_at': FieldValue.serverTimestamp(),
                  });

                  if (selectedRole == "Worker") {
                    await FirebaseFirestore.instance
                        .collection('worker_profiles')
                        .doc(user.uid)
                        .set({
                      'uid': user.uid,
                      'username': nameController.text,
                      'role': skillController.text,
                      'personalInfo': 'No personal info provided yet.',
                      'skills': skillController.text,
                      'workHistory': 'No work history provided yet.',
                      'experience': expController.text,
                      'location': locationController.text,
                      'availability': selectedAvailability,
                    });
                  }
                }

                if (userCred.user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DirectingPage()),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login failed: $e")),
                );
              }
            },
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: previousPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.purple.shade800, width: 2),
                ),
              ),
              child: Text(
                "Previous",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailPasswordPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Create Your Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Set up your account security",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple.shade700,
                ),
              ),
              SizedBox(height: 30),
              MyTextfield(
                label: "Email",
                controller: emailController,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
              ),
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
              MyTextfield(
                label: "Password",
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              MyTextfield(
                label: "Confirm Password",
                controller: confirmpasswordController,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signUserUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already A Member?",
                    style: TextStyle(color: Colors.purple.shade700),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onLoginTap,
                    child: Text(
                      "Login to Your Account",
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
