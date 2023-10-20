import 'package:crime_alert_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'background.dart';
import 'registration_page.dart';
import 'crime_reporting.dart';
import 'menu_bar.dart';


class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

   int _selectedIconIndex=1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 126, 128, 129),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Safe Zone',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 118, 117, 117)),
            ),
            const SizedBox(height: 40),
            const Text(
              'If you want to proceed to giving a report you witnessed, you must Login before proceeding',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Container(
              width: 600,
              height: 400,
              child: Card(
                elevation: 30,
                margin: const EdgeInsets.all(50),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Choose the way you want to log In',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          
                        },
                        child: const Text('Sign in with Google'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                     },
                    
                        child: const Text('Sign in with GitHub'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmailSignInPage()),
                          );
                        },
                        child: const Text('Sign in with Email'),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'If you have not registered yet, register now below',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 65,
        color: const Color.fromARGB(255, 244, 175, 118),
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





class EmailSignInPage extends StatefulWidget {
  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   int _selectedIconIndex=1;

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CrimeReportingPage()),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 126, 128, 129),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Safe Zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login with email',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 118, 117, 117)),
                ),


                
              const SizedBox(height: 20),
                
                Card(
                  elevation: 15, 
                  margin: const EdgeInsets.all(20), 
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 65,
        color: const Color.fromARGB(255, 244, 175, 118),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 0;
                });
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
    ),
    );
  }
}




