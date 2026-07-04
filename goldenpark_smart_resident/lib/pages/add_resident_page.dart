import 'package:flutter/material.dart';
import '../models/resident_model.dart';
import '../services/api_service.dart';

class AddResidentPage extends StatefulWidget {
  const AddResidentPage({super.key});

  @override
  State<AddResidentPage> createState() => _AddResidentPageState();
}

class _AddResidentPageState extends State<AddResidentPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final blokController = TextEditingController();
  final nomorController = TextEditingController();
  final hpController = TextEditingController();

  DateTime? tanggalMasuk;

  String status = "Aktif";

  bool loading = false;

  Future<void> saveResident() async {
    if (!_formKey.currentState!.validate()) return;

    if (tanggalMasuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih tanggal masuk"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final resident = Resident(
      nama: namaController.text.trim(),
      blok: blokController.text.trim(),
      nomorRumah: nomorController.text.trim(),
      noHp: hpController.text.trim(),
      tanggalMasuk: tanggalMasuk!.toIso8601String().substring(0, 10),
      status: status,
    );

    final success = await ApiService.addResident(resident);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan"),
        ),
      );
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    blokController.dispose();
    nomorController.dispose();
    hpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Resident",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Wajib diisi"
                    : null,
              ),

              TextFormField(
                controller: blokController,
                decoration: const InputDecoration(
                  labelText: "Blok",
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Wajib diisi"
                    : null,
              ),

              TextFormField(
                controller: nomorController,
                decoration: const InputDecoration(
                  labelText: "Nomor Rumah",
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Wajib diisi"
                    : null,
              ),

              TextFormField(
                controller: hpController,
                decoration: const InputDecoration(
                  labelText: "Nomor HP",
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Wajib diisi"
                    : null,
              ),

              const SizedBox(height: 20),

              ListTile(
                title: Text(
                  tanggalMasuk == null
                      ? "Pilih Tanggal"
                      : tanggalMasuk.toString().substring(0, 10),
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDate: DateTime.now(),
                  );

                  if (date != null) {
                    setState(() {
                      tanggalMasuk = date;
                    });
                  }
                },
              ),

              DropdownButtonFormField(
                value: status,
                items: const [
                  DropdownMenuItem(
                    value: "Aktif",
                    child: Text(
                      "Aktif",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "Non Aktif",
                    child: Text(
                      "Non Aktif",
                    ),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    status = v!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : saveResident,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Simpan",
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
