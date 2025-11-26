import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!_isLogin && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your name',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'displayName': _nameController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await userCredential.user!.updateDisplayName(_nameController.text);
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Header
              _buildHeader(),
              SizedBox(height: 40),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: AppTheme.mainTextStyle.copyWith(fontSize: 24),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isLogin 
                            ? 'Sign in to your WalletPaddi account'
                            : 'Create your WalletPaddi account',
                        style: AppTheme.subTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: AppTheme.gradientCardDecoration,
                        child: Column(
                          children: [
                            if (!_isLogin)
                              Column(
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name *',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email *',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),
                            
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password *',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 24),
                            
                            _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  )
                                : ElevatedButton(
                                    onPressed: _submit,
                                    child: Text(_isLogin ? 'Sign In' : 'Create Account'),
                                  ),
                            
                            SizedBox(height: 16),
                            
                            TextButton(
                              onPressed: () {
                                setState(() => _isLogin = !_isLogin);
                              },
                              child: Text(
                                _isLogin 
                                    ? 'Don\'t have an account? Sign Up' 
                                    : 'Already have an account? Sign In',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: AppTheme.onPrimaryColor,
            size: 48,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'WalletPaddi',
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your Digital Wallet',
          style: AppTheme.subTextStyle.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}