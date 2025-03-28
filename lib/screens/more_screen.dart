import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'More',
        showBikeSelector: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context, 
            'Motorcycles',
            [
              _buildMenuItem(
                context,
                'Bike Profiles',
                Icons.motorcycle,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bike profiles will be implemented in the next phase'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          _buildSection(
            context, 
            'Analytics',
            [
              _buildMenuItem(
                context,
                'Reports',
                Icons.bar_chart,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reports will be implemented in the next phase'),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Statistics',
                Icons.insert_chart,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statistics will be implemented in the next phase'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          _buildSection(
            context, 
            'Records',
            [
              _buildMenuItem(
                context,
                'Documents',
                Icons.description,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documents will be implemented in the next phase'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          _buildSection(
            context, 
            'Settings',
            [
              _buildMenuItem(
                context,
                'Preferences',
                Icons.settings,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences will be implemented in the next phase'),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Backup & Restore',
                Icons.backup,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup & Restore will be implemented in the next phase'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          _buildSection(
            context, 
            'About',
            [
              _buildMenuItem(
                context,
                'About App',
                Icons.info,
                () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Moto Tracker',
                    applicationVersion: '1.0.0',
                    applicationIcon: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.motorcycle,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    children: [
                      const Text(
                        'A motorcycle maintenance and fuel tracking app that helps riders monitor fuel economy, maintenance activities, and expenses.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}