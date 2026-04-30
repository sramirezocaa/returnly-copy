import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    usernameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await user.updateDisplayName(usernameController.text.trim());
      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update username: $e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await user.updatePassword(passwordController.text.trim());

      passwordController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update password. You may need to log out and log back in. $e',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.settings_outlined,
                  size: 45,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.email ?? 'No email',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : updateUsername,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Update Username'),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : updatePassword,
                  icon: const Icon(Icons.password_outlined),
                  label: const Text('Update Password'),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 25),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}