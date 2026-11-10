import 'package:flutter/material.dart';

void main() {
  runApp(const FindItCampusApp());
}

// =============================================================================
// 1. WARNA, GRADIEN, DAN FUNGSI BANTUAN
// =============================================================================

class AppColors {
  // Warna dasar brand
  static const Color navy = Color(0xFF183B56);
  static const Color blue = Color(0xFF2878A8);
  static const Color lightBlue = Color(0xFFEAF2F7);
  static const Color background = Color(0xFFF3F6FC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF2E9D5B);
  static const Color warning = Color(0xFFE08A00);
  static const Color danger = Color(0xFFD64545);

  // Warna aksen tambahan agar tampilan lebih hidup
  static const Color indigo = Color(0xFF4F46E5);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color violet = Color(0xFF7C3AED);
  static const Color pink = Color(0xFFEC4899);
  static const Color teal = Color(0xFF14B8A6);
}

class AppGradients {
  static const LinearGradient header = LinearGradient(
    colors: [Color(0xFF0F2A44), Color(0xFF1F4E8C), Color(0xFF2BA3C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.indigo, AppColors.cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebar = LinearGradient(
    colors: [Color(0xFF0B1F33), Color(0xFF16405F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Layar lebar (desktop/web) jika lebar jendela >= 900 px.
bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;

/// Format tanggal sederhana tanpa package intl, contoh: 9 Nov 2026.
String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Ikon sesuai kategori barang.
IconData categoryIcon(String category) {
  switch (category) {
    case 'Dokumen':
      return Icons.badge_outlined;
    case 'Elektronik':
      return Icons.devices_other;
    case 'Tas & Dompet':
      return Icons.shopping_bag_outlined;
    case 'Kunci':
      return Icons.vpn_key_outlined;
    case 'Pakaian':
      return Icons.checkroom;
    default:
      return Icons.inventory_2_outlined;
  }
}

/// Pasangan warna gradien untuk tiap kategori.
List<Color> categoryColors(String category) {
  switch (category) {
    case 'Dokumen':
      return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    case 'Elektronik':
      return const [Color(0xFF06B6D4), Color(0xFF3B82F6)];
    case 'Tas & Dompet':
      return const [Color(0xFFEC4899), Color(0xFFF97316)];
    case 'Kunci':
      return const [Color(0xFFF59E0B), Color(0xFFEF4444)];
    case 'Pakaian':
      return const [Color(0xFFA855F7), Color(0xFFEC4899)];
    default:
      return const [Color(0xFF14B8A6), Color(0xFF22C55E)];
  }
}

// =============================================================================
// 2. MODEL DATA, STATUS, DAN AppData
// =============================================================================

enum UserRole { student, admin }

/// Jenis laporan: barang hilang atau barang ditemukan.
enum ReportType {
  lost('Hilang', Icons.search_off, AppColors.violet),
  found('Ditemukan', Icons.inventory_2_outlined, AppColors.teal);

  final String label;
  final IconData icon;
  final Color color;
  const ReportType(this.label, this.icon, this.color);
}

/// Status VERIFIKASI laporan (urusan admin).
enum VerificationStatus {
  pending('Menunggu Verifikasi', AppColors.warning, Icons.hourglass_top),
  approved('Disetujui', AppColors.success, Icons.check_circle_outline),
  rejected('Ditolak', AppColors.danger, Icons.cancel_outlined),
  reverify('Menunggu Verifikasi Ulang', AppColors.warning, Icons.refresh);

  final String label;
  final Color color;
  final IconData icon;
  const VerificationStatus(this.label, this.color, this.icon);
}

/// Status PENYELESAIAN barang (dipisah dari status verifikasi).
enum ResolutionStatus {
  notFound('Belum Ditemukan', AppColors.blue, Icons.search),
  awaitingOwner(
    'Menunggu Konfirmasi Pemilik',
    AppColors.warning,
    Icons.pending_actions,
  ),
  returned('Sudah Dikembalikan', AppColors.success, Icons.verified_outlined),
  followUp(
    'Perlu Tindak Lanjut',
    AppColors.danger,
    Icons.report_problem_outlined,
  ),
  // Skenario baru: pemilik menemukan barangnya sendiri.
  selfFoundPending(
    'Menunggu Persetujuan Admin',
    AppColors.warning,
    Icons.admin_panel_settings_outlined,
  ),
  selfFound('Sudah Ditemukan', AppColors.teal, Icons.task_alt);

  final String label;
  final Color color;
  final IconData icon;
  const ResolutionStatus(this.label, this.color, this.icon);
}

/// Status pengajuan penemuan barang.
enum SubmissionStatus {
  pending('Menunggu Verifikasi', AppColors.warning, Icons.hourglass_top),
  approved('Disetujui', AppColors.success, Icons.check_circle_outline),
  rejected('Ditolak', AppColors.danger, Icons.cancel_outlined),
  done('Selesai', AppColors.success, Icons.task_alt);

  final String label;
  final Color color;
  final IconData icon;
  const SubmissionStatus(this.label, this.color, this.icon);
}

/// Laporan barang hilang / ditemukan.
class LostFoundReport {
  final String id;
  final String itemName;
  final String category;
  final String description;
  final String location;
  final ReportType type;
  final DateTime date;
  final String reporter;
  VerificationStatus verificationStatus;
  ResolutionStatus resolutionStatus;
  DateTime? resolvedAt;

  // Data "ditemukan sendiri oleh pemilik" (diisi saat pemilik mengajukan).
  String? selfFoundLocation;
  DateTime? selfFoundDate;
  String? selfFoundNote;

  LostFoundReport({
    required this.id,
    required this.itemName,
    required this.category,
    required this.description,
    required this.location,
    required this.type,
    required this.date,
    required this.reporter,
    this.verificationStatus = VerificationStatus.pending,
    this.resolutionStatus = ResolutionStatus.notFound,
    this.resolvedAt,
  });

  String get locationLabel =>
      type == ReportType.lost ? 'Lokasi kehilangan' : 'Lokasi ditemukan';
  String get dateLabel =>
      type == ReportType.lost ? 'Tanggal kehilangan' : 'Tanggal ditemukan';

  /// True jika barang sudah kembali ke pemilik (lewat penemu atau ditemukan sendiri).
  bool get isResolved =>
      resolutionStatus == ResolutionStatus.returned ||
      resolutionStatus == ResolutionStatus.selfFound;

  void clearSelfFoundData() {
    selfFoundLocation = null;
    selfFoundDate = null;
    selfFoundNote = null;
  }
}

/// Pengajuan penemuan. Terhubung ke laporan kehilangan lewat [lostReportId].
class FoundSubmission {
  final String id;
  final String lostReportId; // <- relasi ke LostFoundReport.id
  final String itemName;
  final String finder;
  final String foundLocation;
  final DateTime foundDate;
  final String description;
  SubmissionStatus status;

  FoundSubmission({
    required this.id,
    required this.lostReportId,
    required this.itemName,
    required this.finder,
    required this.foundLocation,
    required this.foundDate,
    required this.description,
    this.status = SubmissionStatus.pending,
  });
}

/// Penyimpanan data sementara (hanya di memori selama aplikasi berjalan).
class AppData {
  static String currentUser = '';
  static UserRole currentRole = UserRole.student;

  static int _reportCounter = 3; // 3 laporan dummy sudah ada
  static int _submissionCounter = 0;

  static DateTime _daysAgo(int days) =>
      DateUtils.dateOnly(DateTime.now().subtract(Duration(days: days)));

  static final List<LostFoundReport> reports = [
    LostFoundReport(
      id: 'LR-001',
      itemName: 'Botol Minum Tumbler Biru',
      category: 'Lainnya',
      description: 'Tumbler biru dengan stiker kucing di bagian bawah.',
      location: 'Kantin Gedung C',
      type: ReportType.found,
      date: _daysAgo(2),
      reporter: 'Sinta',
      verificationStatus: VerificationStatus.approved,
    ),
    LostFoundReport(
      id: 'LR-002',
      itemName: 'Kunci Motor Honda',
      category: 'Kunci',
      description: 'Kunci motor dengan gantungan karakter robot warna merah.',
      location: 'Parkiran Gedung B',
      type: ReportType.lost,
      date: _daysAgo(1),
      reporter: 'Raka',
      verificationStatus: VerificationStatus.approved,
    ),
    LostFoundReport(
      id: 'LR-003',
      itemName: 'Power Bank Hitam',
      category: 'Elektronik',
      description: 'Power bank hitam 10.000 mAh, ada goresan di sisi kiri.',
      location: 'Perpustakaan Lantai 1',
      type: ReportType.lost,
      date: _daysAgo(3),
      reporter: 'Dewi',
      verificationStatus: VerificationStatus.approved,
    ),
  ];

  static final List<FoundSubmission> submissions = [];

  static String nextReportId() {
    _reportCounter++;
    return 'LR-${_reportCounter.toString().padLeft(3, '0')}';
  }

  static String nextSubmissionId() {
    _submissionCounter++;
    return 'FS-${_submissionCounter.toString().padLeft(3, '0')}';
  }

  static LostFoundReport? reportById(String id) {
    for (final report in reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  static FoundSubmission? submissionById(String id) {
    for (final submission in submissions) {
      if (submission.id == id) return submission;
    }
    return null;
  }

  /// Laporan yang sudah disetujui admin (terbaru di atas).
  static List<LostFoundReport> get approvedReports => reports
      .where((r) => r.verificationStatus == VerificationStatus.approved)
      .toList()
      .reversed
      .toList();

  /// Laporan milik satu pengguna (terbaru di atas).
  static List<LostFoundReport> reportsBy(String user) =>
      reports.where((r) => r.reporter == user).toList().reversed.toList();

  static List<FoundSubmission> submissionsFor(String reportId) =>
      submissions.where((s) => s.lostReportId == reportId).toList();

  /// Pengajuan yang masih aktif (menunggu verifikasi atau sudah disetujui).
  /// Dipakai untuk mencegah pengajuan ganda pada laporan yang sama.
  static FoundSubmission? activeSubmissionFor(String reportId) {
    for (final s in submissions) {
      if (s.lostReportId == reportId &&
          (s.status == SubmissionStatus.pending ||
              s.status == SubmissionStatus.approved)) {
        return s;
      }
    }
    return null;
  }

  /// Pengajuan yang sudah disetujui admin (atau sudah selesai).
  static FoundSubmission? acceptedSubmissionFor(String reportId) {
    for (final s in submissions) {
      if (s.lostReportId == reportId &&
          (s.status == SubmissionStatus.approved ||
              s.status == SubmissionStatus.done)) {
        return s;
      }
    }
    return null;
  }
}

// =============================================================================
// 3. APP, TEMA, DAN TRANSISI HALAMAN
// =============================================================================

OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Transisi antar-halaman: fade + geser halus dari kanan.
Route<void> appRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class FindItCampusApp extends StatelessWidget {
  const FindItCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.indigo)
        .copyWith(
          primary: AppColors.indigo,
          onPrimary: Colors.white,
          secondary: AppColors.cyan,
          surface: AppColors.white,
          error: AppColors.danger,
        );

    return MaterialApp(
      title: 'FindIt Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: _inputBorder(const Color(0xFFDDE5EF)),
          enabledBorder: _inputBorder(const Color(0xFFDDE5EF)),
          focusedBorder: _inputBorder(AppColors.indigo, width: 1.8),
          errorBorder: _inputBorder(AppColors.danger),
          focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// =============================================================================
// 4. WIDGET BANTUAN (dipakai ulang di banyak screen)
// =============================================================================

/// Menampilkan SnackBar sebagai feedback setelah tindakan pengguna.
void showFeedback(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: isDesktop(context) ? 440 : null,
        backgroundColor: isError ? AppColors.danger : AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Dialog konfirmasi. Mengembalikan true jika pengguna menekan tombol konfirmasi.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(message),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            backgroundColor: isDanger ? AppColors.danger : AppColors.indigo,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Date picker sederhana (tidak boleh memilih tanggal di masa depan).
Future<DateTime?> pickCampusDate(
  BuildContext context,
  DateTime initial,
  String helpText,
) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2024),
    lastDate: DateUtils.dateOnly(DateTime.now()),
    helpText: helpText,
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: AppColors.indigo.withAlpha(18),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// AppBar bergradasi untuk screen detail dan form.
AppBar gradientAppBar(String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: const BoxDecoration(gradient: AppGradients.header),
    ),
  );
}

/// Membatasi lebar konten agar tetap proporsional di layar lebar.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWidth({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Muncul dengan fade + geser ke atas. [index] memberi jeda bertahap (stagger).
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final step = index > 8 ? 8 : index;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + step * 70),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Kartu putih: naik sedikit saat kursor diarahkan (desktop) + efek sentuh.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _hover ? -3.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withAlpha(_hover ? 46 : 18),
              blurRadius: _hover ? 28 : 16,
              offset: Offset(0, _hover ? 12 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onTap,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Tombol bergradasi (dipakai sebagai tombol utama "Buat Laporan").
class GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withAlpha(90),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header besar bergradasi dengan lingkaran dekoratif.
class HeroHeader extends StatelessWidget {
  final Widget child;
  const HeroHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        desktop ? 28 : 20,
        desktop ? 26 : 12,
        desktop ? 28 : 20,
        desktop ? 26 : 22,
      ),
      child: child,
    );

    return Container(
      width: double.infinity,
      margin: desktop ? const EdgeInsets.fromLTRB(24, 24, 24, 0) : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: desktop
            ? BorderRadius.circular(30)
            : const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withAlpha(50),
              ),
            ),
          ),
          Positioned(
            right: 90,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.violet.withAlpha(60),
              ),
            ),
          ),
          desktop ? content : SafeArea(bottom: false, child: content),
        ],
      ),
    );
  }
}

