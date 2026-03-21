import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final profile = context.read<AppProvider>().profile;
      if (profile != null) {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _selectedGender = profile.gender;
        _selectedAvatar = profile.avatarIndex;
      }
    }
  }

  final List<Map<String, dynamic>> _genders = [
    {'label': 'Male', 'icon': Icons.male},
    {'label': 'Female', 'icon': Icons.female},
    {'label': 'Other', 'icon': Icons.people},
    {'label': 'Skip', 'icon': Icons.block},
  ];

  final List<Map<String, dynamic>> _avatars = [
    {'label': 'Scholar', 'icon': Icons.school, 'color': Color(0xFF2962FF)},
    {'label': 'Coder', 'icon': Icons.code, 'color': Color(0xFF00C853)},
    {'label': 'Artist', 'icon': Icons.palette, 'color': Color(0xFFFF6D00)},
    {'label': 'Gamer', 'icon': Icons.sports_esports, 'color': Color(0xFF7C4DFF)},
    {'label': 'Scientist', 'icon': Icons.science, 'color': Color(0xFFE91E63)},
    {'label': 'Explorer', 'icon': Icons.explore, 'color': Color(0xFF00BCD4)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: age,
      gender: _selectedGender,
      avatarIndex: _selectedAvatar,
    );

    context.read<AppProvider>().saveProfile(profile);
    if (widget.isEditing) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set Up Profile',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step 1 of 3',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('33%',
                      style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.33,
                  backgroundColor: AppTheme.cardBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),

              // Welcome
              Text(
                'Welcome, Scholar!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Let's customize your learning experience.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Personal Details
              Text('PERSONAL DETAILS',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 16),

              Text('Full Name', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              Text('Age', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'How old are you?',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Gender
              Text('GENDER',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _genders.map((g) {
                  final isSelected = _selectedGender == g['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGender = g['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: (MediaQuery.of(context).size.width - 60) / 2,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(g['icon'] as IconData,
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textSecondary,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            g['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Avatar selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CHOOSE AVATAR',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final a = _avatars[index];
                    final isSelected = _selectedAvatar == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = index),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: (a['color'] as Color)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            a['icon'] as IconData,
                            color: a['color'] as Color,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Create Profile button
              ElevatedButton(
                onPressed: _createProfile,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create Profile'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
