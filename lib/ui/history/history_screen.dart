import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 24,
                      color: Color(0xFF141414),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 48),
                      child: const Text(
                        'Savings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141414),
                          fontFamily: 'Public Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Account Info Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.grey[300],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User Info
                        Column(
                          children: const [
                            Text(
                              'Ethan Carter',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF141414),
                                fontFamily: 'Public Sans',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Savings account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF737373),
                                fontFamily: 'Public Sans',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$1,234.56',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF737373),
                                fontFamily: 'Public Sans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDBDBDB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Total expenses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              fontFamily: 'Public Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$234.56',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF141414),
                              fontFamily: 'Public Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDBDBDB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Total income',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              fontFamily: 'Public Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$1,469.12',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF141414),
                              fontFamily: 'Public Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Transactions Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Recent transactions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                  fontFamily: 'Public Sans',
                ),
              ),
            ),

            // Transactions List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTransactionItem(
                    name: 'To Liam',
                    type: 'Transfer',
                    amount: '-\$100.00',
                    color: Colors.blue,
                  ),
                  _buildTransactionItem(
                    name: 'From Sophia',
                    type: 'Transfer',
                    amount: '+\$200.00',
                    color: Colors.green,
                  ),
                  _buildTransactionItem(
                    name: 'To Noah',
                    type: 'Transfer',
                    amount: '-\$50.00',
                    color: Colors.orange,
                  ),
                  _buildTransactionItem(
                    name: 'From Olivia',
                    type: 'Transfer',
                    amount: '+\$150.00',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF141414),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Deposit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Public Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEDEDED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Withdraw',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF141414),
                            fontFamily: 'Public Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEDEDED),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: false,
                  ),
                  _buildNavItem(
                    icon: Icons.savings_outlined,
                    label: 'Savings',
                    isActive: true,
                  ),
                  _buildNavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transactions',
                    isActive: false,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isActive: false,
                  ),
                ],
              ),
            ),

            // Bottom spacing
            Container(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String name,
    required String type,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.person,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141414),
                      fontFamily: 'Public Sans',
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF737373),
                      fontFamily: 'Public Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF141414),
              fontFamily: 'Public Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            color: isActive ? Colors.transparent : Colors.transparent,
          ),
          child: Column(
            children: [
              Container(
                height: 32,
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? const Color(0xFF141414) : const Color(0xFF737373),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? const Color(0xFF141414) : const Color(0xFF737373),
                  fontFamily: 'Public Sans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}