/// Baris sapaan di header + tombol keluar (opsional, hanya di layar HP).
class HeaderGreeting extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onLogout;

  const HeaderGreeting({
    super.key,
    required this.title,
    required this.subtitle,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(38),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.travel_explore, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(215),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        if (onLogout != null)
          IconButton(
            onPressed: onLogout,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
      ],
    );
  }
}

class StatTileData {
  final IconData icon;
  final int value;
  final String label;
  const StatTileData(this.icon, this.value, this.label);
}

/// Deretan kartu statistik kecil (jumlah kolom menyesuaikan lebar layar).
class StatGrid extends StatelessWidget {
  final List<StatTileData> tiles;
  final double minTileWidth;

  const StatGrid({super.key, required this.tiles, this.minTileWidth = 100});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = constraints.maxWidth;
        final columns = ((width + gap) / (minTileWidth + gap))
            .floor()
            .clamp(1, tiles.length)
            .toInt();
        final tileWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles
              .map(
                (t) => SizedBox(
                  width: tileWidth,
                  child: _StatTile(data: t),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatTileData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 20, color: Colors.white.withAlpha(225)),
          const SizedBox(height: 8),
          // Angka naik pelan dari nilai sebelumnya ke nilai baru.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: data.value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Text(
              '${value.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge status berwarna. Warna dan teks berganti dengan animasi.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Row(
          key: ValueKey<String>(label),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak ikon kategori bergradasi.
class CategoryTile extends StatelessWidget {
  final String category;
  final double size;
  const CategoryTile({super.key, required this.category, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final colors = categoryColors(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: colors.first.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        categoryIcon(category),
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}

/// Kartu putih statis (tanpa efek sentuh) untuk blok informasi.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const SectionCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

/// Satu baris informasi: ikon + label kecil + nilai.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.indigo.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak informasi berwarna (petunjuk / peringatan).
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const InfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan ketika daftar kosong.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.indigo.withAlpha(30),
                    AppColors.cyan.withAlpha(30),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppColors.indigo),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pil filter dengan animasi perpindahan pilihan.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.accent : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFDDE5EF),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.indigo.withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.navy,
          ),
        ),
      ),
    );
  }
}

/// Grid responsif: 1 kolom (HP), 2 kolom, atau 3 kolom (desktop).
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  const ResponsiveGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = constraints.maxWidth;
        final columns = width >= 980 ? 3 : (width >= 640 ? 2 : 1);
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < children.length; i++)
              SizedBox(
                width: itemWidth,
                child: FadeSlideIn(index: i, child: children[i]),
              ),
          ],
        );
      },
    );
  }
}

/// Susunan halaman: satu kolom di HP, dua kolom di desktop.
class TwoPane extends StatelessWidget {
  final List<Widget> left;
  final List<Widget> right;
  const TwoPane({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop(context) || right.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...left, ...right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: left,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: right,
          ),
        ),
      ],
    );
  }
}

/// Kerangka halaman dengan hero di atas dan konten di bawahnya (bisa di-scroll).
class PageBody extends StatelessWidget {
  final Widget hero;
  final List<Widget> children;
  const PageBody({super.key, required this.hero, required this.children});

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);
    final pad = desktop ? 24.0 : 16.0;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hero,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    22,
                    pad,
                    desktop ? 40 : 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu satu laporan pada daftar.
