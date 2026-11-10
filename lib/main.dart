
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      scrollBehavior:
          const MaterialScrollBehavior().copyWith(scrollbars: false),
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
      setState(() {
        _errorMessage = 'Email dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
        await userRef.update({
          'email': user.email ?? '',
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Login gagal.';
      });
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengakses Firestore: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        color: Color(0xFF218477),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
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
      backgroundColor: const Color(0xFFFAF8F3),
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
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBDEBDD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                    ),
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
                    autocorrect: false,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF218477),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim tautan reset',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF218477)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Permintaan reset password sudah diproses. '
                              'Periksa email dan folder Spam.',
                              style: TextStyle(color: Color(0xFF173C38)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF218477)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Belum ada emailnya? Cek folder spam, '
                            'atau coba kirim ulang setelah beberapa saat.',
                            style: TextStyle(
                              color: Color(0xFF173C38),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali ke halaman masuk',
                      style: TextStyle(
                        color: Color(0xFF218477),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
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
      MaterialPageRoute(
        builder: (_) => const PostReportScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
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
        return ProfileContent(
          onLogout: _logout,
          reportService: _reportService,
        );
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
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
        ],
      ),
      body: _buildPage(),
      floatingActionButton:
          _selectedIndex == 0 || _selectedIndex == 1
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
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Katalog',
          ),
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

  const HomeContent({
    super.key,
    required this.reportService,
  });

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
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
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

  const CatalogContent({
    super.key,
    required this.reportService,
  });

  @override
  State<CatalogContent> createState() => _CatalogContentState();
}

class _CatalogContentState extends State<CatalogContent> {
  final TextEditingController _searchController =
      TextEditingController();

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
            onChanged: (_) {
              setState(() {});
            },
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
              final selected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
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

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final search =
                  _searchController.text.toLowerCase();

              final reports = (snapshot.data ?? []).where((report) {
                final matchesName =
                    report.namaBarang.toLowerCase().contains(search);

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
                itemBuilder: (context, index) {
                  return ReportCard(report: reports[index]);
                },
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

  const ReportList({
    super.key,
    required this.reportService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: reportService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Gagal memuat laporan.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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
          children: reports.take(10).map((report) {
            return ReportCard(report: report);
          }).toList(),
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
      decoration: BoxDecoration(
        color: const Color(0xFF218477).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image_outlined,
                  color: const Color(0xFF218477),
                  size: iconSize,
                );
              },
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

  const ReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = report.jenisLaporan == 'Hilang';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(
                report: report,
              ),
            ),
          );
        },
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
                fit: BoxFit.cover,
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
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
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
                          textColor: isLost
                              ? Colors.deepOrange
                              : Colors.teal,
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
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
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

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() =>
      _ReportDetailScreenState();
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
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget _detailItem(
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF218477),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
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

  // ================= EDIT LAPORAN =================

  Future<void> _editReport(ReportModel report) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditReportScreen(
          report: report,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  // ================= HAPUS LAPORAN =================

  Future<void> _deleteReport(ReportModel report) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Laporan?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus laporan '
            '"${report.namaBarang}"?\n\n'
            'Laporan yang dihapus tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

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
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ================= TANDAI SELESAI =================

  Future<void> _markAsCompleted(ReportModel report) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tandai Laporan Selesai?'),
          content: Text(
            'Apakah laporan "${report.namaBarang}" '
            'sudah selesai ditangani dan barang sudah '
            'dikembalikan kepada pemilik?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF218477),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Selesai'),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      await _reportService.markReportAsCompleted(report.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil ditandai selesai.'),
          backgroundColor: Color(0xFF218477),
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
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  // ================= DETAIL BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
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
            return const Center(
              child: Text('Gagal memuat detail laporan.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Laporan tidak ditemukan atau telah dihapus.'),
            );
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return const Center(
              child: Text('Data laporan tidak tersedia.'),
            );
          }

          final report = ReportModel.fromMap(
            snapshot.data!.id,
            data,
          );

          final isLost = report.jenisLaporan == 'Hilang';
          final isCompleted = report.status == 'Selesai';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ReportImage(
                            imageUrl: report.fotoBarang,
                            width: double.infinity,
                            height: 230,
                            iconSize: 75,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            report.namaBarang,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173C38),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _ReportBadge(
                                label: report.jenisLaporan,
                                color: isLost
                                    ? const Color(0xFFFFE1D9)
                                    : const Color(0xFFD5F2E8),
                                textColor: isLost
                                    ? Colors.deepOrange
                                    : Colors.teal,
                              ),
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
                        ),
                        const SizedBox(height: 20),

