import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Kutubxona'),
        actions: [
          IconButton(
            onPressed: () {
              // Add music functionality
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 80,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Kutubxona bo\'sh',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Musiqalarni qo\'shish uchun + tugmasini bosing',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
