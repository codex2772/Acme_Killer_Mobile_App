import 'package:acme_killer_mobile_app/modules/staff/controllers/document_controller.dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentScreen extends StatelessWidget {

  final controller = Get.put(DocumentController());

  DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffd4af37),

        child: const Icon(Icons.upload_file, color: Colors.black),

        onPressed: () {
          // controller.addDummyDocument();
        },
      ),

      body: Obx(() => ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: controller.documents.length,

        itemBuilder: (_, i) {

          final doc = controller.documents[i];

          return Container(

            margin: const EdgeInsets.only(bottom: 12),

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xff1a1a2e),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [

                const Icon(
                  Icons.insert_drive_file,
                  color: Color(0xffd4af37),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    doc.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),

                  onPressed: () {
                    controller.removeDocument(i);
                  },
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}