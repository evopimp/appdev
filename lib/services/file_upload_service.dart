import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:younger_delivery/services/firebase_service.dart';
import 'package:younger_delivery/services/google_cloud_storage_service.dart'
    as gcs;

class FileUploadService {
  final FirebaseService firebaseService;

  FileUploadService({required this.firebaseService});

  Future<String?> uploadToFirebase(File file, String extension) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("$extension/${DateTime.now().toIso8601String()}.$extension");
    UploadTask uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() => null);
    return ref.getDownloadURL();
  }

  Future<void> uploadToGoogleCloud(File file) async {
    await gcs.uploadToGoogleCloud(file); // Note the 'gcs.' before the function
  }
}
