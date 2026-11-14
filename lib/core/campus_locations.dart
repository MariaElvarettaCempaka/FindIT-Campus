/// Master Data Lokasi & Hotspot Kampus UNESA (Ketintang & Lidah Wetan)
/// Digunakan untuk Smart Autocomplete, Tagging Kampus, dan Filter Laporan.
class CampusLocation {
  final String id;
  final String name;
  final String campus; // 'Ketintang' atau 'Lidah Wetan'
  final String area;
  final List<String> keywords;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.campus,
    required this.area,
    this.keywords = const [],
  });
}

/// Daftar Master Hotspot Kampus UNESA
const List<CampusLocation> unesaCampusLocations = [
  // --- KAMPUS KETINTANG ---
  CampusLocation(
    id: 'ft_e1',
    name: 'Gedung E1 Fakultas Teknik (FT)',
    campus: 'Ketintang',
    area: 'Fakultas Teknik • Area Kuliah & Dosen',
    keywords: ['ft', 'teknik', 'e1', 'dekanat ft', 'mesin', 'sipil', 'elektro', 'informatika'],
  ),
  CampusLocation(
    id: 'ft_e11_lab',
    name: 'Gedung E11 Lab Komputer & Multimedia FT',
    campus: 'Ketintang',
    area: 'Fakultas Teknik • Ruang Praktikum Lab',
    keywords: ['lab', 'komputer', 'e11', 'multimedia', 'jaringan', 'ti'],
  ),
  CampusLocation(
    id: 'perpus_ketintang',
    name: 'Perpustakaan Pusat UNESA Ketintang',
    campus: 'Ketintang',
    area: 'Gedung Perpustakaan, Lt. 1 & 2',
    keywords: ['perpus', 'perpustakaan', 'buku', 'ruang baca', 'sirkulasi'],
  ),
  CampusLocation(
    id: 'kantin_ketintang',
    name: 'Kantin Pusat & Food Court Ketintang',
    campus: 'Ketintang',
    area: 'Pujasera Utama & Area Kasir',
    keywords: ['kantin', 'makan', 'food court', 'pujasera', 'kopi'],
  ),
  CampusLocation(
    id: 'rektorat_lama',
    name: 'Gedung Rektorat Lama Ketintang',
    campus: 'Ketintang',
    area: 'Pusat Administrasi & Layanan Mahasiswa',
    keywords: ['rektorat', 'baa', 'bak', 'keuangan', 'kemahasiswaan'],
  ),
  CampusLocation(
    id: 'masjid_ketintang',
    name: 'Masjid Baitul Makmur Ketintang',
    campus: 'Ketintang',
    area: 'Selasar Utama & Area Tempat Wudhu',
    keywords: ['masjid', 'mushola', 'sholat', 'baitul makmur', 'wudhu'],
  ),
  CampusLocation(
    id: 'feb_fisipol',
    name: 'Gedung G7 FEB & FISIPOL Ketintang',
    campus: 'Ketintang',
    area: 'Fakultas Ekonomika dan Bisnis & Ilmu Sosial',
    keywords: ['feb', 'fisipol', 'ekonomi', 'bisnis', 'g7', 'akuntansi', 'manajemen'],
  ),
  CampusLocation(
    id: 'fmipa_c1',
    name: 'Gedung C1 FMIPA Ketintang',
    campus: 'Ketintang',
    area: 'Fakultas Matematika & Ilmu Pengetahuan Alam',
    keywords: ['fmipa', 'c1', 'matematika', 'fisika', 'kimia', 'biologi', 'sains'],
  ),
  CampusLocation(
    id: 'vokasi_ketintang',
    name: 'Gedung Program Pendidikan Vokasi Ketintang',
    campus: 'Ketintang',
    area: 'Gedung Kesenian & Vokasi Terpadu',
    keywords: ['vokasi', 'd4', 'terapan', 'bengkel'],
  ),
  CampusLocation(
    id: 'parkir_ketintang',
    name: 'Area Parkir Motor & Mobil Ketintang',
    campus: 'Ketintang',
    area: 'Parkir Barat & Pos Satpam Gerbang Utama',
    keywords: ['parkir', 'motor', 'helm', 'pos satpam', 'gerbang'],
  ),
  CampusLocation(
    id: 'gazebo_ft',
    name: 'Gazebo Depan Gedung E1 FT Ketintang',
    campus: 'Ketintang',
    area: 'Taman Santai & Tempat Duduk Mahasiswa',
    keywords: ['gazebo', 'taman', 'e1', 'depan ft', 'tempat nongkrong'],
  ),

  // --- KAMPUS LIDAH WETAN ---
  CampusLocation(
    id: 'fbs_k10',
    name: 'Gedung K10 Fakultas Bahasa dan Seni (FBS)',
    campus: 'Lidah Wetan',
    area: 'Fakultas Bahasa & Seni • Gedung K10',
    keywords: ['fbs', 'k10', 'bahasa', 'seni', 'sastra', 'desain', 'musik'],
  ),
  CampusLocation(
    id: 'fip_o5',
    name: 'Gedung O5 Fakultas Ilmu Pendidikan (FIP)',
    campus: 'Lidah Wetan',
    area: 'Fakultas Ilmu Pendidikan • Gedung O5',
    keywords: ['fip', 'o5', 'pendidikan', 'pgsd', 'bk', 'paud'],
  ),
  CampusLocation(
    id: 'rektorat_lidah',
    name: 'Gedung Rektorat Baru Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Kantor Pusat Pimpinan UNESA',
    keywords: ['rektorat baru', 'kantor rektor', 'lantai 1', 'lobi'],
  ),
  CampusLocation(
    id: 'danau_lidah',
    name: 'Area Danau & Jogging Track UNESA',
    campus: 'Lidah Wetan',
    area: 'Depan Rektorat Baru Lidah Wetan',
    keywords: ['danau', 'jogging', 'taman danau', 'dermaga', 'pinggir danau'],
  ),
  CampusLocation(
    id: 'gor_bima',
    name: 'GOR Bima & Lapangan Olahraga Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Tribun Penonton, Loker, & Lapangan Basket/Futsal',
    keywords: ['gor', 'bima', 'futsal', 'basket', 'lapangan', 'olahraga', 'stadion'],
  ),
  CampusLocation(
    id: 'fik_u1',
    name: 'Gedung U1 Fakultas Ilmu Keolahragaan (FIK)',
    campus: 'Lidah Wetan',
    area: 'Fakultas Ilmu Keolahragaan dan Kesehatan',
    keywords: ['fik', 'fikk', 'olahraga', 'u1', 'senam', 'kolam renang'],
  ),
  CampusLocation(
    id: 'masjid_lidah',
    name: 'Masjid Baitul Muttaqin / Al-Ittihad Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Masjid Kampus Lidah Wetan',
    keywords: ['masjid lidah', 'mushola', 'sholat', 'tempat wudhu'],
  ),
  CampusLocation(
    id: 'kantin_fbs',
    name: 'Kantin Kejujuran FBS Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Kantin Belakang Gedung Seni Rupa',
    keywords: ['kantin fbs', 'kantin kejujuran', 'makan', 'minum'],
  ),
  CampusLocation(
    id: 'gkb_lidah',
    name: 'Gedung Kuliah Bersama (GKB) Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Lantai 1-7 • Ruang Kuliah Umum Mahasiswa',
    keywords: ['gkb', 'kuliah bersama', 'ruang kelas', 'lantai 2', 'lantai 3'],
  ),
  CampusLocation(
    id: 'labschool_lidah',
    name: 'Kompleks Lab School UNESA Lidah Wetan',
    campus: 'Lidah Wetan',
    area: 'Sekolah Laboratorium UNESA',
    keywords: ['lab school', 'labschool', 'sd', 'smp', 'sma'],
  ),
];

