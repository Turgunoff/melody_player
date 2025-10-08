import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('Umumiy', [
            _buildSettingsTile(
              icon: Icons.palette,
              title: 'Mavzu',
              subtitle: 'Qorong\'i',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Til',
              subtitle: 'O\'zbekcha',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.volume_up,
              title: 'Ovoz balandligi',
              subtitle: '50%',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          _buildSettingsSection('Musiqa', [
            _buildSettingsTile(
              icon: Icons.repeat,
              title: 'Takrorlash',
              subtitle: 'Yo\'q',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.shuffle,
              title: 'Tasodifiy',
              subtitle: 'Yo\'q',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.equalizer,
              title: 'Ekvalayzer',
              subtitle: 'O\'chirilgan',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          _buildSettingsSection('Ilova haqida', [
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Versiya',
              subtitle: '1.0.0',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.help,
              title: 'Yordam',
              subtitle: '',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Maxfiylik siyosati',
              subtitle: '',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
