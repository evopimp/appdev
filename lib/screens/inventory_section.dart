import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:younger_delivery/services/firebase_service.dart';
import 'package:younger_delivery/services/file_upload_service.dart';

class InventorySection extends StatefulWidget {
  @override
  _InventorySectionState createState() => _InventorySectionState();
}

class _InventorySectionState extends State<InventorySection> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final FirebaseService firebaseService =
      FirebaseService(); // Initialize FirebaseService
  final FileUploadService fileUploadService; // Declare FileUploadService
  _InventorySectionState()
      : fileUploadService = FileUploadService(
            firebaseService: FirebaseService()); // Initialize FileUploadService

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'xls', 'xlsx', 'csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  void addItem() {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        sizeController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('inventory').add({
        'name': nameController.text,
        'price': double.parse(priceController.text),
        'quantity': int.parse(quantityController.text),
        'description': descriptionController.text,
        'size': sizeController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Section"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('inventory')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Size')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    return DataRow(cells: [
                      DataCell(Text(doc['name'])),
                      DataCell(Text(doc['price'].toString())),
                      DataCell(Text(doc['quantity'].toString())),
                      DataCell(Text(doc['size'])),
                      DataCell(Text(doc['description'])),
                    ]);
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Add New Item"),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: 'Item Name'),
                          ),
                          TextField(
                            controller: priceController,
                            decoration: InputDecoration(labelText: 'Price'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: quantityController,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: sizeController,
                            decoration: InputDecoration(labelText: 'Size'),
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              File? file = await pickFile();
                              if (file != null) {
                                String extension = path
                                    .extension(file.path)
                                    .substring(1); // remove the leading '.'
                                String? url =
                                    await fileUploadService.uploadToFirebase(
                                        file, extension); // Use the new service
                                print("File uploaded: $url");
                                // TODO: Depending on the file type, parse the in
                                                            }
                            },
                            child: Text('Upload Inventory Document'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addItem();
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Add New Item"),
            ),
          ),
        ],
      ),
    );
  }
}
