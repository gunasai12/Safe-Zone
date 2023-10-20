import 'package:crime_alert_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication_page.dart'; 
import 'background.dart';
import 'menu_bar.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _selectedIconIndex=1;

  String emailFormatError = '';
  String passwordFormatError = '';
  String registrationError = '';

  void register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    setState(() {
      emailFormatError = '';
      passwordFormatError = '';
      registrationError = '';
    });

   
    if (!_isValidEmail(email)) {
      setState(() {
        emailFormatError = 'Invalid email format.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        passwordFormatError = 'Password must be at least 6 characters long.';
      });
      return;
    }

    if (password == confirmPassword) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

       
        await userCredential.user!.sendEmailVerification();

      
        if (userCredential.user != null) {
       
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Successful'),
                content: Text('A verification email has been sent to your email address. '
                    'Please check your email and verify your account.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the success dialog
                      _auth.signOut(); // Sign out the user until verification

                      // Navigate to the authentication_page.dart after successful registration
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => AuthenticationPage()),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print("Error registering user: $e");
        // Handle registration errors
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          setState(() {
            registrationError = 'This email is already registered.';
          });
        } else {
          setState(() {
            registrationError = 'An error occurred during registration. Please try again later.';
          });
        }
      }
    } else {
      // Passwords do not match, show an error
      setState(() {
        registrationError = 'Passwords do not match.';
      });
    }
  }

  bool _isValidEmail(String email) {
    // Simple email format validation using a regular expression
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 126, 128, 129),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Safe Zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Registration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 118, 117, 117)),
                ),
                
              SizedBox(height: 20),
                
                Card(
                  elevation: 15, // Adjust the elevation as needed
                  margin: EdgeInsets.all(20), // Adjust the margin as needed
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Username'),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        if (emailFormatError.isNotEmpty)
                          Text(
                            emailFormatError,
                            style: TextStyle(color: Colors.red),
                          ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                        if (passwordFormatError.isNotEmpty)
                          Text(
                            passwordFormatError,
                            style: TextStyle(color: Colors.red),
                          ),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Confirm Password'),
                        ),
                        if (registrationError.isNotEmpty)
                          Text(
                            registrationError,
                            style: TextStyle(color: Colors.red),
                          ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            register();
                          },
                          child: Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
                // End of Registration Form Card
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 65,
        color: Color.fromARGB(255, 244, 175, 118),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconIndex = 0;
                  });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomMenuBar()),
              );

                },
              child: Icon(
                Icons.menu,
                color: _selectedIconIndex == 0 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 1;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthenticationPage()),
                );
              },
              child: Icon(
                Icons.report,
                color: _selectedIconIndex == 1 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 2;
                });
              },
              child: Icon(
                Icons.map,
                color: _selectedIconIndex == 2 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Icon(
                Icons.home,
                color: _selectedIconIndex == 3 ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}