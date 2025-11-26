import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transfer_screen.dart';
import 'transaction_model.dart';
import 'auth_screen.dart';
import 'app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'financial_insight_engine.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  double _balance = 1000.0;
  bool _showFinancialHealth = false;
  double _financialHealthScore = 0.0; // Default score

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $error',
            style: AppTheme.subTextStyle,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<double> _calculateBalance() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 1000.0;

    try {
      final sentQuery = await _firestore
          .collection('transactions')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .get();

      final receivedQuery = await _firestore
          .collection('transactions')
          .where('toUserId', isEqualTo: currentUser.uid)
          .get();

      double totalSent = 0.0;
      double totalReceived = 0.0;

      for (final doc in sentQuery.docs) {
        final transaction = WalletTransaction.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        totalSent += transaction.amount;
      }

      for (final doc in receivedQuery.docs) {
        final transaction = WalletTransaction.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        totalReceived += transaction.amount;
      }

      return 1000.0 - totalSent + totalReceived;
    } catch (error) {
      print('Error calculating balance: $error');
      return 1000.0;
    }
  }

  // Add this to calculate financial data from transactions
Future<Map<String, dynamic>> _calculateFinancialData() async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) return {};

  try {
    final transactions = await _firestore
        .collection('transactions')
        .where(Filter.or(
          Filter('fromUserId', isEqualTo: currentUser.uid),
          Filter('toUserId', isEqualTo: currentUser.uid),
        ))
        .orderBy('timestamp', descending: true)
        .get();

    double totalReceived = 0.0;
    double totalSpent = 0.0;
    double largestTransaction = 0.0;
    double lastCredit = 0.0;
    List<double> dailySpending = [];
    int spendingSpikes = 0;
    
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    // Filter transactions for current month only
    final monthlyTransactions = transactions.docs.where((doc) {
      final transaction = WalletTransaction.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      return transaction.timestamp.isAfter(firstDayOfMonth);
    }).toList();

    if (monthlyTransactions.isEmpty) {
      return {
        'incomeTotal': 0.0,
        'spendingTotal': 0.0,
        'largestTransaction': 0.0,
        'lastCredit': 0.0,
        'dailyAverage': 0.0,
        'spendingSpikes': 0,
        'monthName': _getMonthName(now.month),
        'calculatedScore': 0.0, // Add this
      };
    }

    // Calculate metrics
    for (final doc in monthlyTransactions) {
      final transaction = WalletTransaction.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      
      final isSent = transaction.fromUserId == currentUser.uid;
      
      if (isSent) {
        totalSpent += transaction.amount;
        largestTransaction = max(largestTransaction, transaction.amount);
        dailySpending.add(transaction.amount);
      } else {
        totalReceived += transaction.amount;
        lastCredit = max(lastCredit, transaction.amount);
      }
    }

    // Calculate spending spikes (transactions > 2x average)
    if (dailySpending.isNotEmpty) {
      final averageSpend = totalSpent / dailySpending.length;
      spendingSpikes = dailySpending.where((amount) => amount > averageSpend * 2).length;
    }

    // Calculate actual financial health score
    double calculatedScore = 0.0;
    if (totalReceived > 0) {
      double surplus = totalReceived - totalSpent;
      calculatedScore = max((surplus / totalReceived) * 100, 0);
    }

    return {
      'incomeTotal': totalReceived,
      'spendingTotal': totalSpent,
      'largestTransaction': largestTransaction,
      'lastCredit': lastCredit,
      'dailyAverage': totalSpent / max(dailySpending.length, 1),
      'spendingSpikes': spendingSpikes,
      'monthName': _getMonthName(now.month),
      'calculatedScore': calculatedScore, // Add the actual calculated score
    };
  } catch (error) {
    print('Error calculating financial data: $error');
    return {};
  }
}

String _getMonthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month - 1];
}

  // 🔧 1. Simplified financial tier function — returns only first label
String _getFinancialHealthWord(double score) {
  if (score >= 80) return 'Prime';
  if (score >= 60) return 'Stable'; 
  if (score >= 40) return 'Fragile';
  return 'Critical';
}

Color _getTierColor(double score) {
  if (score >= 80) return Colors.green;
  if (score >= 60) return Colors.blue;
  if (score >= 40) return Colors.orange;
  return Colors.red;
}

  // 🔧 2. Simplified dropdown widget — only label, no numbers, no insights, no colors
