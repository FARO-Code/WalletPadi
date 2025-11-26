import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_model.dart';
import 'app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _recipientName;
  String? _recipientId;

  Future<void> _validateRecipient() async {
    if (_emailController.text.isEmpty) return;

    try {
      final recipientQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (recipientQuery.docs.isNotEmpty) {
        final recipientDoc = recipientQuery.docs.first;
        final recipientData = recipientDoc.data();
        setState(() {
          _recipientName = recipientData['displayName'] ?? 'User';
          _recipientId = recipientDoc.id;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User found: $_recipientName',
              style: AppTheme.subTextStyle,
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        setState(() {
          _recipientName = null;
          _recipientId = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No user found with this email',
              style: AppTheme.subTextStyle,
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _recipientName = null;
        _recipientId = null;
      });
    }
  }

  Future<void> _transferMoney() async {
    if (_amountController.text.isEmpty || _emailController.text.isEmpty) {
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

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid amount',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_recipientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please validate the recipient email first',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final currentUser = _auth.currentUser!;
    if (currentUser.uid == _recipientId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot transfer money to yourself',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = WalletTransaction(
        id: '',
        fromUserId: currentUser.uid,
        fromUserName: currentUser.displayName ?? currentUser.email!.split('@')[0],
        toUserId: _recipientId!,
        toUserName: _recipientName!,
        amount: amount,
        note: _noteController.text.isNotEmpty ? _noteController.text : 'Money Transfer',
        timestamp: DateTime.now(),
      );

      await _firestore.collection('transactions').add(transaction.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer successful!',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      _amountController.clear();
      _noteController.clear();
      _emailController.clear();
      setState(() {
        _recipientName = null;
        _recipientId = null;
      });

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer failed: $error',
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
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Transfer Money',
          style: AppTheme.mainTextStyle.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Money',
                style: AppTheme.mainTextStyle.copyWith(fontSize: 28),
              ),
              SizedBox(height: 8),
              Text(
                'Transfer money to another WalletPaddi user',
                style: AppTheme.subTextStyle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 32),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: AppTheme.gradientCardDecoration,
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Recipient's Email *",
                            prefixIcon: Icon(Icons.email),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: _validateRecipient,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              _recipientName = null;
                              _recipientId = null;
                            });
                          },
                        ),
                        
                        if (_recipientName != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: AppTheme.successDecoration,
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'User found: $_recipientName',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 20),
                        TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount *',
                            prefixIcon: Icon(Icons.attach_money),
                            prefixText: '₦',
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                        
                        SizedBox(height: 20),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Note (optional)',
                            prefixIcon: Icon(Icons.note),
                            hintText: 'Add a note (optional)',
                          ),
                          maxLines: 2,
                        ),
                        
                        SizedBox(height: 32),
                        _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              )
                            : ElevatedButton(
                                onPressed: _transferMoney,
                                child: Text('Transfer Money'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}