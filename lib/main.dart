import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'core/app_dimens.dart';
import 'core/app_theme.dart';
import 'widgets/app_button.dart';
import 'widgets/status_chip.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FindITCampusApp());
}

class FindITCampusApp extends StatelessWidget {
  const FindITCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindIT Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const DesignSystemShowcase(),
    );
  }
}

/// Tampilan preview untuk menguji fondasi desain, warna, tombol, dan chip.
class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Dompet', 'HP', 'Kunci', 'Tas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FindIT Campus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenInset,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Barang kembali.\nTemukan lagi.',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Platform lost and found civitas akademika UNESA.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Search Bar Placeholder
            Container(
              height: AppDimens.searchBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimens.radius99),
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: AppDimens.borderDefaultStroke,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.slate600),
                  SizedBox(width: 10),
                  Text(
                    'Cari nama barang...',
                    style: TextStyle(color: AppColors.slate600, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            const Text(
              'Kategori Filter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryFilterChip(
                      label: _filters[index],
                      isSelected: _selectedFilterIndex == index,
                      onTap: () => setState(() => _selectedFilterIndex = index),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Status Chips
            const Text(
              'Status Badge',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                StatusChip.lost(),
                SizedBox(width: 10),
                StatusChip.found(),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol-tombol Design System
            const Text(
              'Tombol Design System',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Lanjut (Primary)',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton.secondary(
              label: 'Edit (Secondary)',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton.lost(
              label: 'Laporkan Hilang',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton.whatsapp(
              label: 'Hubungi via WhatsApp',
              onPressed: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
