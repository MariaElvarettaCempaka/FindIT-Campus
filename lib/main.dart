import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'models/report_model.dart';
import 'services/report_service.dart';
import 'screens/post/post_report_screen.dart';
import 'screens/post/edit_report_screen.dart';

const Color primaryGreen = Color(0xFF17695D);
const Color backgroundColor = Color(0xFFFBF8F3);
const Color mainTextColor = Color(0xFF12312E);
const Color borderColor = Color(0xFFDEE8E2);
const Color dangerColor = Color(0xFFE0533C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FindITCampusApp());
}

class FindITCampusApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const FindITCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'FindIT Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email dan password wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user!;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        await userRef.set({
          'email': user.email ?? '',
          'nama': '',
          'fotoProfil': '',
          'nomorWhatsApp': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.update({'email': user.email ?? ''});
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Login gagal.');
    } on FirebaseException catch (e) {
      setState(() => _errorMessage = 'Gagal mengakses Firestore: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 70,
                  color: Color(0xFF218477),
                ),
                const SizedBox(height: 16),
                const Text(
                  'FindIT Campus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Temukan kembali barang yang hilang.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    ),
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        color: Color(0xFF218477),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gunakan akun yang sudah terdaftar di Firebase Authentication.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= FORGOT PASSWORD PAGE =================

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _emailSent = false;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      setState(() => _emailSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jika email terdaftar, tautan reset password akan dikirim. '
            'Periksa kotak masuk dan folder Spam.',
          ),
          backgroundColor: Color(0xFF218477),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'user-not-found':
          message = 'Email tersebut belum terdaftar.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak permintaan. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          message = 'Koneksi internet bermasalah. Periksa koneksi kamu.';
          break;
        default:
          message = e.message ?? 'Gagal mengirim tautan reset password.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFBDEBDD),
                      child: Icon(
                        Icons.mail_outline_rounded,
                        size: 55,
                        color: Color(0xFF173C38),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Lupa password?',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173C38),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Masukkan email yang kamu pakai saat mendaftar. '
                    'Kami akan mengirimkan tautan untuk mengatur ulang password.',
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    onSubmitted: (_) {
                      if (!_isLoading) _sendResetEmail();
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text('Kirim tautan reset'),
                    ),
                  ),
                  if (_emailSent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF3E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Permintaan reset password sudah diproses. '
                        'Periksa email dan folder Spam.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Text(
                    'Belum ada emailnya? Cek folder spam, atau coba kirim '
                    'ulang setelah beberapa saat.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke halaman masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= MAIN NAVIGATION =================

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  final ReportService _reportService = ReportService();

  final List<String> _titles = [
    'FindIT Campus',
    'Katalog Barang',
    'Notifikasi',
    'Profil Saya',
  ];

  Future<void> _openPostReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostReportScreen()),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(reportService: _reportService);
      case 1:
        return CatalogContent(reportService: _reportService);
      case 2:
        return const NotificationContent();
      case 3:
        return ProfileContent(onLogout: _logout, reportService: _reportService);
      default:
        return HomeContent(reportService: _reportService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              tooltip: 'Notifikasi',
              icon: const Icon(Icons.notifications_none),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
        ],
      ),
      body: _buildPage(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openPostReport,
              backgroundColor: const Color(0xFF218477),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Buat Laporan'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Katalog'),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ================= HOME =================

class HomeContent extends StatelessWidget {
  final ReportService reportService;

  const HomeContent({super.key, required this.reportService});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barang kembali.\nTemukan lagi.',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173C38),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Platform lost and found civitas akademika UNESA.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            'Laporan Terbaru',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ReportList(reportService: reportService),
        ],
      ),
    );
  }
}

// ================= KATALOG =================

class CatalogContent extends StatefulWidget {
  final ReportService reportService;

  const CatalogContent({super.key, required this.reportService});

  @override
  State<CatalogContent> createState() => _CatalogContentState();
}

