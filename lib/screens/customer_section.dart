import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; // Added this for file extensions
import 'package:younger_delivery/services/firebase_service.dart'; // Added
import 'package:younger_delivery/services/file_upload_service.dart'; // Added

class CustomerSection extends StatefulWidget {
  @override
  _CustomerSectionState createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FirebaseService firebaseService =
      FirebaseService(); // Initialize FirebaseService here
  final FileUploadService fileUploadService;

  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  _CustomerSectionState()
      : fileUploadService = FileUploadService(
            firebaseService:
                FirebaseService()); // Initialize FileUploadService in constructor

  Future<void> addCustomer() async {
    return customers
        .add({
          'businessName': _businessNameController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text,
          'notes': _notesController.text,
        })
        .then((value) => print("Customer Added"))
        .catchError((error) => print("Failed to add customer: $error"));
  }

  Future<void> deleteCustomer(DocumentSnapshot docToDelete) {
    return customers
        .doc(docToDelete.id)
        .delete()
        .then((value) => print("Customer Deleted"))
        .catchError((error) => print("Failed to delete customer: $error"));
  }

  Future<void> addCustomersFromCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String extension =
          path.extension(file.path).substring(1); // remove the leading '.'

      String? url = await fileUploadService.uploadToFirebase(
          file, extension); // Use the new service

      if (url != null) {
        print("File uploaded: $url");
      } else {
        print('Failed to process document');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: addCustomersFromCSV,
          child: Text("Upload CSV"),
        ),
        Expanded(
          child: StreamBuilder(
            stream: customers.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No customers found.');
              }

              List<DataRow> rows = [];

              for (DocumentSnapshot document in snapshot.data!.docs) {
                Map<String, dynamic>? data =
                    document.data() as Map<String, dynamic>?;

                if (data != null &&
                    data.containsKey('businessName') &&
                    data.containsKey('phoneNumber')) {
                  rows.add(
                    DataRow(
                      cells: [
                        DataCell(Text(data['businessName'] ?? 'N/A')),
                        DataCell(Text(data['phoneNumber'] ?? 'N/A')),
                        DataCell(Text(data['address'] ?? 'N/A')),
                        DataCell(Text(data['notes'] ?? 'N/A')),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              deleteCustomer(document);
                            },
                            child: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Business Name')),
                    DataColumn(label: Text('Phone Number')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: rows,
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Customer'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _businessNameController,
                          decoration:
                              InputDecoration(labelText: 'Business Name'),
                        ),
                        TextField(
                          controller: _phoneNumberController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                        ),
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(labelText: 'Address'),
                        ),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(labelText: 'Notes'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        addCustomer();
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Add New Customer'),
        ),
      ],
    );
  }
}