// Update the financial health dropdown to show insights
Widget _buildFinancialHealthDropdown() {
  return AnimatedContainer(
    duration: Duration(milliseconds: 250),
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      border: Border.all(
        color: AppTheme.primaryColor.withOpacity(0.2),
      ),
    ),
    child: FutureBuilder<Map<String, dynamic>>(
      future: _calculateFinancialData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final financialData = snapshot.data!;
          final actualScore = financialData['calculatedScore'] ?? 0.0;
          
          // Update the state with the actual score
          if (_financialHealthScore != actualScore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _financialHealthScore = actualScore;
              });
            });
          }

          final engine = FinancialInsightEngine(
            incomeTotal: financialData['incomeTotal'] ?? 0.0,
            spendingTotal: financialData['spendingTotal'] ?? 0.0,
            largestTransaction: financialData['largestTransaction'] ?? 0.0,
            lastCredit: financialData['lastCredit'] ?? 0.0,
            dailyAverage: financialData['dailyAverage'] ?? 0.0,
            spendingSpikes: financialData['spendingSpikes'] ?? 0,
            monthName: financialData['monthName'] ?? 'this month',
          );

          final insight = engine.generateInsight();
          final label = _getFinancialHealthWord(actualScore);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '$label • ${actualScore.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _getTierColor(actualScore),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                insight,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.mainTextStyle.color,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LinearProgressIndicator(
                  value: actualScore / 100,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTierColor(actualScore)),
                ),
              ),
            ],
          );
        }

        return Center(
          child: Text(
            'No transaction data available for analysis',
            style: AppTheme.subTextStyle,
            textAlign: TextAlign.center,
          ),
        );
      },
    ),
  );
}

  @override
  void initState() {
    super.initState();
    _updateBalance();
  }

  Future<void> _updateBalance() async {
    final newBalance = await _calculateBalance();
    setState(() {
      _balance = newBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please log in',
                style: AppTheme.mainTextStyle,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                    (route) => false,
                  );
                },
                child: Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
        // In HomeScreen app bar, remove these actions:
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'WalletPaddi',
            style: AppTheme.mainTextStyle.copyWith(fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, size: 24),
              onPressed: () {
                _updateBalance();
              },
              tooltip: 'Refresh',
            ),
            // Remove the logout button from here
          ],
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card with Dropdown Toggle
            Container(
              margin: EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration,
              child: Column(
                children: [
                  // Main Balance Card
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current Balance',
                          style: AppTheme.subTextStyle.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 12),

                        // BALANCE WITH NORMAL FONT FOR ₦
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₦',
                                style: AppTheme.subTextStyle.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: null,
                                  color: AppTheme.balanceTextStyle.color,
                                ),
                              ),
                              TextSpan(
                                text: _balance.toStringAsFixed(2),
                                style: AppTheme.balanceTextStyle,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12),

                        // USERNAME BOLD
                        RichText(
                          text: TextSpan(
                            style: AppTheme.subTextStyle,
                            children: [
                              TextSpan(text: 'Welcome, '),
                              TextSpan(
                                text: '${currentUser.displayName ?? currentUser.email!.split('@')[0]}!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // 🔧 3. Dropdown toggle button (unchanged)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFinancialHealth = !_showFinancialHealth;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Financial Health',
                                  style: AppTheme.subTextStyle.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  _showFinancialHealth
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Financial Health Dropdown (simplified)
                  if (_showFinancialHealth) _buildFinancialHealthDropdown(),
                ],
              ),
            ),
          
            SizedBox(height: 28),
            
            // Transactions Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTheme.sectionHeaderTextStyle,
                  ),
                  Spacer(),
                  Icon(Icons.history, size: 24, color: AppTheme.primaryColor),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Transactions List
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('transactions')
                  .where(Filter.or(
                    Filter('fromUserId', isEqualTo: currentUser.uid),
                    Filter('toUserId', isEqualTo: currentUser.uid),
                  ))
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: AppTheme.gradientCardDecoration,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: AppTheme.mainTextStyle,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Make your first transfer!',
                                  style: AppTheme.subTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final transactions = snapshot.data!.docs.map((doc) {
                  return WalletTransaction.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                return ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isSent = transaction.fromUserId == currentUser.uid;
                    
                    return Container(
                      decoration: AppTheme.transactionCardDecoration,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSent 
                                ? AppTheme.errorColor.withOpacity(0.2)
                                : AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isSent ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isSent ? AppTheme.errorColor : AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          isSent
                              ? 'To: ${transaction.toUserName}'
                              : 'From: ${transaction.fromUserName}',
                          style: AppTheme.mainTextStyle,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              transaction.note,
                              style: AppTheme.subTextStyle,
                            ),
                            SizedBox(height: 6),
                            Text(
                              _formatDate(transaction.timestamp),
                              style: AppTheme.subTextStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₦${transaction.amount.toStringAsFixed(2)}',
                              style: AppTheme.transactionAmountTextStyle.copyWith(
                                color: isSent ? AppTheme.errorColor : AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSent 
                                    ? AppTheme.errorColor.withOpacity(0.15)
                                    : AppTheme.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isSent ? 'SENT' : 'RECEIVED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSent ? AppTheme.errorColor : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}