class _CatalogContentState extends State<CatalogContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Elektronik',
    'Dompet',
    'Dokumen',
    'Aksesoris',
    'Pakaian',
    'Tas',
    'Kunci',
    'Lainnya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama barang...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category),
                  selected: category == _selectedCategory,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<ReportModel>>(
            stream: widget.reportService.getReports(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat katalog barang.'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final search = _searchController.text.toLowerCase();
              final reports = (snapshot.data ?? []).where((report) {
                final matchesName = report.namaBarang.toLowerCase().contains(
                  search,
                );
                final matchesCategory =
                    _selectedCategory == 'Semua' ||
                    report.kategori == _selectedCategory;
                return matchesName && matchesCategory;
              }).toList();

              if (reports.isEmpty) {
                return const Center(
                  child: Text('Belum ada barang yang ditemukan.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: reports.length,
                itemBuilder: (context, index) =>
                    ReportCard(report: reports[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= REPORT LIST =================

class ReportList extends StatelessWidget {
  final ReportService reportService;

  const ReportList({super.key, required this.reportService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: reportService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Gagal memuat laporan.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 35),
            child: Center(
              child: Text(
                'Belum ada laporan barang.\nSilakan buat laporan pertama.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: reports
              .take(10)
              .map((report) => ReportCard(report: report))
              .toList(),
        );
      },
    );
  }
}

// ================= REPORT IMAGE =================

class ReportImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double iconSize;
  final BoxFit fit;

  const ReportImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.iconSize = 40,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF218477).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: hasImage
          ? Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image_outlined,
                color: const Color(0xFF218477),
                size: iconSize,
              ),
            )
          : Icon(
              Icons.inventory_2_outlined,
              color: const Color(0xFF218477),
              size: iconSize,
            ),
    );
  }
}

// ================= REPORT CARD =================

