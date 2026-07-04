import 'package:flutter/material.dart';
import '../models/resident_model.dart';
import '../services/api_service.dart';
import 'add_resident_page.dart';
import 'edit_resident_page.dart';

class ResidentPage extends StatefulWidget {
  const ResidentPage({super.key});

  @override
  State<ResidentPage> createState() => _ResidentPageState();
}

class _ResidentPageState extends State<ResidentPage> {
  late Future<List<Resident>> residents;

  @override
  void initState() {
    super.initState();
    loadResidents();
  }

  void loadResidents() {
    residents = ApiService.getResidents();
  }

  Future<void> refreshResidents() async {
    setState(() {
      loadResidents();
    });
  }

  Future<void> deleteResident(Resident resident) async {
    final id = resident.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resident tidak memiliki ID valid"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Resident"),
        content: Text("Apakah Anda yakin ingin menghapus ${resident.nama}?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteResident(id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Resident berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );

        refreshResidents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menghapus resident"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> openAddResidentPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddResidentPage(),
      ),
    );

    if (result == true) {
      refreshResidents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Resident Management"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshResidents,
        child: FutureBuilder<List<Resident>>(
          future: residents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 220),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: Text(
                      "Belum ada data resident",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              );
            }

            final residentList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: residentList.length,
              itemBuilder: (context, index) {
                final resident = residentList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    onLongPress: () => deleteResident(resident),
                    //
                    onTap: () async {
                      if (resident.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Resident tidak memiliki ID valid"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditResidentPage(resident: resident),
                        ),
                      );

                      if (result == true) {
                        refreshResidents();
                      }
                    },
                    //
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.15),
                      child: Text(
                        resident.blok,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      resident.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Blok ${resident.blok}-${resident.nomorRumah}\nHP: ${resident.noHp}",
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: resident.status == "Aktif"
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        resident.status,
                        style: TextStyle(
                          color: resident.status == "Aktif"
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddResidentPage,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
