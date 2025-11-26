import 'package:flutter/material.dart';
import 'app_theme.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: AppTheme.mainTextStyle.copyWith(fontSize: 20),
        ),
      ),
      body: Center(
        child: Text(
          'Full transaction history coming soon...',
          style: AppTheme.subTextStyle,
        ),
      ),
    );
  }
}