class ReportCard extends StatelessWidget {
  final LostFoundReport report;
  final VoidCallback onTap;
  final bool showVerification; // tampilkan badge status verifikasi
  final bool showReporter; // tampilkan nama pelapor
  final bool showFinder; // tampilkan nama penemu (jika sudah disetujui)

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.showVerification = false,
    this.showReporter = false,
    this.showFinder = false,
  });

  @override
  Widget build(BuildContext context) {
    final accepted = showFinder
        ? AppData.acceptedSubmissionFor(report.id)
        : null;
    final isLost = report.type == ReportType.lost;
    final dateText = showReporter
        ? '${formatDate(report.date)}  •  ${report.reporter}'
        : formatDate(report.date);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTile(category: report.category, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusBadge(
                      label: report.type.label,
                      color: report.type.color,
                      icon: report.type.icon,
                    ),
                    if (showVerification)
                      StatusBadge(
                        label: report.verificationStatus.label,
                        color: report.verificationStatus.color,
                        icon: report.verificationStatus.icon,
                      ),
                    if (isLost &&
                        report.verificationStatus ==
                            VerificationStatus.approved)
                      StatusBadge(
                        label: report.resolutionStatus.label,
                        color: report.resolutionStatus.color,
                        icon: report.resolutionStatus.icon,
                      ),
                  ],
                ),
                if (accepted != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.volunteer_activism_outlined,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ditemukan oleh ${accepted.finder}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Kartu satu pengajuan penemuan (dipakai di dashboard admin).
class SubmissionCard extends StatelessWidget {
  final FoundSubmission submission;
  final VoidCallback onTap;

  const SubmissionCard({
    super.key,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final report = AppData.reportById(submission.lostReportId);
    final ownerText = report == null
        ? 'Laporan ${submission.lostReportId}'
        : 'Laporan ${report.id} milik ${report.reporter}';

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Penemu: ${submission.finder}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  ownerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                StatusBadge(
                  label: submission.status.label,
                  color: submission.status.color,
                  icon: submission.status.icon,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Baris-baris informasi sebuah laporan (dipakai di detail & form penemuan).
class ReportInfoRows extends StatelessWidget {
  final LostFoundReport report;
  const ReportInfoRows({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(icon: Icons.tag, label: 'ID Laporan', value: report.id),
        InfoRow(
          icon: categoryIcon(report.category),
          label: 'Kategori',
          value: report.category,
        ),
        InfoRow(
          icon: Icons.notes_outlined,
          label: 'Deskripsi',
          value: report.description,
        ),
        InfoRow(
          icon: Icons.place_outlined,
          label: report.locationLabel,
          value: report.location,
        ),
        InfoRow(
          icon: Icons.event_outlined,
          label: report.dateLabel,
          value: formatDate(report.date),
        ),
        InfoRow(
          icon: Icons.person_outline,
          label: 'Pelapor',
          value: report.reporter,
        ),
        if (report.resolvedAt != null)
          InfoRow(
            icon: Icons.task_alt,
            label: 'Tanggal selesai',
            value: formatDate(report.resolvedAt!),
          ),
      ],
    );
  }
}

/// Informasi "ditemukan sendiri oleh pemilik".
class SelfFoundInfo extends StatelessWidget {
  final LostFoundReport report;
  const SelfFoundInfo({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(
          icon: Icons.place_outlined,
          label: 'Lokasi barang ditemukan',
          value: report.selfFoundLocation ?? '-',
        ),
        InfoRow(
          icon: Icons.event_outlined,
          label: 'Tanggal ditemukan',
          value: report.selfFoundDate == null
              ? '-'
              : formatDate(report.selfFoundDate!),
        ),
        InfoRow(
          icon: Icons.notes_outlined,
          label: 'Keterangan pemilik',
          value: report.selfFoundNote ?? '-',
        ),
      ],
    );
  }
}

/// Baris-baris informasi sebuah pengajuan penemuan.
class SubmissionInfo extends StatelessWidget {
  final FoundSubmission submission;
  final bool showStatus;

  const SubmissionInfo({
    super.key,
    required this.submission,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStatus)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: StatusBadge(
              label: submission.status.label,
              color: submission.status.color,
              icon: submission.status.icon,
            ),
          ),
        InfoRow(
          icon: Icons.person_outline,
          label: 'Penemu',
          value: submission.finder,
        ),
        InfoRow(
          icon: Icons.place_outlined,
          label: 'Lokasi ditemukan',
          value: submission.foundLocation,
        ),
        InfoRow(
          icon: Icons.event_outlined,
          label: 'Tanggal ditemukan',
          value: formatDate(submission.foundDate),
        ),
        InfoRow(
          icon: Icons.notes_outlined,
          label: 'Ciri-ciri barang yang ditemukan',
          value: submission.description,
        ),
        InfoRow(
          icon: Icons.link,
          label: 'Terhubung ke laporan',
          value: submission.lostReportId,
        ),
      ],
    );
  }
}

/// Baris tombol Tolak / Setujui untuk admin.
class DecisionRow extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final String rejectLabel;
  final String approveLabel;

  const DecisionRow({
    super.key,
    required this.onReject,
    required this.onApprove,
    this.rejectLabel = 'Tolak',
    this.approveLabel = 'Setujui',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            onPressed: onReject,
            icon: const Icon(Icons.close),
            label: Text(rejectLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: onApprove,
            icon: const Icon(Icons.check),
            label: Text(approveLabel),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 5. KERANGKA NAVIGASI RESPONSIF (sidebar di desktop, bottom bar di HP)
// =============================================================================

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge = 0,
  });
}

class AppShell extends StatelessWidget {
  final String userName;
  final String roleLabel;
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback? onCreate; // null = tidak ada tombol "Buat Laporan"
  final Widget body;

  const AppShell({
    super.key,
    required this.userName,
    required this.roleLabel,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.body,
    this.onCreate,
  });

