import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/zhspk_viewmodel.dart';

class ZhspkCreatePage extends ConsumerStatefulWidget {
  const ZhspkCreatePage({super.key});

  @override
  ConsumerState<ZhspkCreatePage> createState() => _ZhspkCreatePageState();
}

class _ZhspkCreatePageState extends ConsumerState<ZhspkCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _zhspkNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController();

  @override
  void dispose() {
    _zhspkNameController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('New ZHSPK'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ZHSPK Information section
            Text(
              'ZHSPK Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // ZHSPK Name field - required
            TextFormField(
              controller: _zhspkNameController,
              decoration: const InputDecoration(
                labelText: 'ZHSPK Name',
                hintText: 'Enter ZHSPK name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ZHSPK name is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Chairman Information section
            Text(
              'Chairman Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Last Name field - required
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter last name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Last name is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // First Name field - required
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter first name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Patronymic field - optional
            TextFormField(
              controller: _patronymicController,
              decoration: const InputDecoration(
                labelText: 'Patronymic',
                hintText: 'Enter patronymic (optional)',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submitForm,
            child: const Text('Create'),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final zhspkName = _zhspkNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final firstName = _firstNameController.text.trim();
      final patronymic = _patronymicController.text.trim();

      try {
        print('=== НАЧАЛО ФОРМЫ ===');

        // Create ZHSPK and get ID
        print('1. Создаем ZHSPK...');
        final String zhspkId = await ref
            .read(zhspkViewModelProvider.notifier)
            .createZhspk(zhspkName);
        print('2. ZHSPK создан, ID: $zhspkId');

        // Create chair person and get credentials
        print('3. Начинаем создание председателя...');
        print('   Параметры: zhspkId=25, lastName=$lastName, firstName=$firstName');

        final Map<String, String> credentials = await ref
            .read(zhspkViewModelProvider.notifier)
            .createChairPerson(
          '25',
          lastName,
          firstName,
        );

        print('4. Председатель создан, credentials: $credentials');

        if (mounted) {
          _showCredentialsDialog(
            context,
            login: credentials['login'] ?? credentials['Login'] ?? '',
            password: credentials['password'] ?? credentials['Password'] ?? '',
          );
        }
      } catch (e, stackTrace) {
        print('!!! ОШИБКА: $e');
        print('StackTrace: $stackTrace');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showCredentialsDialog(
      BuildContext context, {
        required String login,
        required String password,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false, // Must tap Done to close
      builder: (context) => AlertDialog(
        title: const Text('Access Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save these credentials. The password cannot be recovered.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Login field
            _CredentialField(
              label: 'Login',
              value: login,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Password field
            _CredentialField(
              label: 'Password',
              value: password,
              colorScheme: colorScheme,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close create page
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Helper widget for credential display
class _CredentialField extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final bool isPassword;

  const _CredentialField({
    required this.label,
    required this.value,
    required this.colorScheme,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // Copy to clipboard
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
              );
            },
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }
}