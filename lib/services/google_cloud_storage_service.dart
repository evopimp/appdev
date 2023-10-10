import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart';

Future<void> uploadToGoogleCloud(File file) async {
  var scopes = [storage.StorageApi.devstorageFullControlScope];
  var jsonContent = await rootBundle
      .loadString('assets/google_cloud_storage_credentials.json');
  var credentials =
      ServiceAccountCredentials.fromJson(json.decode(jsonContent));

  var client = await clientViaServiceAccount(credentials, scopes);
  var storageApi = storage.StorageApi(client);

  var media = storage.Media(file.openRead(), file.lengthSync());
  var bucketName = 'younger_file_upload_bucket';
  var fileName = 'Inventory/' + DateTime.now().toIso8601String();

  try {
    await storageApi.objects.insert(
      storage.Object.fromJson({'name': fileName}),
      bucketName,
      uploadMedia: media,
    );
    print('File uploaded to Google Cloud Storage');
  } catch (e) {
    print('An error occurred: $e');
  } finally {
    client.close();
  }
}
