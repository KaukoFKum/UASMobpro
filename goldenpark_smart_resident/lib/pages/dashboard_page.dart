import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../models/resident_model.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Resident>> residents;

  final LatLng goldenParkCenter = const LatLng(-6.2635, 106.6635);

  @override
  void initState() {
    super.initState();
    residents = ApiService.getResidents();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  String getAdminName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "Admin GoldenPark";
  }

  String getTodayText() {
    const days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    final now = DateTime.now();
    return "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  String getTimeText() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$hour:$minute WIB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F4),
      appBar: AppBar(
        title: const Text("GoldenPark Smart Resident"),
        backgroundColor: const Color(0xff1F7A3A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Tombol Darurat"),
              content: const Text(
                "Simulasi tombol panic keamanan. Dalam aplikasi nyata, tombol ini dapat terhubung ke satpam atau pengurus RW.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text("PANIC"),
      ),
      body: FutureBuilder<List<Resident>>(
        future: residents,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          final isApiConnected =
              !snapshot.hasError && snapshot.connectionState == ConnectionState.done;
          final totalResident = data.length;
          final aktif = data.where((e) => e.status == "Aktif").length;
          final nonAktif = data.where((e) => e.status != "Aktif").length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildSystemStatus(isApiConnected: isApiConnected),
                  if (snapshot.hasError) ...[
                    const SizedBox(height: 12),
                    _errorBanner(snapshot.error.toString()),
                  ],
                  const SizedBox(height: 18),
                  _sectionTitle("Statistik Kependudukan"),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: isWide ? 6 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.45 : 1.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _statCard("Total Resident", "$totalResident", Icons.people, Colors.blue),
                      _statCard("Resident Aktif", "$aktif", Icons.verified_user, Colors.green),
                      _statCard("Non Aktif", "$nonAktif", Icons.block, Colors.redAccent),
                      _statCard("Total KK", "240", Icons.home, Colors.orange),
                      _statCard("Rumah Terdata", "240", Icons.house, Colors.deepPurple),
                      _statCard("Total RT", "5", Icons.location_city, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildFinanceCard()),
                        const SizedBox(width: 14),
                        Expanded(child: _buildIplProgress()),
                        const SizedBox(width: 14),
                        Expanded(child: _buildNotificationCard()),
                      ],
                    )
                  else ...[
                    _buildFinanceCard(),
                    const SizedBox(height: 14),
                    _buildIplProgress(),
                    const SizedBox(height: 14),
                    _buildNotificationCard(),
                  ],
                  const SizedBox(height: 18),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMiniMap()),
                        const SizedBox(width: 14),
                        Expanded(child: _buildQuickAction()),
                      ],
                    )
                  else ...[
                    _buildMiniMap(),
                    const SizedBox(height: 14),
                    _buildQuickAction(),
                  ],
                  const SizedBox(height: 18),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDemography()),
                        const SizedBox(width: 14),
                        Expanded(child: _buildTodayActivity()),
                        const SizedBox(width: 14),
                        Expanded(child: _buildInfoRw()),
                      ],
                    )
                  else ...[
                    _buildDemography(),
                    const SizedBox(height: 14),
                    _buildTodayActivity(),
                    const SizedBox(height: 14),
                    _buildInfoRw(),
                  ],
                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff063D2A),
            Color(0xff1F7A3A),
            Color(0xff4CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Image.asset(
              'assets/images/logo_goldenparkserpong.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  getAdminName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Administrator RW 09 Golden Park Serpong",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _headerChip(Icons.calendar_month, getTodayText()),
                    _headerChip(Icons.access_time, getTimeText()),
                    _headerChip(Icons.wb_sunny_outlined, "29 C Cerah"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSystemStatus({required bool isApiConnected}) {
    return _panel(
      title: "Status Sistem",
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          _statusChip("System Online"),
          _statusChip("Firebase Connected"),
          _statusChip(
            isApiConnected ? "Laravel API Connected" : "Laravel API Offline",
            ok: isApiConnected,
          ),
          _statusChip("Maps Connected"),
        ],
      ),
    );
  }

  Widget _statusChip(String label, {bool ok = true}) {
    final color = ok ? Colors.green : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Data dashboard",
                  style: TextStyle(color: Colors.black38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard() {
    return _panel(
      title: "Ringkasan Keuangan RW",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _miniFinance("Pemasukan", "Rp 75.000.000", Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _miniFinance("Pengeluaran", "Rp 48.500.000", Colors.redAccent)),
              const SizedBox(width: 10),
              Expanded(child: _miniFinance("Saldo Kas", "Rp 235.000.000", Colors.blue)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: SimpleLineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFinance(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIplProgress() {
    return _panel(
      title: "Progress Pembayaran IPL",
      child: Column(
        children: [
          SizedBox(
            height: 145,
            width: 145,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 13,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xff1F7A3A),
                ),
                const Center(
                  child: Text(
                    "72%",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1F7A3A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "173 / 240 rumah sudah bayar",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.72,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xff1F7A3A),
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return _panel(
      title: "Notifikasi Penting",
      child: Column(
        children: [
          _alertTile(Icons.warning, "Tombol Panic Keamanan", "Darurat? Hubungi satpam RW", Colors.red),
          _alertTile(Icons.notifications, "3 Laporan Belum Diproses", "Segera tindak lanjuti laporan", Colors.orange),
          _alertTile(Icons.event, "Kegiatan Terdekat", "Kerja bakti Ahad 07.00 WIB", Colors.blue),
          _alertTile(Icons.payments, "Iuran Bulan Juli", "Batas pembayaran 10 Juli", Colors.green),
        ],
      ),
    );
  }

  Widget _alertTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.13),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return _panel(
      title: "Peta Lingkungan Golden Park",
      trailing: "Lihat Peta",
      child: SizedBox(
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: goldenParkCenter,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.goldenpark_smart_resident',
              ),
              MarkerLayer(
                markers: [
                  _marker(-6.2635, 106.6635, Icons.sports_soccer, Colors.blue, "Sport"),
                  _marker(-6.2640, 106.6640, Icons.mosque, Colors.green, "Masjid"),
                  _marker(-6.2630, 106.6628, Icons.sports_basketball, Colors.orange, "Lapangan"),
                  _marker(-6.2627, 106.6639, Icons.security, Colors.red, "Pos"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _marker(double lat, double lng, IconData icon, Color color, String label) {
    return Marker(
      point: LatLng(lat, lng),
      width: 82,
      height: 60,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label, style: const TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction() {
    return _panel(
      title: "Aksi Cepat",
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.25,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _quick(Icons.person_add, "Tambah Resident", Colors.green),
          _quick(Icons.people, "Data Resident", Colors.blue),
          _quick(Icons.map, "Peta Lingkungan", Colors.teal),
          _quick(Icons.event, "Agenda", Colors.purple),
          _quick(Icons.campaign, "Pengumuman", Colors.orange),
          _quick(Icons.phone, "Kontak", Colors.redAccent),
        ],
      ),
    );
  }

  Widget _quick(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDemography() {
    return _panel(
      title: "Distribusi Usia Resident",
      child: Column(
        children: [
          _demoRow("0 - 17 Tahun", "48", Colors.blue),
          _demoRow("18 - 40 Tahun", "132", Colors.green),
          _demoRow("41 - 60 Tahun", "85", Colors.orange),
          _demoRow("> 60 Tahun", "26", Colors.purple),
        ],
      ),
    );
  }

  Widget _demoRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 8, backgroundColor: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTodayActivity() {
    return _panel(
      title: "Aktivitas Hari Ini",
      child: Column(
        children: [
          _activity(Icons.person_add, "3 Resident Baru", "Data resident baru ditambahkan", Colors.green),
          _activity(Icons.campaign, "1 Pengumuman Baru", "Pengumuman berhasil dipublikasikan", Colors.blue),
          _activity(Icons.assignment_turned_in, "2 Laporan Selesai", "Laporan warga telah ditindaklanjuti", Colors.orange),
          _activity(Icons.login, "5 Visitor Masuk", "Visitor tercatat hari ini", Colors.teal),
        ],
      ),
    );
  }

  Widget _activity(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildInfoRw() {
    return _panel(
      title: "Informasi Lainnya",
      child: Column(
        children: [
          _info(Icons.announcement, "Pengumuman Terbaru", "Pemasangan CCTV area Blok E dan F"),
          _info(Icons.photo_library, "Galeri Kegiatan", "Dokumentasi kegiatan RW terbaru"),
          _info(Icons.contact_phone, "Kontak Pengurus", "Daftar kontak pengurus dan seksi"),
          _info(Icons.videocam, "CCTV Online", "Pantau CCTV lingkungan RW"),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String title, String subtitle) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: Colors.green.withOpacity(0.10),
        child: Icon(icon, color: const Color(0xff1F7A3A), size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _panel({
    required String title,
    String? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: const TextStyle(
                    color: Color(0xff1F7A3A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}

class SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.20)
      ..strokeWidth = 1;

    final greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final redPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Path buildPath(List<double> values) {
      final path = Path();
      for (int i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1);
        final y = size.height - (values[i] * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    canvas.drawPath(buildPath([0.25, 0.45, 0.40, 0.60, 0.50, 0.70]), greenPaint);
    canvas.drawPath(buildPath([0.15, 0.20, 0.18, 0.30, 0.25, 0.35]), redPaint);
    canvas.drawPath(buildPath([0.50, 0.70, 0.65, 0.80, 0.70, 0.88]), bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
