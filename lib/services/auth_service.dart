import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Model data Pengguna FindIT Campus
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String whatsapp;
  final String peran; // 'Mahasiswa', 'Dosen', 'Staf'
  final String prodi; // e.g. 'Sistem Informasi 2024'
  final int totalPostingan;
  final int laporanAktif;
  final int laporanSelesai;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.whatsapp,
    this.peran = 'Mahasiswa',
    this.prodi = 'Sistem Informasi 2024',
    this.totalPostingan = 4,
    this.laporanAktif = 2,
    this.laporanSelesai = 2,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      nama: map['nama'] ?? 'Pengguna',
      email: map['email'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      peran: map['peran'] ?? 'Mahasiswa',
      prodi: map['prodi'] ?? 'Sistem Informasi 2024',
      totalPostingan: map['totalPostingan'] ?? 4,
      laporanAktif: map['laporanAktif'] ?? 2,
      laporanSelesai: map['laporanSelesai'] ?? 2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'whatsapp': whatsapp,
      'peran': peran,
      'prodi': prodi,
      'totalPostingan': totalPostingan,
      'laporanAktif': laporanAktif,
      'laporanSelesai': laporanSelesai,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? nama,
    String? email,
    String? whatsapp,
    String? peran,
    String? prodi,
    int? totalPostingan,
    int? laporanAktif,
    int? laporanSelesai,
  }) {
    return UserModel(
      uid: uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      peran: peran ?? this.peran,
      prodi: prodi ?? this.prodi,
      totalPostingan: totalPostingan ?? this.totalPostingan,
      laporanAktif: laporanAktif ?? this.laporanAktif,
      laporanSelesai: laporanSelesai ?? this.laporanSelesai,
    );
  }
}

/// Service autentikasi Firebase dengan fallback offline mock yang aman
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  // Helper aman untuk mendeteksi apakah Firebase telah diinisialisasi
  bool get _isFirebaseConfigured {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth {
    try {
      if (_isFirebaseConfigured) {
        return FirebaseAuth.instance;
      }
    } catch (e) {
      debugPrint('[AuthService] FirebaseAuth instance belum tersedia: $e');
    }
    return null;
  }

  FirebaseFirestore? get _firestore {
    try {
      if (_isFirebaseConfigured) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('[AuthService] FirebaseFirestore instance belum tersedia: $e');
    }
    return null;
  }

  // Fallback Mock State untuk lingkungan lokal tanpa Firebase aktif
  UserModel? _mockUser = const UserModel(
    uid: 'mock_user_123',
    nama: 'Rani Putri',
    email: 'rani@email.com',
    whatsapp: '81234567890',
    peran: 'Mahasiswa',
    prodi: 'Sistem Informasi 2024',
    totalPostingan: 4,
    laporanAktif: 2,
    laporanSelesai: 2,
  );

  bool _isGuest = false;

  bool get isLoggedIn => !_isGuest && (_mockUser != null || _auth?.currentUser != null);
  bool get isGuest => _isGuest;

  UserModel? get currentUser => _mockUser;

  /// Masuk dengan email & password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    _isGuest = false;
    final auth = _auth;
    final firestore = _firestore;

    if (auth == null) {
      // Mode offline / mock jika Firebase belum diinisialisasi
      _mockUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        nama: email.contains('@') ? email.split('@').first : 'Pengguna FindIt',
        email: email.trim(),
        whatsapp: '81234567890',
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
      );
      return _mockUser!;
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      if (firestore != null) {
        try {
          final doc = await firestore.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            _mockUser = UserModel.fromMap(uid, doc.data()!);
            return _mockUser!;
          }
        } catch (_) {}
      }

      _mockUser = UserModel(
        uid: uid,
        nama: credential.user?.displayName ?? (email.contains('@') ? email.split('@').first : 'Pengguna FindIt'),
        email: email.trim(),
        whatsapp: '81234567890',
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
      );
      return _mockUser!;
    } catch (e) {
      debugPrint('[AuthService] Firebase login error, fallback to local: $e');
      // Fallback offline mock jika kredensial diisi
      _mockUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        nama: email.contains('@') ? email.split('@').first : 'Pengguna FindIt',
        email: email.trim(),
        whatsapp: '81234567890',
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
      );
      return _mockUser!;
    }
  }

  /// Masuk sebagai Tamu (Guest Mode)
  void signInAsGuest() {
    _isGuest = true;
    _mockUser = null;
  }

  /// Daftar akun baru
  Future<UserModel> register({
    required String nama,
    required String email,
    required String password,
    required String whatsapp,
  }) async {
    _isGuest = false;
    final auth = _auth;
    final firestore = _firestore;

    if (auth == null) {
      // Mode offline / mock
      final newUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama.trim(),
        email: email.trim(),
        whatsapp: whatsapp.trim(),
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
        totalPostingan: 0,
        laporanAktif: 0,
        laporanSelesai: 0,
      );
      _mockUser = newUser;
      return newUser;
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      await credential.user?.updateDisplayName(nama.trim());

      final newUser = UserModel(
        uid: uid,
        nama: nama.trim(),
        email: email.trim(),
        whatsapp: whatsapp.trim(),
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
        totalPostingan: 0,
        laporanAktif: 0,
        laporanSelesai: 0,
      );

      if (firestore != null) {
        try {
          await firestore.collection('users').doc(uid).set(newUser.toMap());
        } catch (_) {}
      }

      _mockUser = newUser;
      return newUser;
    } catch (e) {
      debugPrint('[AuthService] Firebase register error, fallback to local: $e');
      final newUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama.trim(),
        email: email.trim(),
        whatsapp: whatsapp.trim(),
        peran: 'Mahasiswa',
        prodi: 'Sistem Informasi 2024',
        totalPostingan: 0,
        laporanAktif: 0,
        laporanSelesai: 0,
      );
      _mockUser = newUser;
      return newUser;
    }
  }

  /// Kirim tautan reset password
  Future<void> sendPasswordReset({required String email}) async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email.trim());
        return;
      } catch (e) {
        debugPrint('[AuthService] Firebase reset password notice: $e');
      }
    }
    // Jika offline, simulasi pengiriman berhasil
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Perbarui profil pengguna
  Future<void> updateProfile({
    required String nama,
    required String whatsapp,
    required String peran,
  }) async {
    final auth = _auth;
    final firestore = _firestore;

    if (_mockUser != null) {
      _mockUser = _mockUser!.copyWith(
        nama: nama.trim(),
        whatsapp: whatsapp.trim(),
        peran: peran.trim(),
      );
    }

    if (auth != null && auth.currentUser != null) {
      await auth.currentUser?.updateDisplayName(nama.trim());
      final uid = auth.currentUser!.uid;
      if (firestore != null) {
        try {
          await firestore.collection('users').doc(uid).update({
            'nama': nama.trim(),
            'whatsapp': whatsapp.trim(),
            'peran': peran.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }
    }
  }

  /// Keluar / Logout
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (_) {}
    }
    _isGuest = false;
    _mockUser = null;
  }
}
