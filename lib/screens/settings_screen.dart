import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../provider/theme_provider.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_font.dart';

/// Enhancement 2: user preferences (light/dark mode) + Sign Out.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await LocalStorageService.clearSession();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final textColor = primaryTextColor(context);

    return Scaffold(
      backgroundColor: bgColor(context),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          CustomFont(
            text: 'Preferences',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: FB_DARK_PRIMARY,
          ).withPadding(),

          SwitchListTile(
            title: Text('Dark Mode', style: TextStyle(color: textColor)),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark mode is on'
                  : 'Light mode is on',
              style: TextStyle(color: secondaryTextColor(context)),
            ),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: FB_DARK_PRIMARY,
            ),
            value: themeProvider.isDarkMode,
            activeColor: FB_DARK_PRIMARY,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),

          Divider(color: secondaryTextColor(context)),

          CustomFont(
            text: 'Account',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: FB_DARK_PRIMARY,
          ).withPadding(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}

extension _PaddedFont on Widget {
  Widget withPadding() =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: this);
}
