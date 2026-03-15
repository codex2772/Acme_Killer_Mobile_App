import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSubmit;

  const CustomerForm({super.key, this.customer, required this.onSubmit});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final city = TextEditingController();
  final address = TextEditingController();
  final pan = TextEditingController();
  final gst = TextEditingController();
  final notes = TextEditingController();

  String type = "regular";

  @override
  void initState() {
    super.initState();

    if (widget.customer != null) {
      final c = widget.customer!;

      name.text = c.name;
      phone.text = c.phone ?? "";
      email.text = c.email ?? "";
      city.text = c.city ?? "";
      address.text = c.address ?? "";
      pan.text = c.pan ?? "";
      gst.text = c.gstNumber ?? "";
      notes.text = c.notes;
      type = c.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section("Basic Information"),

            input(name, "Customer Name"),
            input(phone, "Phone"),
            input(email, "Email"),

            const SizedBox(height: 20),

            section("Address"),

            input(city, "City"),
            input(address, "Address"),

            const SizedBox(height: 20),

            section("Business Details"),

            input(pan, "PAN"),
            input(gst, "GST Number"),

            const SizedBox(height: 20),

            section("Customer Type"),

            DropdownButtonFormField<String>(
              value: type,

              /// Selected value text color
              style: const TextStyle(color: Colors.white),

              dropdownColor: AppColors.bgCard,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: "vip",
                  child: Text("VIP", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "premium",
                  child: Text("Premium", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "regular",
                  child: Text("Regular", style: TextStyle(color: Colors.white)),
                ),
              ],

              onChanged: (v) {
                setState(() {
                  type = v!;
                });
              },
            ),

            const SizedBox(height: 20),

            section("Notes"),

            input(notes, "Notes", maxLines: 3),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                ),

                onPressed: save,

                child: const Text(
                  "Save Customer",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget input(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,

        /// ENTERED TEXT COLOR
        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          labelText: label,

          /// LABEL COLOR
          labelStyle: const TextStyle(color: Colors.white70),

          /// HINT COLOR
          hintStyle: const TextStyle(color: Colors.white38),

          filled: true,
          fillColor: AppColors.inputFill,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.goldPrimary),
          ),
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.goldPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void save() {
    final customer = Customer(
      id:
          widget.customer?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),

      name: name.text,
      phone: phone.text,
      email: email.text,
      city: city.text,
      address: address.text,
      pan: pan.text,
      gstNumber: gst.text,
      type: type,
      notes: notes.text,
    );

    widget.onSubmit(customer);
  }
}
