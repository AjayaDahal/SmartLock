import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartlock/login-page.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showErrorSnackBarGreen(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _signup() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User ${userCredential.user?.uid} signed up.');
      showErrorSnackBarGreen(context, 'Sign up successful!');
      // Navigate to the login page or any other page in your app.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(email: _emailController.text),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up: ${e.message}');
      showErrorSnackBar(context, 'An error occurred!');
      // Show an error message to the user.
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth!.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      print('User ${userCredential.user?.uid} signed up with Google.');
      // Navigate to the home page or any other page in your app.
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up with Google: ${e.message}');
      // Show an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _signUpWithGoogle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.jpeg',
                      height: 24,
                    ),
                    SizedBox(width: 10),
                    Text('Sign up with Google'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