/// Fungsi Pencarian Cerdas Lokasi Kampus
List<CampusLocation> searchCampusLocations(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  return unesaCampusLocations.where((loc) {
    if (loc.name.toLowerCase().contains(q)) return true;
    if (loc.area.toLowerCase().contains(q)) return true;
    if (loc.campus.toLowerCase().contains(q)) return true;
    return loc.keywords.any((k) => k.toLowerCase().contains(q));
  }).toList();
}

/// Deteksi Otomatis Kampus dari Teks Bebas (Smart Scanner)
String detectCampusFromText(String text, {String fallbackCampus = 'Ketintang'}) {
  final lower = text.toLowerCase();

  // Deteksi Keyword Kampus Ketintang
  const ketintangKeys = [
    'ketintang',
    'ft',
    'feb',
    'fisipol',
    'fmipa',
    'vokasi',
    'e1',
    'e11',
    'g7',
    'c1',
    'baitul makmur',
    'teknik',
  ];
  for (final key in ketintangKeys) {
    if (lower.contains(key)) return 'Ketintang';
  }

  // Deteksi Keyword Kampus Lidah Wetan
  const lidahKeys = [
    'lidah',
    'fbs',
    'fip',
    'fik',
    'fikk',
    'fish',
    'danau',
    'gor bima',
    'bima',
    'k10',
    'o5',
    'u1',
    'al-ittihad',
    'lab school',
    'labschool',
  ];
  for (final key in lidahKeys) {
    if (lower.contains(key)) return 'Lidah Wetan';
  }

  return fallbackCampus;
}

