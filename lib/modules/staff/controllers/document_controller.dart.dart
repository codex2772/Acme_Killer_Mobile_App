import 'package:acme_killer_mobile_app/models/staff/document_model.dart';
import 'package:get/get.dart';

class DocumentController extends GetxController {
  var documents = <StaffDocument>[].obs;

  void addDocument(StaffDocument doc) {
    documents.add(doc);
  }

  void removeDocument(int index) {
    documents.removeAt(index);
  }
}
