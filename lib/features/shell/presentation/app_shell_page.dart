import 'dart:io';

import 'package:flutter/material.dart';

import '../../dashboard/presentation/dashboard_page.dart';
import '../../daily_accomplishment/presentation/daily_accomplishment_page.dart';
import '../../monthly_reports/presentation/monthly_daily_accomplishment_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Daily Accomplishment',
    'Monthly Reports',
    'MPOR',
    'IPCR',
    'Tasks / Functions',
    'Employee Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildCurrentPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildApplicationHeader(),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavigationItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                ),
                _buildNavigationItem(
                  index: 1,
                  icon: Icons.calendar_month_outlined,
                  label: 'Daily Accomplishment',
                ),
                _buildNavigationItem(
                  index: 2,
                  icon: Icons.description_outlined,
                  label: 'Monthly Reports',
                ),
                _buildNavigationItem(
                  index: 3,
                  icon: Icons.bar_chart_outlined,
                  label: 'MPOR',
                ),
                _buildNavigationItem(
                  index: 4,
                  icon: Icons.fact_check_outlined,
                  label: 'IPCR',
                ),
                const Divider(height: 30),
                _buildNavigationItem(
                  index: 5,
                  icon: Icons.task_alt_outlined,
                  label: 'Tasks / Functions',
                ),
                _buildNavigationItem(
                  index: 6,
                  icon: Icons.person_outline,
                  label: 'Employee Profile',
                ),
              ],
            ),
          ),
          _buildExitButton(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Version 0.1.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assessment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'MPOR / IPCR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          selected: selected,
          selectedTileColor:
              Colors.indigo.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(
            icon,
            color: selected
                ? Colors.indigo
                : Colors.grey.shade700,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.indigo
                  : Colors.grey.shade800,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(
            Icons.exit_to_app_outlined,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Exit',
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
          onTap: _exitApplication,
        ),
      ),
    );
  }

  void _exitApplication() {
    exit(0);
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person_outline),
          ),
          const SizedBox(width: 10),
          const Text(
            'Employee',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();

      case 1:
        return const DailyAccomplishmentPage();

      case 2:
        return const MonthlyDailyAccomplishmentPage();

      case 3:
        return const _ComingSoonPage(
          title: 'MPOR',
          icon: Icons.bar_chart_outlined,
        );

      case 4:
        return const _ComingSoonPage(
          title: 'IPCR',
          icon: Icons.fact_check_outlined,
        );

      case 5:
        return const _ComingSoonPage(
          title: 'Tasks / Functions',
          icon: Icons.task_alt_outlined,
        );

      case 6:
        return const _ComingSoonPage(
          title: 'Employee Profile',
          icon: Icons.person_outline,
        );

      default:
        return const DashboardPage();
    }
  }
}

class _ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.indigo,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This module will be implemented next.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}