  Widget _badgeIcon(NavItem item, bool selected) {
    return Badge(
      isLabelVisible: item.badge > 0,
      label: Text('${item.badge}'),
      child: Icon(selected ? item.selectedIcon : item.icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              userName: userName,
              roleLabel: roleLabel,
              items: items,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
              onLogout: onLogout,
              onCreate: onCreate,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: onCreate == null
          ? null
          : GradientButton(
              icon: Icons.add,
              label: 'Buat Laporan',
              onPressed: onCreate!,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.indigo.withAlpha(36),
        height: 68,
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: _badgeIcon(item, false),
              selectedIcon: _badgeIcon(item, true),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String userName;
  final String roleLabel;
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback? onCreate;

  const _Sidebar({
    required this.userName,
    required this.roleLabel,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final initial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Container(
      width: 268,
      decoration: const BoxDecoration(gradient: AppGradients.sidebar),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'FindIt Campus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              // Kartu pengguna
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.cyan,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            roleLabel,
                            style: TextStyle(
                              color: Colors.white.withAlpha(170),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 10),
                child: Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.white.withAlpha(120),
                    fontSize: 11.5,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (var i = 0; i < items.length; i++)
                _SidebarTile(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              if (onCreate != null) ...[
                GradientButton(
                  icon: Icons.add,
                  label: 'Buat Laporan',
                  onPressed: onCreate!,
                  expanded: true,
                ),
                const SizedBox(height: 14),
              ],
              _SidebarTile(
                item: const NavItem(
                  icon: Icons.logout,
                  selectedIcon: Icons.logout,
                  label: 'Keluar',
                ),
                selected: false,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withAlpha(34) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.white.withAlpha(40) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: Colors.white.withAlpha(selected ? 255 : 175),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(selected ? 255 : 190),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (item.badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Transisi perpindahan tab di dalam shell (fade + geser tipis).
Widget animatedTabBody(int index, Widget page) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 350),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeIn,
    layoutBuilder: (currentChild, previousChildren) {
      return Stack(
        fit: StackFit.expand,
        children: [...previousChildren, if (currentChild != null) currentChild],
      );
    },
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    child: KeyedSubtree(key: ValueKey<int>(index), child: page),
  );
}

/// Keluar ke halaman login (data AppData tetap ada selama aplikasi hidup).
void logoutToLogin(BuildContext context) {
  AppData.currentUser = '';
  showFeedback(context, 'Anda telah keluar.');
  Navigator.pushAndRemoveUntil(
    context,
    appRoute(const LoginScreen()),
    (route) => false,
  );
}

// =============================================================================
// 6. SCREEN: LOGIN (simulasi pemilihan username & role)
// =============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student; // state: role yang dipilih
  bool _hidePassword = true; // state: sembunyikan / tampilkan password

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// "budi" -> "Budi" agar nama pelapor konsisten saat dibandingkan.
  String _normalizeName(String raw) {
    final text = raw.trim();
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) {
      showFeedback(
        context,
        'Data login belum valid. Periksa kolom yang berwarna merah.',
        isError: true,
      );
      return;
    }

    AppData.currentUser = _normalizeName(_usernameController.text);
    AppData.currentRole = _selectedRole;

    final Widget next = _selectedRole == UserRole.admin
        ? const AdminShellScreen()
        : const StudentShellScreen();

    showFeedback(context, 'Selamat datang, ${AppData.currentUser}!');
    Navigator.pushReplacement(context, appRoute(next));
  }

  Widget _buildForm() {
    return SectionCard(
      margin: EdgeInsets.zero,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masuk untuk melapor atau memverifikasi barang.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<UserRole>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<UserRole>(
                    value: UserRole.student,
                    label: Text('Mahasiswa'),
                    icon: Icon(Icons.school_outlined),
                  ),
                  ButtonSegment<UserRole>(
                    value: UserRole.admin,
                    label: Text('Admin'),
                    icon: Icon(Icons.admin_panel_settings_outlined),
                  ),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (selection) {
                  setState(() => _selectedRole = selection.first);
                },
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Masukkan Nama Anda, bebas (minimal 3 karakter)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Username wajib diisi';
                if (text.length < 3) return 'Username minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Bebas, minimal 4 karakter',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _hidePassword
                      ? 'Tampilkan password'
                      : 'Sembunyikan password',
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
              ),
              validator: (value) {
                final text = value ?? '';
                if (text.isEmpty) return 'Password wajib diisi';
                if (text.length < 4) return 'Password minimal 4 karakter';
                return null;
              },
            ),
            const SizedBox(height: 22),
            GradientButton(
              icon: Icons.login,
              label: 'Masuk',
              onPressed: _login,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            const Expanded(flex: 5, child: _BrandPanel()),
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: FadeSlideIn(child: _buildForm()),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroHeader(
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FindIt Campus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FadeSlideIn(child: _buildForm()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel branding di sisi kiri halaman login versi desktop.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.header),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withAlpha(50),
              ),
            ),
          ),
          Positioned(
            right: 120,
            bottom: 90,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.violet.withAlpha(70),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeSlideIn(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'FindIt Campus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Every Lost Item Deserves a Way Home',
                        style: TextStyle(
                          color: Colors.white.withAlpha(225),
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const _BrandFeature(
                        icon: Icons.campaign_outlined,
                        text: 'Laporkan barang hilang atau yang kamu temukan',
                      ),
                      const _BrandFeature(
                        icon: Icons.fact_check_outlined,
                        text: 'Setiap laporan diverifikasi admin kampus',
                      ),
                      const _BrandFeature(
                        icon: Icons.volunteer_activism_outlined,
                        text: 'Barang kembali ke pemilik dengan aman',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BrandFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(34),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withAlpha(235),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 7. SHELL MAHASISWA: Beranda + Laporan Saya
// =============================================================================

class StudentShellScreen extends StatefulWidget {
  const StudentShellScreen({super.key});

  @override
  State<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends State<StudentShellScreen> {
  int _index = 0; // state: tab aktif (0 = Beranda, 1 = Laporan Saya)
  final _searchController = TextEditingController();
  String _query = ''; // state: kata kunci pencarian
  ReportType? _typeFilter; // state: filter jenis (null = semua)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Membuka screen lain, lalu menyegarkan tampilan saat kembali.
  void _open(Widget screen) {
    Navigator.push(context, appRoute(screen)).then((_) {
      if (mounted) setState(() {});
    });
  }

  List<LostFoundReport> _filteredReports() {
    final q = _query.trim().toLowerCase();
    return AppData.approvedReports.where((r) {
      final matchType = _typeFilter == null || r.type == _typeFilter;
      final matchQuery =
          q.isEmpty ||
          r.itemName.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
      return matchType && matchQuery;
    }).toList();
  }

  String _myReportsSummary() {
    final mine = AppData.reportsBy(AppData.currentUser);
    if (mine.isEmpty) return 'Belum ada laporan';
    final waiting = mine
        .where(
          (r) =>
              r.verificationStatus == VerificationStatus.pending ||
              r.verificationStatus == VerificationStatus.reverify,
        )
        .length;
    final needConfirm = mine
        .where((r) => r.resolutionStatus == ResolutionStatus.awaitingOwner)
        .length;
    final parts = <String>['${mine.length} laporan'];
    if (waiting > 0) parts.add('$waiting menunggu verifikasi');
    if (needConfirm > 0) parts.add('$needConfirm perlu konfirmasi');
    return parts.join('  •  ');
  }

  Widget _buildHome(BuildContext context) {
    final reports = _filteredReports();
    final lostApproved = AppData.approvedReports
        .where((r) => r.type == ReportType.lost)
        .toList();
    final closed = lostApproved.where((r) => r.isResolved).length;
    final active = lostApproved.length - closed;
    final mineCount = AppData.reportsBy(AppData.currentUser).length;

    return PageBody(
      hero: HeroHeader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderGreeting(
              title: 'Halo, ${AppData.currentUser}',
              subtitle: 'Every Lost Item Deserves a Way Home',
              onLogout: isDesktop(context)
                  ? null
                  : () => logoutToLogin(context),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari barang, kategori, atau lokasi',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 18),
            StatGrid(
              tiles: [
                StatTileData(Icons.search, active, 'Masih dicari'),
                StatTileData(Icons.verified_outlined, closed, 'Sudah kembali'),
                StatTileData(
                  Icons.assignment_outlined,
                  mineCount,
                  'Laporan saya',
                ),
              ],
            ),
          ],
        ),
      ),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilterPill(
              label: 'Semua',
              selected: _typeFilter == null,
              onTap: () => setState(() => _typeFilter = null),
            ),
            FilterPill(
              label: 'Hilang',
              selected: _typeFilter == ReportType.lost,
              onTap: () => setState(() => _typeFilter = ReportType.lost),
            ),
            FilterPill(
              label: 'Ditemukan',
              selected: _typeFilter == ReportType.found,
              onTap: () => setState(() => _typeFilter = ReportType.found),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${reports.length} laporan terverifikasi',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (reports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: EmptyState(
              icon: Icons.search_off,
              title: 'Laporan tidak ditemukan',
              message: 'Coba kata kunci lain atau ubah filter. Laporan baru muncul setelah disetujui admin.',
            ),
          )
        else
          ResponsiveGrid(
            children: [
              for (final report in reports)
                ReportCard(
                  report: report,
                  onTap: () => _open(ReportDetailScreen(reportId: report.id)),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildMine(BuildContext context) {
    final mine = AppData.reportsBy(AppData.currentUser);
    final waiting = mine
        .where(
          (r) =>
              r.verificationStatus == VerificationStatus.pending ||
              r.verificationStatus == VerificationStatus.reverify,
        )
        .length;
    final needConfirm = mine
        .where((r) => r.resolutionStatus == ResolutionStatus.awaitingOwner)
        .length;
    final done = mine.where((r) => r.isResolved).length;

    return PageBody(
      hero: HeroHeader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderGreeting(
              title: 'Laporan Saya',
              subtitle: _myReportsSummary(),
              onLogout: isDesktop(context)
                  ? null
                  : () => logoutToLogin(context),
            ),
            const SizedBox(height: 18),
            StatGrid(
              tiles: [
                StatTileData(
                  Icons.hourglass_top,
                  waiting,
                  'Menunggu verifikasi',
                ),
                StatTileData(
                  Icons.pending_actions,
                  needConfirm,
                  'Perlu konfirmasi',
                ),
                StatTileData(Icons.task_alt, done, 'Selesai'),
              ],
            ),
          ],
        ),
      ),
      children: [
        if (mine.isEmpty)
          EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Belum ada laporan',
            message: 'Laporan yang kamu buat akan muncul di sini beserta status verifikasi dan penyelesaiannya.',
            actionLabel: 'Buat Laporan',
            onAction: () => _open(const ReportFormScreen()),
          )
        else
          ResponsiveGrid(
            children: [
              for (final report in mine)
                ReportCard(
                  report: report,
                  showVerification: true,
                  showFinder: true,
                  onTap: () => _open(ReportDetailScreen(reportId: report.id)),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final needConfirm = AppData.reportsBy(AppData.currentUser)
        .where((r) => r.resolutionStatus == ResolutionStatus.awaitingOwner)
        .length;

    return AppShell(
      userName: AppData.currentUser,
      roleLabel: 'Mahasiswa',
      selectedIndex: _index,
      onSelect: (i) => setState(() => _index = i),
      onLogout: () => logoutToLogin(context),
      onCreate: () => _open(const ReportFormScreen()),
      items: [
        const NavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'Beranda',
        ),
        NavItem(
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          label: 'Laporan Saya',
          badge: needConfirm,
        ),
      ],
      body: animatedTabBody(
        _index,
        _index == 0 ? _buildHome(context) : _buildMine(context),
      ),
    );
  }
}

// =============================================================================
// 8. SCREEN: FORM LAPORAN (hilang / ditemukan)
// =============================================================================

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const List<String> _categories = [
    'Dokumen',
    'Elektronik',
    'Tas & Dompet',
    'Kunci',
    'Pakaian',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  ReportType _type = ReportType.lost; // state: jenis laporan
  String? _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(DateTime.now());
    _dateController.text = formatDate(_date);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  bool get _isLost => _type == ReportType.lost;

  Future<void> _pickDate() async {
    final picked = await pickCampusDate(
      context,
      _date,
      _isLost ? 'Pilih tanggal kehilangan' : 'Pilih tanggal ditemukan',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = formatDate(picked);
      });
    }
  }

  void _submit() {
    // Validasi: jika ada field tidak valid, data TIDAK diproses.
    if (!_formKey.currentState!.validate()) {
      showFeedback(
        context,
        'Laporan belum bisa dikirim. Lengkapi data yang masih salah.',
        isError: true,
      );
      return;
    }

    final report = LostFoundReport(
      id: AppData.nextReportId(),
      itemName: _nameController.text.trim(),
      category: _category!,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      type: _type,
      date: _date,
      reporter: AppData.currentUser,
      // verificationStatus awal: Menunggu Verifikasi
      // resolutionStatus awal : Belum Ditemukan
    );
    AppData.reports.add(report);

    showFeedback(
      context,
      'Laporan terkirim dan menunggu verifikasi admin. Cek di Laporan Saya.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gradientAppBar('Buat Laporan'),
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: FadeSlideIn(
              child: SectionCard(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Jenis laporan'),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ReportType>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<ReportType>(
                              value: ReportType.lost,
                              label: Text('Barang Hilang'),
                            ),
                            ButtonSegment<ReportType>(
                              value: ReportType.found,
                              label: Text('Barang Ditemukan'),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (selection) {
                            setState(() => _type = selection.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nama barang',
                          hintText: 'Contoh: Kartu Mahasiswa',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Nama barang wajib diisi';
                          if (text.length < 3) {
                            return 'Nama barang minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) =>
                            value == null ? 'Pilih kategori barang' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Ciri-ciri barang',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.notes_outlined),
                          ),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Deskripsi wajib diisi';
                          if (text.length < 10) {
                            return 'Deskripsi minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _locationController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: _isLost
                              ? 'Lokasi kehilangan'
                              : 'Lokasi ditemukan',
                          hintText: 'Contoh: Gedung A Lantai 2',
                          prefixIcon: const Icon(Icons.place_outlined),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Lokasi wajib diisi';
                          if (text.length < 3) {
                            return 'Lokasi minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: _isLost
                              ? 'Tanggal kehilangan'
                              : 'Tanggal ditemukan',
                          prefixIcon: const Icon(Icons.event_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Tanggal wajib dipilih'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        icon: Icons.send_outlined,
                        label: 'Kirim Laporan',
                        onPressed: _submit,
                        expanded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 9. BOTTOM SHEET: PEMILIK MENEMUKAN BARANGNYA SENDIRI (skenario baru)
// =============================================================================

class SelfFoundSheet extends StatefulWidget {
  final LostFoundReport report;
  const SelfFoundSheet({super.key, required this.report});

  @override
  State<SelfFoundSheet> createState() => _SelfFoundSheetState();
}

class _SelfFoundSheetState extends State<SelfFoundSheet> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(DateTime.now());
    _dateController.text = formatDate(_date);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickCampusDate(
      context,
      _date,
      'Pilih tanggal ditemukan',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate())
      return; // data tidak valid -> berhenti

    final report = widget.report;
    // Status berubah menjadi "Menunggu Persetujuan Admin" (belum final).
    report.selfFoundLocation = _locationController.text.trim();
    report.selfFoundDate = _date;
    report.selfFoundNote = _noteController.text.trim();
    report.resolutionStatus = ResolutionStatus.selfFoundPending;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CategoryTile(category: widget.report.category, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Barangmu sudah ketemu?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          widget.report.itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const InfoBanner(
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.blue,
                text: 'Permintaanmu akan ditinjau admin dulu. Laporan baru ditandai "Sudah Ditemukan" setelah admin menyetujui.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Di mana barang ditemukan?',
                  hintText: 'Contoh: Ternyata ada di tas sendiri',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Lokasi wajib diisi';
                  if (text.length < 3) return 'Lokasi minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal ditemukan',
                  prefixIcon: Icon(Icons.event_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Tanggal wajib dipilih'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noteController,
                minLines: 2,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Ceritakan singkat bagaimana barang ditemukan',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Keterangan wajib diisi';
                  if (text.length < 10) return 'Keterangan minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Kirim Permintaan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 10. SCREEN: DETAIL LAPORAN (dipakai Mahasiswa pemilik, Mahasiswa lain, dan Admin)
// =============================================================================

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool get _isAdmin => AppData.currentRole == UserRole.admin;

  /// Pemilik laporan = mahasiswa yang sedang login dan pelapor laporan ini.
  bool _isOwner(LostFoundReport report) =>
      AppData.currentRole == UserRole.student &&
      report.reporter == AppData.currentUser;

  // ---------- Aksi Admin: setujui / tolak laporan ----------
  Future<void> _decideReport(LostFoundReport report, bool approve) async {
    if (!_isAdmin) return; // hak akses: hanya admin
    if (!approve) {
      final ok = await showConfirmDialog(
        context,
        title: 'Tolak laporan?',
        message:
            'Laporan "${report.itemName}" tidak akan tampil ke mahasiswa lain. Pelapor masih bisa mengajukan verifikasi ulang.',
        confirmLabel: 'Ya, Tolak',
        isDanger: true,
      );
      if (!ok || !mounted) return;
    }
    setState(() {
      report.verificationStatus = approve
          ? VerificationStatus.approved
          : VerificationStatus.rejected;
    });
    showFeedback(
      context,
      approve
          ? 'Laporan disetujui dan kini terlihat oleh mahasiswa lain.'
          : 'Laporan ditolak.',
      isError: !approve,
    );
  }

  // ---------- Aksi Pemilik: ajukan verifikasi ulang ----------
  void _requestReverify(LostFoundReport report) {
    if (!_isOwner(report)) return;
    if (report.verificationStatus != VerificationStatus.rejected) return;
    setState(() => report.verificationStatus = VerificationStatus.reverify);
    showFeedback(context, 'Pengajuan verifikasi ulang dikirim ke admin.');
  }

  // ---------- Aksi Pemilik: konfirmasi barang diterima ----------
  Future<void> _confirmReceived(LostFoundReport report) async {
    if (!_isOwner(report)) return; // hanya pemilik yang boleh mengonfirmasi
    final ok = await showConfirmDialog(
      context,
      title: 'Konfirmasi penerimaan',
      message:
          'Pastikan barang "${report.itemName}" benar-benar sudah kamu terima. Laporan akan ditandai selesai.',
      confirmLabel: 'Ya, Sudah Saya Terima',
    );
    if (!ok || !mounted) return;
    setState(() {
      report.resolutionStatus = ResolutionStatus.returned;
      report.resolvedAt = DateUtils.dateOnly(DateTime.now());
      final submission = AppData.acceptedSubmissionFor(report.id);
      if (submission != null) submission.status = SubmissionStatus.done;
    });
    showFeedback(context, 'Terima kasih! Barang ditandai sudah dikembalikan.');
  }

  // ---------- Aksi Pemilik: barang belum diterima ----------
  Future<void> _confirmNotReceived(LostFoundReport report) async {
    if (!_isOwner(report)) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Barang belum diterima?',
      message: 'Status laporan akan menjadi "Perlu Tindak Lanjut" dan admin akan melihatnya. Laporan tidak ditandai selesai.',
      confirmLabel: 'Ya, Belum Diterima',
      isDanger: true,
    );
    if (!ok || !mounted) return;
    setState(() => report.resolutionStatus = ResolutionStatus.followUp);
    showFeedback(
      context,
      'Status diubah menjadi Perlu Tindak Lanjut.',
      isError: true,
    );
  }

  // ---------- Aksi Pemilik: barang ditemukan sendiri (butuh approval admin) ----------
  Future<void> _openSelfFoundSheet(LostFoundReport report) async {
    if (!_isOwner(report)) return;
    if (report.type != ReportType.lost ||
        report.verificationStatus != VerificationStatus.approved ||
        report.resolutionStatus != ResolutionStatus.notFound) {
      return;
    }
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 560),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SelfFoundSheet(report: report),
    );
    if (sent == true && mounted) {
      setState(() {});
      showFeedback(
        context,
        'Permintaan terkirim. Status menunggu persetujuan admin.',
      );
    }
  }

  // ---------- Aksi Pemilik: batalkan permintaan "ditemukan sendiri" ----------
  Future<void> _cancelSelfFound(LostFoundReport report) async {
    if (!_isOwner(report)) return;
    if (report.resolutionStatus != ResolutionStatus.selfFoundPending) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Batalkan permintaan?',
      message: 'Laporan kembali ke status "Belum Ditemukan" dan tetap bisa dicari mahasiswa lain.',
      confirmLabel: 'Ya, Batalkan',
      isDanger: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      report.resolutionStatus = ResolutionStatus.notFound;
      report.clearSelfFoundData();
    });
    showFeedback(
      context,
      'Permintaan dibatalkan. Status kembali Belum Ditemukan.',
    );
  }

  // ---------- Aksi Admin: setujui / tolak klaim "ditemukan sendiri" ----------
  Future<void> _decideSelfFound(LostFoundReport report, bool approve) async {
    if (!_isAdmin) return; // hak akses: hanya admin
    if (report.resolutionStatus != ResolutionStatus.selfFoundPending) return;

    if (!approve) {
      final ok = await showConfirmDialog(
        context,
        title: 'Tolak klaim pemilik?',
        message:
            'Laporan "${report.itemName}" kembali ke status "Belum Ditemukan" dan tetap bisa dicari mahasiswa lain.',
        confirmLabel: 'Ya, Tolak',
        isDanger: true,
      );
      if (!ok || !mounted) return;
    }

    setState(() {
      if (approve) {
        report.resolutionStatus = ResolutionStatus.selfFound;
        report.resolvedAt = DateUtils.dateOnly(DateTime.now());
        // Pengajuan penemu yang masih menunggu otomatis ditutup.
        for (final s in AppData.submissionsFor(report.id)) {
          if (s.status == SubmissionStatus.pending) {
            s.status = SubmissionStatus.rejected;
          }
        }
      } else {
        report.resolutionStatus = ResolutionStatus.notFound;
        report.clearSelfFoundData();
      }
    });

    showFeedback(
      context,
      approve
          ? 'Klaim disetujui. Laporan ditandai Sudah Ditemukan.'
          : 'Klaim ditolak. Laporan kembali Belum Ditemukan.',
      isError: !approve,
    );
  }

  void _openFoundForm(LostFoundReport report) {
    Navigator.push(
      context,
      appRoute(FoundSubmissionFormScreen(reportId: report.id)),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  // ---------- Bagian informasi penemu ----------
  List<Widget> _buildFinderSection(LostFoundReport report) {
    if (_isAdmin) {
      final submissions = AppData.submissionsFor(report.id);
      if (submissions.isEmpty) return [];
      return [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Pengajuan Penemuan'),
              for (var i = 0; i < submissions.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                SubmissionInfo(submission: submissions[i]),
              ],
            ],
          ),
        ),
      ];
    }
    if (_isOwner(report)) {
      final accepted = AppData.acceptedSubmissionFor(report.id);
      if (accepted == null) return [];
      return [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('${accepted.finder} menemukan barangmu'),
              SubmissionInfo(submission: accepted),
            ],
          ),
        ),
      ];
    }
    return [];
  }

  // ---------- Tombol & info sesuai peran dan status ----------
  List<Widget> _buildActions(LostFoundReport report) {
    final widgets = <Widget>[];
    final isLost = report.type == ReportType.lost;

    // ===== ADMIN =====
    if (_isAdmin) {
      final needsVerification =
          report.verificationStatus == VerificationStatus.pending ||
          report.verificationStatus == VerificationStatus.reverify;
      if (needsVerification) {
        widgets.add(
          const InfoBanner(
            icon: Icons.fact_check_outlined,
            color: AppColors.blue,
            text: 'Periksa data laporan ini, lalu setujui atau tolak.',
          ),
        );
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          DecisionRow(
            onReject: () => _decideReport(report, false),
            onApprove: () => _decideReport(report, true),
          ),
        );
      }
      if (isLost &&
          report.resolutionStatus == ResolutionStatus.selfFoundPending) {
        widgets.add(
          const InfoBanner(
            icon: Icons.task_alt,
            color: AppColors.teal,
            text: 'Pemilik melaporkan sudah menemukan barangnya sendiri. Periksa keterangannya, lalu setujui atau tolak.',
          ),
        );
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          DecisionRow(
            rejectLabel: 'Tolak Klaim',
            approveLabel: 'Setujui Klaim',
            onReject: () => _decideSelfFound(report, false),
            onApprove: () => _decideSelfFound(report, true),
          ),
        );
      }
      if (isLost && report.resolutionStatus == ResolutionStatus.followUp) {
        widgets.add(
          const InfoBanner(
            icon: Icons.report_problem_outlined,
            color: AppColors.danger,
            text:
                'Pemilik melaporkan belum menerima barang. Proses belum selesai dan perlu ditindaklanjuti. '
                'Admin tidak dapat mengubah status menjadi Sudah Dikembalikan; hanya pemilik laporan yang bisa.',
          ),
        );
      }
      return widgets;
    }

    // ===== PEMILIK LAPORAN =====
    if (_isOwner(report)) {
      switch (report.verificationStatus) {
        case VerificationStatus.pending:
        case VerificationStatus.reverify:
          widgets.add(
            const InfoBanner(
              icon: Icons.hourglass_top,
              color: AppColors.warning,
              text: 'Laporanmu sedang menunggu verifikasi admin. Setelah disetujui, laporan terlihat oleh mahasiswa lain.',
            ),
          );
          return widgets;
        case VerificationStatus.rejected:
          widgets.add(
            const InfoBanner(
              icon: Icons.cancel_outlined,
              color: AppColors.danger,
              text: 'Laporanmu ditolak admin sehingga belum tampil ke mahasiswa lain. Kamu bisa mengajukan verifikasi ulang.',
            ),
          );
          widgets.add(const SizedBox(height: 12));
          widgets.add(
            FilledButton.icon(
              onPressed: () => _requestReverify(report),
              icon: const Icon(Icons.refresh),
              label: const Text('Ajukan Verifikasi Ulang'),
            ),
          );
          return widgets;
        case VerificationStatus.approved:
          break;
      }

      final accepted = AppData.acceptedSubmissionFor(report.id);
      if (isLost && report.resolutionStatus == ResolutionStatus.notFound) {
        widgets.add(
          const InfoBanner(
            icon: Icons.search,
            color: AppColors.blue,
            text: 'Laporanmu sudah terverifikasi dan dapat dilihat mahasiswa lain. Jika barang sudah ketemu, kamu bisa mengubah statusnya (perlu persetujuan admin).',
          ),
        );
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () => _openSelfFoundSheet(report),
            icon: const Icon(Icons.task_alt),
            label: const Text('Saya Sudah Menemukan Sendiri'),
          ),
        );
      } else if (report.resolutionStatus == ResolutionStatus.selfFoundPending) {
        widgets.add(
          const InfoBanner(
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.warning,
            text: 'Permintaanmu "barang sudah ditemukan" sedang menunggu persetujuan admin. Laporan belum ditandai selesai.',
          ),
        );
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            onPressed: () => _cancelSelfFound(report),
            icon: const Icon(Icons.undo),
            label: const Text('Batalkan Permintaan'),
          ),
        );
      } else if (report.resolutionStatus == ResolutionStatus.selfFound) {
        widgets.add(
          InfoBanner(
            icon: Icons.task_alt,
            color: AppColors.teal,
            text:
                'Admin menyetujui bahwa barangmu sudah ditemukan${report.resolvedAt == null ? '' : ' pada ${formatDate(report.resolvedAt!)}'}. Laporan selesai.',
          ),
        );
      } else if (report.resolutionStatus == ResolutionStatus.awaitingOwner ||
          report.resolutionStatus == ResolutionStatus.followUp) {
        widgets.add(
          InfoBanner(
            icon: Icons.volunteer_activism_outlined,
            color: AppColors.warning,
            text: accepted == null
                ? 'Ada penemuan barang yang menunggu konfirmasimu.'
                : '${accepted.finder} telah melaporkan penemuan barangmu. Konfirmasi setelah kamu menerima barangnya.',
          ),
        );
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => _confirmReceived(report),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Barang Sudah Saya Terima'),
          ),
        );
        if (report.resolutionStatus == ResolutionStatus.awaitingOwner) {
          widgets.add(const SizedBox(height: 10));
          widgets.add(
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () => _confirmNotReceived(report),
              icon: const Icon(Icons.highlight_off),
              label: const Text('Saya Belum Menerima Barang'),
            ),
          );
        }
      } else if (report.resolutionStatus == ResolutionStatus.returned) {
        widgets.add(
          InfoBanner(
            icon: Icons.verified_outlined,
            color: AppColors.success,
            text:
                'Barang sudah dikembalikan${report.resolvedAt == null ? '' : ' pada ${formatDate(report.resolvedAt!)}'}. Laporan selesai.',
          ),
        );
      }
      return widgets;
    }

    // ===== MAHASISWA LAIN =====
    if (!isLost) {
      widgets.add(
        const InfoBanner(
          icon: Icons.info_outline,
          color: AppColors.blue,
          text: 'Ini laporan barang yang ditemukan. Jika barang ini milikmu, hubungi admin kampus.',
        ),
      );
      return widgets;
    }

    if (report.resolutionStatus == ResolutionStatus.returned ||
        report.resolutionStatus == ResolutionStatus.selfFound) {
      widgets.add(
        const InfoBanner(
          icon: Icons.verified_outlined,
          color: AppColors.success,
          text: 'Barang ini sudah kembali kepada pemiliknya.',
        ),
      );
      return widgets;
    }

    if (report.resolutionStatus == ResolutionStatus.selfFoundPending) {
      widgets.add(
        const InfoBanner(
          icon: Icons.hourglass_top,
          color: AppColors.warning,
          text: 'Pemilik melaporkan sudah menemukan barangnya sendiri. Menunggu persetujuan admin.',
        ),
      );
      return widgets;
    }

    if (AppData.activeSubmissionFor(report.id) != null) {
      widgets.add(
        const InfoBanner(
          icon: Icons.hourglass_top,
          color: AppColors.warning,
          text: 'Sudah ada pengajuan penemuan untuk laporan ini yang sedang diproses admin.',
        ),
      );
      return widgets;
    }

    widgets.add(
      FilledButton.icon(
        onPressed: () => _openFoundForm(report),
        icon: const Icon(Icons.volunteer_activism_outlined),
        label: const Text('Saya Menemukan Barang Ini'),
      ),
    );
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final report = AppData.reportById(widget.reportId);

    if (report == null) {
      return Scaffold(
        appBar: gradientAppBar('Detail Laporan'),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Laporan tidak ditemukan',
          message: 'Data laporan tidak tersedia.',
        ),
      );
    }

    final isLost = report.type == ReportType.lost;
    final showSelfFoundInfo =
        report.selfFoundLocation != null && (_isAdmin || _isOwner(report));

    return Scaffold(
      appBar: gradientAppBar('Detail Laporan'),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 1000,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FadeSlideIn(
                child: TwoPane(
                  left: [
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CategoryTile(category: report.category, size: 58),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  report.itemName,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusBadge(
                                label: report.type.label,
                                color: report.type.color,
                                icon: report.type.icon,
                              ),
                              StatusBadge(
                                label: report.verificationStatus.label,
                                color: report.verificationStatus.color,
                                icon: report.verificationStatus.icon,
                              ),
                              if (isLost &&
                                  report.verificationStatus ==
                                      VerificationStatus.approved)
                                StatusBadge(
                                  label: report.resolutionStatus.label,
                                  color: report.resolutionStatus.color,
                                  icon: report.resolutionStatus.icon,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Informasi Barang'),
                          ReportInfoRows(report: report),
                        ],
                      ),
                    ),
                    if (showSelfFoundInfo)
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle('Penemuan oleh pemilik'),
                            SelfFoundInfo(report: report),
                          ],
                        ),
                      ),
                  ],
                  right: [
                    ..._buildFinderSection(report),
                    ..._buildActions(report),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 11. SCREEN: FORM PENGAJUAN PENEMUAN ("Saya Menemukan Barang Ini")
// =============================================================================

class FoundSubmissionFormScreen extends StatefulWidget {
  final String reportId; // ID laporan kehilangan yang dirujuk
  const FoundSubmissionFormScreen({super.key, required this.reportId});

  @override
  State<FoundSubmissionFormScreen> createState() =>
      _FoundSubmissionFormScreenState();
}

class _FoundSubmissionFormScreenState extends State<FoundSubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  late DateTime _foundDate;

  @override
  void initState() {
    super.initState();
    _foundDate = DateUtils.dateOnly(DateTime.now());
    _dateController.text = formatDate(_foundDate);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickCampusDate(
      context,
      _foundDate,
      'Pilih tanggal ditemukan',
    );
    if (picked != null) {
      setState(() {
        _foundDate = picked;
        _dateController.text = formatDate(picked);
      });
    }
  }

  void _submit(LostFoundReport report) {
    if (!_formKey.currentState!.validate()) {
      showFeedback(
        context,
        'Pengajuan belum bisa dikirim. Lengkapi data yang masih salah.',
        isError: true,
      );
      return;
    }

    // Penjagaan: pemilik tidak boleh mengajukan penemuan untuk laporannya sendiri.
    if (report.reporter == AppData.currentUser) {
      showFeedback(
        context,
        'Kamu tidak bisa mengajukan penemuan untuk laporanmu sendiri.',
        isError: true,
      );
      return;
    }

    // Penjagaan: laporan harus masih berstatus Belum Ditemukan.
    if (report.resolutionStatus != ResolutionStatus.notFound) {
      showFeedback(
        context,
        'Laporan ini sedang diproses atau sudah selesai.',
        isError: true,
      );
      return;
    }

    // Penjagaan: hindari pengajuan ganda yang masih aktif.
    if (AppData.activeSubmissionFor(report.id) != null) {
      showFeedback(
        context,
        'Sudah ada pengajuan aktif untuk laporan ini.',
        isError: true,
      );
      return;
    }

    AppData.submissions.add(
      FoundSubmission(
        id: AppData.nextSubmissionId(),
        lostReportId: report.id, // menghubungkan ke laporan kehilangan
        itemName: report.itemName,
        finder: AppData.currentUser, // penemu otomatis dari username login
        foundLocation: _locationController.text.trim(),
        foundDate: _foundDate,
        description: _descriptionController.text.trim(),
        // status awal: Menunggu Verifikasi
      ),
    );

    showFeedback(
      context,
      'Pengajuan penemuan terkirim dan menunggu verifikasi admin.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final report = AppData.reportById(widget.reportId);

    if (report == null) {
      return Scaffold(
        appBar: gradientAppBar('Pengajuan Penemuan'),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Laporan tidak ditemukan',
          message: 'Data laporan tidak tersedia.',
        ),
      );
    }

    final referenceCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Laporan kehilangan yang dirujuk'),
          Row(
            children: [
              CategoryTile(category: report.category, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  report.itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReportInfoRows(report: report),
        ],
      ),
    );

    final formCard = SectionCard(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Data penemuan'),
            InfoBanner(
              icon: Icons.person_outline,
              color: AppColors.blue,
              text:
                  'Nama penemu otomatis: ${AppData.currentUser} (sesuai akun yang sedang masuk).',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Lokasi barang ditemukan',
                hintText: 'Contoh: Ruang Kelas A.203',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Lokasi penemuan wajib diisi';
                if (text.length < 3) return 'Lokasi minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Tanggal ditemukan',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Tanggal wajib dipilih'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Deskripsi / ciri-ciri barang',
                hintText: 'Jelaskan kondisi barang yang kamu temukan',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Deskripsi wajib diisi';
                if (text.length < 10) return 'Deskripsi minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24),
            GradientButton(
              icon: Icons.send_outlined,
              label: 'Kirim Pengajuan',
              onPressed: () => _submit(report),
              expanded: true,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: gradientAppBar('Saya Menemukan Barang Ini'),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 1000,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: FadeSlideIn(
              child: TwoPane(left: [referenceCard], right: [formCard]),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 12. SHELL ADMIN: Laporan, Pengajuan, Klaim Mandiri, Status Barang
// =============================================================================

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _index = 0; // state: tab aktif

  void _open(Widget screen) {
    Navigator.push(context, appRoute(screen)).then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Urutan prioritas pada tab Status Barang (yang perlu perhatian di atas).
  int _priority(LostFoundReport report) {
    switch (report.resolutionStatus) {
      case ResolutionStatus.followUp:
        return 4;
      case ResolutionStatus.selfFoundPending:
        return 3;
      case ResolutionStatus.awaitingOwner:
        return 2;
      case ResolutionStatus.notFound:
        return 1;
      case ResolutionStatus.returned:
      case ResolutionStatus.selfFound:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingReports = AppData.reports
        .where(
          (r) =>
              r.verificationStatus == VerificationStatus.pending ||
              r.verificationStatus == VerificationStatus.reverify,
        )
        .toList()
        .reversed
        .toList();

    final pendingSubmissions = AppData.submissions
        .where((s) => s.status == SubmissionStatus.pending)
        .toList()
        .reversed
        .toList();

    final selfFoundClaims = AppData.approvedReports
        .where(
          (r) =>
              r.type == ReportType.lost &&
              r.resolutionStatus == ResolutionStatus.selfFoundPending,
        )
        .toList();

    final statusReports =
        AppData.approvedReports.where((r) => r.type == ReportType.lost).toList()
          ..sort((a, b) => _priority(b).compareTo(_priority(a)));

    final followUpCount = statusReports
        .where((r) => r.resolutionStatus == ResolutionStatus.followUp)
        .length;

    // ----- Judul & isi tiap tab -----
    final titles = [
      'Verifikasi Laporan',
      'Pengajuan Penemuan',
      'Klaim Ditemukan Sendiri',
      'Status Barang',
    ];
    final subtitles = [
      'Setujui atau tolak laporan baru dari mahasiswa',
      'Periksa penemuan barang yang diajukan mahasiswa lain',
      'Pemilik yang menemukan barangnya sendiri menunggu persetujuan',
      'Pantau penyelesaian semua laporan kehilangan',
    ];

    Widget content;
    switch (_index) {
      case 0:
        content = pendingReports.isEmpty
            ? const EmptyState(
                icon: Icons.task_alt,
                title: 'Semua laporan sudah diverifikasi',
                message: 'Laporan baru dari mahasiswa akan muncul di sini.',
              )
            : ResponsiveGrid(
                children: [
                  for (final report in pendingReports)
                    ReportCard(
                      report: report,
                      showVerification: true,
                      showReporter: true,
                      onTap: () =>
                          _open(ReportDetailScreen(reportId: report.id)),
                    ),
                ],
              );
        break;
      case 1:
        content = pendingSubmissions.isEmpty
            ? const EmptyState(
                icon: Icons.volunteer_activism_outlined,
                title: 'Belum ada pengajuan menunggu',
                message:
                    'Pengajuan penemuan dari mahasiswa akan muncul di sini.',
              )
            : ResponsiveGrid(
                children: [
                  for (final submission in pendingSubmissions)
                    SubmissionCard(
                      submission: submission,
                      onTap: () => _open(
                        SubmissionDetailScreen(submissionId: submission.id),
                      ),
                    ),
                ],
              );
        break;
      case 2:
        content = selfFoundClaims.isEmpty
            ? const EmptyState(
                icon: Icons.task_alt,
                title: 'Belum ada klaim menunggu',
                message: 'Saat pemilik mengubah status laporannya menjadi sudah ditemukan, klaimnya muncul di sini.',
              )
            : ResponsiveGrid(
                children: [
                  for (final report in selfFoundClaims)
                    ReportCard(
                      report: report,
                      showReporter: true,
                      onTap: () =>
                          _open(ReportDetailScreen(reportId: report.id)),
                    ),
                ],
              );
        break;
      default:
        content = statusReports.isEmpty
            ? const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Belum ada laporan terverifikasi',
                message: 'Status penyelesaian barang akan tampil di sini.',
              )
            : ResponsiveGrid(
                children: [
                  for (final report in statusReports)
                    ReportCard(
                      report: report,
                      showReporter: true,
                      showFinder: true,
                      onTap: () =>
                          _open(ReportDetailScreen(reportId: report.id)),
                    ),
                ],
              );
    }

    final page = PageBody(
      hero: HeroHeader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderGreeting(
              title: titles[_index],
              subtitle: subtitles[_index],
              onLogout: isDesktop(context)
                  ? null
                  : () => logoutToLogin(context),
            ),
            const SizedBox(height: 18),
            StatGrid(
              minTileWidth: 150,
              tiles: [
                StatTileData(
                  Icons.assignment_late_outlined,
                  pendingReports.length,
                  'Laporan menunggu',
                ),
                StatTileData(
                  Icons.volunteer_activism_outlined,
                  pendingSubmissions.length,
                  'Pengajuan menunggu',
                ),
                StatTileData(
                  Icons.task_alt,
                  selfFoundClaims.length,
                  'Klaim menunggu',
                ),
                StatTileData(
                  Icons.report_problem_outlined,
                  followUpCount,
                  'Perlu tindak lanjut',
                ),
              ],
            ),
          ],
        ),
      ),
      children: [content],
    );

    return AppShell(
      userName: AppData.currentUser,
      roleLabel: 'Admin',
      selectedIndex: _index,
      onSelect: (i) => setState(() => _index = i),
      onLogout: () => logoutToLogin(context),
      items: [
        NavItem(
          icon: Icons.assignment_late_outlined,
          selectedIcon: Icons.assignment_late,
          label: 'Laporan',
          badge: pendingReports.length,
        ),
        NavItem(
          icon: Icons.volunteer_activism_outlined,
          selectedIcon: Icons.volunteer_activism,
          label: 'Pengajuan',
          badge: pendingSubmissions.length,
        ),
        NavItem(
          icon: Icons.task_alt_outlined,
          selectedIcon: Icons.task_alt,
          label: 'Klaim',
          badge: selfFoundClaims.length,
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: 'Status',
          badge: followUpCount,
        ),
      ],
      body: animatedTabBody(_index, page),
    );
  }
}

// =============================================================================
// 13. SCREEN: DETAIL PENGAJUAN PENEMUAN (Admin)
// =============================================================================

class SubmissionDetailScreen extends StatefulWidget {
  final String submissionId;
  const SubmissionDetailScreen({super.key, required this.submissionId});

  @override
  State<SubmissionDetailScreen> createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  Future<void> _decide(
    FoundSubmission submission,
    LostFoundReport report,
    bool approve,
  ) async {
    if (AppData.currentRole != UserRole.admin) return; // hanya admin
    if (submission.status != SubmissionStatus.pending) return;

    if (approve && report.resolutionStatus != ResolutionStatus.notFound) {
      showFeedback(
        context,
        'Laporan ini sudah memiliki proses penemuan lain.',
        isError: true,
      );
      return;
    }

    if (!approve) {
      final ok = await showConfirmDialog(
        context,
        title: 'Tolak pengajuan?',
        message:
            'Pengajuan dari ${submission.finder} akan ditolak. Laporan "${report.itemName}" tetap dapat dicari mahasiswa lain.',
        confirmLabel: 'Ya, Tolak',
        isDanger: true,
      );
      if (!ok || !mounted) return;
    }

    setState(() {
      if (approve) {
        submission.status = SubmissionStatus.approved;
        // Laporan pemilik menunggu konfirmasi dari pemilik (BUKAN langsung selesai).
        report.resolutionStatus = ResolutionStatus.awaitingOwner;
      } else {
        submission.status = SubmissionStatus.rejected;
        // Status laporan tetap Belum Ditemukan.
      }
    });

    showFeedback(
      context,
      approve
          ? 'Pengajuan disetujui. Laporan kini menunggu konfirmasi pemilik.'
          : 'Pengajuan ditolak. Laporan tetap Belum Ditemukan.',
      isError: !approve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final submission = AppData.submissionById(widget.submissionId);
    final report = submission == null
        ? null
        : AppData.reportById(submission.lostReportId);

    if (submission == null || report == null) {
      return Scaffold(
        appBar: gradientAppBar('Detail Pengajuan'),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Data tidak ditemukan',
          message: 'Pengajuan atau laporan terkait tidak tersedia.',
        ),
      );
    }

    final referenceCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Laporan kehilangan (referensi)'),
          Row(
            children: [
              CategoryTile(category: report.category, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  report.itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReportInfoRows(report: report),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge(
                label: report.verificationStatus.label,
                color: report.verificationStatus.color,
                icon: report.verificationStatus.icon,
              ),
              StatusBadge(
                label: report.resolutionStatus.label,
                color: report.resolutionStatus.color,
                icon: report.resolutionStatus.icon,
              ),
            ],
          ),
        ],
      ),
    );

    final submissionCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Informasi penemuan'),
          SubmissionInfo(submission: submission),
        ],
      ),
    );

    final actions = <Widget>[
      if (submission.status == SubmissionStatus.pending) ...[
        const InfoBanner(
          icon: Icons.fact_check_outlined,
          color: AppColors.blue,
          text: 'Bandingkan laporan pemilik dengan informasi penemuan, lalu setujui atau tolak.',
        ),
        const SizedBox(height: 12),
        DecisionRow(
          onReject: () => _decide(submission, report, false),
          onApprove: () => _decide(submission, report, true),
        ),
      ] else
        InfoBanner(
          icon: submission.status.icon,
          color: submission.status.color,
          text:
              'Pengajuan ini berstatus "${submission.status.label}". Hanya pemilik laporan yang dapat mengonfirmasi barang sudah diterima.',
        ),
    ];

    return Scaffold(
      appBar: gradientAppBar('Detail Pengajuan Penemuan'),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 1000,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FadeSlideIn(
                child: TwoPane(
                  left: [referenceCard],
                  right: [submissionCard, ...actions],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