class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isLost = report.jenisLaporan == 'Hilang';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportImage(
                imageUrl: report.fotoBarang,
                width: 75,
                height: 75,
                iconSize: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.namaBarang,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${report.kategori} • ${report.lokasi}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _ReportBadge(
                          label: report.jenisLaporan,
                          color: isLost
                              ? const Color(0xFFFFE1D9)
                              : const Color(0xFFD5F2E8),
                          textColor: isLost ? Colors.deepOrange : Colors.teal,
                        ),
                        _ReportBadge(
                          label: report.status,
                          color: report.status == 'Selesai'
                              ? const Color(0xFFD5F2E8)
                              : const Color(0xFFECEAE3),
                          textColor: report.status == 'Selesai'
                              ? const Color(0xFF218477)
                              : Colors.black87,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DETAIL LAPORAN =================

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ReportService _reportService = ReportService();

  bool _isDeleting = false;
  bool _isCompleting = false;

  bool get _isOwner {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.uid == widget.report.userId;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _relativeTime(dynamic timestamp) {
    if (timestamp is! Timestamp) return 'Waktu publikasi tidak tersedia';

    final difference = DateTime.now().difference(timestamp.toDate());
    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Diposting baru saja';
    }
    if (difference.inMinutes < 60) {
      return 'Diposting ${difference.inMinutes} menit lalu';
    }
    if (difference.inHours < 24) {
      return 'Diposting ${difference.inHours} jam lalu';
    }
    if (difference.inDays < 7) {
      return 'Diposting ${difference.inDays} hari lalu';
    }
    if (difference.inDays < 30) {
      return 'Diposting ${difference.inDays ~/ 7} minggu lalu';
    }
    if (difference.inDays < 365) {
      return 'Diposting ${difference.inDays ~/ 30} bulan lalu';
    }
    return 'Diposting ${difference.inDays ~/ 365} tahun lalu';
  }

  String _activeDays(dynamic timestamp) {
    if (timestamp is! Timestamp) return 'Belum tersedia';
    final days = DateTime.now().difference(timestamp.toDate()).inDays;
    return '${days + 1} hari';
  }

  String _normalizePhone(String phone) {
    var number = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    } else if (number.startsWith('8')) {
      number = '62$number';
    }
    return number;
  }

  void _openImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 35,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Future<void> _contactReporter(String phone, String reporterName) async {
    final number = _normalizePhone(phone);

    if (number.isEmpty || number.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nomor WhatsApp pelapor belum tersedia atau tidak valid.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Hubungi Pelapor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamu akan diarahkan ke WhatsApp untuk menghubungi '
                '${reporterName.isEmpty ? 'pelapor' : reporterName}.',
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F7F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, color: primaryGreen),
                    const SizedBox(width: 10),
                    Text(
                      phone,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  icon: const Icon(Icons.chat),
                  label: const Text('Lanjut ke WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final uri = Uri.parse('https://wa.me/$number');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp tidak dapat dibuka.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuka WhatsApp: $e')));
    }
  }

  Future<void> _editReport(ReportModel report) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditReportScreen(report: report)),
    );

    if (!mounted) return;
    if (result == true) Navigator.pop(context, true);
  }

  Future<void> _deleteReport(ReportModel report) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus laporan '
          '"${report.namaBarang}"?\n\n'
          'Laporan yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmation != true || !mounted) return;
    setState(() => _isDeleting = true);

    try {
      await _reportService.deleteReport(report.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus laporan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _markAsCompleted(ReportModel report) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Tandai Laporan Selesai?',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Color(0xFF173C38),
          ),
        ),
        content: Text(
          'Apakah laporan "${report.namaBarang}" sudah selesai ditangani '
          'dan barang sudah dikembalikan kepada pemilik?',
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF52615E),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF218477),
                      side: const BorderSide(color: Color(0xFF218477)),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ya, Selesai',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmation != true || !mounted) return;
    setState(() => _isCompleting = true);

    try {
      await _reportService.markReportAsCompleted(report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil ditandai selesai.'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menandai laporan selesai: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  Widget _reporterCard() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.report.userId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final name = data['nama']?.toString().trim() ?? '';
        final photo = data['fotoProfil']?.toString() ?? '';
        final phone = data['nomorWhatsApp']?.toString() ?? '';
        final displayName = name.isEmpty ? 'Pengguna FindIT' : name;

        return _sectionCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFD5F2E8),
                backgroundImage: photo.trim().isNotEmpty
                    ? NetworkImage(photo)
                    : null,
                child: photo.trim().isEmpty
                    ? const Icon(Icons.person, color: primaryGreen, size: 28)
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dilaporkan oleh',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (phone.trim().isEmpty &&
                  snapshot.connectionState != ConnectionState.waiting &&
                  !_isOwner)
                const Icon(Icons.info_outline, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _safetyGuideline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D5A9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFFB66B20), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Keamanan',
                  style: TextStyle(
                    color: Color(0xFF8B5118),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lakukan serah terima di area ber-CCTV '
                  '(Pos Satpam/Lobby). Hindari transfer uang tebusan '
                  'secara daring.',
                  style: TextStyle(color: Color(0xFF79552D), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownerInsights(dynamic createdAt) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _insightItem(
                'Dilihat',
                'Belum tersedia',
                Icons.visibility_outlined,
              ),
              _insightItem(
                'Respons',
                'Belum tersedia',
                Icons.chat_bubble_outline,
              ),
              _insightItem(
                'Aktif',
                _activeDays(createdAt),
                Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Data jumlah kunjungan dan respons belum tersedia pada sistem.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _insightItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: primaryGreen, size: 21),
          const SizedBox(height: 7),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .doc(widget.report.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat detail laporan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Laporan tidak ditemukan atau telah dihapus.'),
            );
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Data laporan tidak tersedia.'));
          }

          final report = ReportModel.fromMap(snapshot.data!.id, data);
          final isLost = report.jenisLaporan == 'Hilang';
          final isCompleted = report.status == 'Selesai';
          final createdAt = data['createdAt'];
          final custodyLocation = report.lokasiPenyimpanan?.trim() ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto utama dengan badge status.
                GestureDetector(
                  onTap: () => _openImage(report.fotoBarang),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          color: const Color(0xFFE8EFEB),
                          child: report.fotoBarang.trim().isEmpty
                              ? const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 75,
                                  color: primaryGreen,
                                )
                              : Image.network(
                                  report.fotoBarang,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 65,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _ReportBadge(
                          label: report.status,
                          color: isCompleted
                              ? const Color(0xFFD5F2E8)
                              : const Color(0xFFFFF0D9),
                          textColor: isCompleted
                              ? primaryGreen
                              : const Color(0xFF94601F),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  report.namaBarang,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ReportBadge(
                      label: report.jenisLaporan,
                      color: isLost
                          ? const Color(0xFFFFE1D9)
                          : const Color(0xFFD5F2E8),
                      textColor: isLost ? dangerColor : primaryGreen,
                    ),
                    _ReportBadge(
                      label: report.kategori,
                      color: const Color(0xFFEAF0ED),
                      textColor: mainTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _relativeTime(createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(report.tanggalKejadian),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Kartu profil pelapor.
                _reporterCard(),
                const SizedBox(height: 16),

                // Informasi selesai.
                if (isCompleted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF3E9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF9BD9C1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: primaryGreen),
                            SizedBox(width: 8),
                            Text(
                              'Laporan Selesai',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Barang telah dikembalikan kepada pemilik.',
                          style: TextStyle(color: primaryGreen, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanggal selesai: ${_formatDate(report.tanggalSelesai)}',
                          style: const TextStyle(
                            color: primaryGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Informasi utama.
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Barang',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _detailItem(
                        'Lokasi Kejadian',
                        report.lokasi,
                        Icons.location_on_outlined,
                      ),
                      if (!isLost)
                        _detailItem(
                          'Lokasi Penyimpanan',
                          custodyLocation.isEmpty
                              ? 'Belum ada informasi lokasi penyimpanan'
                              : custodyLocation,
                          Icons.place_outlined,
                        ),
                      _detailItem(
                        'Deskripsi',
                        report.deskripsi,
                        Icons.description_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _safetyGuideline(),
                const SizedBox(height: 16),

                _ownerInsights(createdAt),
                const SizedBox(height: 20),

                // Tombol pemilik laporan.
                if (_isOwner) ...[
                  if (!isCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isCompleting || _isDeleting
                            ? null
                            : () => _markAsCompleted(report),
                        icon: _isCompleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isCompleting ? 'Memproses...' : 'Tandai Selesai',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting || _isCompleting
                          ? null
                          : () => _editReport(report),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting || _isCompleting
                          ? null
                          : () => _deleteReport(report),
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _isDeleting ? 'Menghapus...' : 'Hapus Laporan',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dangerColor,
                        side: const BorderSide(color: dangerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _isOwner
          ? null
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.report.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Gagal membaca data pelapor: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Dokumen pengguna tidak ditemukan.'),
                  );
                }

                final userData = snapshot.data!.data() ?? {};
                final phone = userData['nomorWhatsApp']?.toString() ?? '';

                debugPrint('ID pelapor: ${widget.report.userId}');
                debugPrint('Data nomor WhatsApp: $phone');

                final validPhone = _normalizePhone(phone).length >= 10;

                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: validPhone
                            ? () => _contactReporter(
                                phone,
                                snapshot.data?.data()?['nama']?.toString() ??
                                    '',
                              )
                            : null,
                        icon: const Icon(Icons.chat),
                        label: Text(
                          validPhone
                              ? 'Hubungi via WhatsApp'
                              : 'Nomor WhatsApp belum tersedia',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ================= REPORT BADGE =================

class _ReportBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _ReportBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// ================= NOTIFICATIONS =================

class NotificationContent extends StatelessWidget {
  const NotificationContent({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp is! Timestamp) return 'Baru saja';
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }

  Future<void> _openNotification(BuildContext context, String reportId) async {
    try {
      await ReportService().markNotificationAsRead(reportId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui notifikasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Silakan login kembali.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, reportSnapshot) {
        if (reportSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Gagal memuat laporan: ${reportSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (reportSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = [...(reportSnapshot.data?.docs ?? [])];
        reports.sort((a, b) {
          final dateA = a.data()['createdAt'];
          final dateB = b.data()['createdAt'];
          final timeA = dateA is Timestamp ? dateA.millisecondsSinceEpoch : 0;
          final timeB = dateB is Timestamp ? dateB.millisecondsSinceEpoch : 0;
          return timeB.compareTo(timeA);
        });

        if (reports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 65, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada notifikasi.'),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ReportService().getNotificationReads(),
          builder: (context, readSnapshot) {
            if (readSnapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat status notifikasi: '
                  '${readSnapshot.error}',
                ),
              );
            }
            if (readSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final readReports = <String>{};
            for (final readDoc in readSnapshot.data?.docs ?? []) {
              final readData = readDoc.data();
              if (readData['isRead'] == true) {
                final reportId = readData['reportId']?.toString();
                if (reportId != null) readReports.add(reportId);
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final data = report.data();
                final reportId = report.id;
                final jenis = data['jenisLaporan']?.toString() ?? 'Laporan';
                final namaBarang = data['namaBarang']?.toString() ?? 'Barang';
                final lokasi = data['lokasi']?.toString() ?? '';
                final isHilang = jenis.toLowerCase() == 'hilang';
                final isRead = readReports.contains(reportId);
                final judul = isHilang
                    ? 'Laporan Barang Hilang Baru'
                    : 'Laporan Barang Ditemukan Baru';
                final pesan = isHilang
                    ? 'Ada laporan barang hilang: $namaBarang di $lokasi.'
                    : 'Ada laporan barang ditemukan: $namaBarang di $lokasi.';

                return Card(
                  color: isRead ? Colors.white : const Color(0xFFE6F4F0),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _openNotification(context, reportId),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFD5F2E8),
                      child: Icon(
                        isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: const Color(0xFF218477),
                      ),
                    ),
                    title: Text(
                      judul,
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(pesan),
                        const SizedBox(height: 7),
                        Text(
                          _formatDate(data['createdAt']),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        if (!isRead)
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'Belum dibaca',
                              style: TextStyle(
                                color: Color(0xFF218477),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: isRead
                        ? const Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey,
                          )
                        : const Icon(
                            Icons.circle,
                            color: Color(0xFF218477),
                            size: 12,
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ================= PROFILE =================

class ProfileContent extends StatelessWidget {
  final Future<void> Function() onLogout;
  final ReportService reportService;

  const ProfileContent({
    super.key,
    required this.onLogout,
    required this.reportService,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Pengguna tidak ditemukan.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final nama = data['nama']?.toString() ?? '';
        final email = user.email ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFD5F2E8),
                child: Icon(Icons.person, size: 55, color: Color(0xFF218477)),
              ),
              const SizedBox(height: 16),
              Text(
                nama.isEmpty ? 'Pengguna FindIT' : nama,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(email),
              const SizedBox(height: 30),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Nama'),
                      subtitle: Text(nama.isEmpty ? 'Belum diisi' : nama),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Nomor WhatsApp'),
                      subtitle: Text(
                        data['nomorWhatsApp']?.toString().isNotEmpty == true
                            ? data['nomorWhatsApp'].toString()
                            : 'Belum diisi',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD5F2E8),
                    child: Icon(Icons.history, color: Color(0xFF218477)),
                  ),
                  title: const Text(
                    'Riwayat Laporan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Lihat laporan barang yang pernah dibuat',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportHistoryScreen(reportService: reportService),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= RIWAYAT LAPORAN =================

class ReportHistoryScreen extends StatelessWidget {
  final ReportService reportService;

  const ReportHistoryScreen({super.key, required this.reportService});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Riwayat Laporan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF218477),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF218477),
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Barang Hilang'),
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Barang Ditemukan',
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<ReportModel>>(
          stream: reportService.getMyReports(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat riwayat laporan.\n'
                    'Periksa koneksi internet dan akses Firestore.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF218477)),
              );
            }

            final List<ReportModel> sortedReports = List<ReportModel>.from(
              snapshot.data ?? <ReportModel>[],
            );

            sortedReports.sort(
              (a, b) => b.tanggalKejadian.compareTo(a.tanggalKejadian),
            );

            final List<ReportModel> lostReports = sortedReports
                .where((r) => r.jenisLaporan.toLowerCase() == 'hilang')
                .toList();

            final List<ReportModel> foundReports = sortedReports
                .where((r) => r.jenisLaporan.toLowerCase() == 'ditemukan')
                .toList();

            return TabBarView(
              children: [
                _HistoryReportList(
                  reports: lostReports,
                  emptyMessage:
                      'Kamu belum pernah membuat laporan barang hilang.',
                ),
                _HistoryReportList(
                  reports: foundReports,
                  emptyMessage:
                      'Kamu belum pernah membuat laporan barang ditemukan.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ================= DAFTAR RIWAYAT =================

class _HistoryReportList extends StatelessWidget {
  final List<ReportModel> reports;
  final String emptyMessage;

  const _HistoryReportList({required this.reports, required this.emptyMessage});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, size: 65, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final isLost = report.jenisLaporan.toLowerCase() == 'hilang';
        final isCompleted = report.status == 'Selesai';

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(report: report),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReportImage(
                        imageUrl: report.fotoBarang,
                        width: 85,
                        height: 85,
                        iconSize: 35,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.namaBarang,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173C38),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              report.kategori,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    report.lokasi,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(report.tanggalKejadian),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      _ReportBadge(
                        label: report.jenisLaporan,
                        color: isLost
                            ? const Color(0xFFFFE1D9)
                            : const Color(0xFFD5F2E8),
                        textColor: isLost ? Colors.deepOrange : Colors.teal,
                      ),
                      const SizedBox(width: 6),
                      _ReportBadge(
                        label: report.status,
                        color: isCompleted
                            ? const Color(0xFFD5F2E8)
                            : const Color(0xFFECEAE3),
                        textColor: isCompleted
                            ? const Color(0xFF218477)
                            : Colors.black87,
                      ),
                    ],
                  ),
                  if (isCompleted && report.tanggalSelesai != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Color(0xFF218477),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Selesai pada ${_formatDate(report.tanggalSelesai!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF218477),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Lihat detail',
                      style: TextStyle(
                        color: Color(0xFF218477),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
