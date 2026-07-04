import 'package:flutter/material.dart';
import '../models/resident_model.dart';
import '../services/api_service.dart';

class EditResidentPage extends StatefulWidget {
  final Resident resident;

  const EditResidentPage({
    super.key,
    required this.resident,
  });

  @override
  State<EditResidentPage> createState() => _EditResidentPageState();
}

class _EditResidentPageState extends State<EditResidentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController blokController;
  late TextEditingController nomorController;
  late TextEditingController hpController;

  DateTime? tanggalMasuk;
  String status = "Aktif";
  bool loading = false;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(text: widget.resident.nama);
    blokController = TextEditingController(text: widget.resident.blok);
    nomorController = TextEditingController(text: widget.resident.nomorRumah);
    hpController = TextEditingController(text: widget.resident.noHp);

    tanggalMasuk = DateTime.tryParse(widget.resident.tanggalMasuk);
    status = widget.resident.status;
  }

  Future<void> updateResident() async {
    if (!_formKey.currentState!.validate()) return;

    final residentId = widget.resident.id;
    if (residentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resident tidak memiliki ID valid"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (tanggalMasuk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih tanggal masuk"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final updatedResident = Resident(
      id: widget.resident.id,
      nama: namaController.text.trim(),
      blok: blokController.text.trim(),
      nomorRumah: nomorController.text.trim(),
      noHp: hpController.text.trim(),
      tanggalMasuk: tanggalMasuk!.toIso8601String().substring(0, 10),
      status: status,
    );

    final success = await ApiService.updateResident(
      residentId,
      updatedResident,
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resident berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memperbarui resident"),
          backgroundColor: Colors.red,
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

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xffF8FAFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label wajib diisi";
          }
          return null;
        },
      ),
    );
  }

  Future<void> pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: tanggalMasuk ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        tanggalMasuk = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggalText = tanggalMasuk == null
        ? "Pilih Tanggal Masuk"
        : tanggalMasuk!.toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Edit Resident"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  size: 70,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Update Data Resident",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 22),
                buildTextField(
                  label: "Nama",
                  controller: namaController,
                  icon: Icons.person_outline,
                ),
                buildTextField(
                  label: "Blok",
                  controller: blokController,
                  icon: Icons.home_work_outlined,
                ),
                buildTextField(
                  label: "Nomor Rumah",
                  controller: nomorController,
                  icon: Icons.house_outlined,
                ),
                buildTextField(
                  label: "Nomor HP",
                  controller: hpController,
                  icon: Icons.phone_outlined,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(tanggalText),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: pickDate,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: "Status",
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      filled: true,
                      fillColor: const Color(0xffF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Aktif",
                        child: Text("Aktif"),
                      ),
                      DropdownMenuItem(
                        value: "Non Aktif",
                        child: Text("Non Aktif"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : updateResident,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(loading ? "Menyimpan..." : "Update Resident"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