                        // Informasi ketika laporan sudah selesai.
                        if (isCompleted) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF3E9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF9BD9C1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF218477),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Laporan Selesai',
                                        style: TextStyle(
                                          color: Color(0xFF176B5D),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Barang telah dikembalikan kepada pemilik.',
                                  style: TextStyle(
                                    color: Color(0xFF176B5D),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tanggal selesai: '
                                  '${_formatDate(report.tanggalSelesai)}',
                                  style: const TextStyle(
                                    color: Color(0xFF176B5D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        const Divider(),
                        const SizedBox(height: 16),
                        _detailItem(
                          'Kategori',
                          report.kategori,
                          Icons.category_outlined,
                        ),
                        _detailItem(
                          'Jenis Laporan',
                          report.jenisLaporan,
                          Icons.assignment_outlined,
                        ),
                        _detailItem(
                          'Lokasi',
                          report.lokasi,
                          Icons.location_on_outlined,
                        ),
                        _detailItem(
                          'Deskripsi',
                          report.deskripsi,
                          Icons.description_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol pemilik laporan.
                if (_isOwner) ...[
                  // Tombol Tandai Selesai hanya muncul jika belum selesai.
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
                          _isCompleting
                              ? 'Memproses...'
                              : 'Tandai Selesai',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF218477),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Edit tetap tersedia meskipun status sudah Selesai.
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
                        backgroundColor: const Color(0xFF218477),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hapus tetap tersedia meskipun status sudah Selesai.
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _isDeleting ? 'Menghapus...' : 'Hapus Laporan',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF218477),
                    ),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
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
    if (timestamp is! Timestamp) {
      return 'Baru saja';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  Future<void> _openNotification(
    BuildContext context,
    String reportId,
  ) async {
    try {
      await ReportService().markNotificationAsRead(reportId);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui notifikasi: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login kembali.'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .snapshots(),
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

        if (reportSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = [
          ...(reportSnapshot.data?.docs ?? []),
        ];

        reports.sort((a, b) {
          final dateA = a.data()['createdAt'];
          final dateB = b.data()['createdAt'];

          final timeA = dateA is Timestamp
              ? dateA.millisecondsSinceEpoch
              : 0;

          final timeB = dateB is Timestamp
              ? dateB.millisecondsSinceEpoch
              : 0;

          return timeB.compareTo(timeA);
        });

        if (reports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 65,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text('Belum ada notifikasi.'),
              ],
            ),
          );
        }

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
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

            if (readSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final readReports = <String>{};

            for (final readDoc
                in readSnapshot.data?.docs ?? []) {
              final readData = readDoc.data();

              if (readData['isRead'] == true) {
                final reportId =
                    readData['reportId']?.toString();

                if (reportId != null) {
                  readReports.add(reportId);
                }
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final data = report.data();

                final reportId = report.id;
                final jenis =
                    data['jenisLaporan']?.toString() ??
                    'Laporan';

                final namaBarang =
                    data['namaBarang']?.toString() ??
                    'Barang';

                final lokasi =
                    data['lokasi']?.toString() ?? '';

                final isHilang =
                    jenis.toLowerCase() == 'hilang';

                final isRead =
                    readReports.contains(reportId);

                final judul = isHilang
                    ? 'Laporan Barang Hilang Baru'
                    : 'Laporan Barang Ditemukan Baru';

                final pesan = isHilang
                    ? 'Ada laporan barang hilang: '
                        '$namaBarang di $lokasi.'
                    : 'Ada laporan barang ditemukan: '
                        '$namaBarang di $lokasi.';

                return Card(
                  color: isRead
                      ? Colors.white
                      : const Color(0xFFE6F4F0),
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    onTap: () {
                      _openNotification(
                        context,
                        reportId,
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFFD5F2E8),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
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
      return const Center(
        child: Text('Pengguna tidak ditemukan.'),
      );
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
                child: Icon(
                  Icons.person,
                  size: 55,
                  color: Color(0xFF218477),
                ),
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
                      subtitle: Text(
                        nama.isEmpty ? 'Belum diisi' : nama,
                      ),
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
                        data['nomorWhatsApp']?.toString().isNotEmpty ==
                                true
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
                    child: Icon(
                      Icons.history,
                      color: Color(0xFF218477),
                    ),
                  ),
                  title: const Text(
                    'Riwayat Laporan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Lihat laporan barang yang pernah dibuat',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportHistoryScreen(
                          reportService: reportService,
                        ),
                      ),
                    );
                  },
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
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

  const ReportHistoryScreen({
    super.key,
    required this.reportService,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
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
              Tab(
                icon: Icon(Icons.search),
                text: 'Barang Hilang',
              ),
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
                child: CircularProgressIndicator(
                  color: Color(0xFF218477),
                ),
              );
            }

            final allReports = snapshot.data ?? [];

            final sortedReports = [...allReports]
              ..sort(
                (a, b) => b.tanggalKejadian.compareTo(
                  a.tanggalKejadian,
                ),
              );

            final lostReports = sortedReports
                .where(
                  (report) =>
                      report.jenisLaporan.toLowerCase() == 'hilang',
                )
                .toList();

            final foundReports = sortedReports
                .where(
                  (report) =>
                      report.jenisLaporan.toLowerCase() ==
                      'ditemukan',
                )
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

  const _HistoryReportList({
    required this.reports,
    required this.emptyMessage,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
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
              const Icon(
                Icons.history,
                size: 65,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
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

        final isLost =
            report.jenisLaporan.toLowerCase() == 'hilang';

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(
                    report: report,
                  ),
                ),
              );
            },
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
                        fit: BoxFit.cover,
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
                        textColor: isLost
                            ? Colors.deepOrange
                            : Colors.teal,
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
                          'Selesai pada '
                          '${_formatDate(report.tanggalSelesai!)}',
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
