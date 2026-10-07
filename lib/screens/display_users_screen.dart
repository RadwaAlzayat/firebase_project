import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DisplayUsersScreen extends StatefulWidget {
  const DisplayUsersScreen({super.key});

  @override
  State<DisplayUsersScreen> createState() => _DisplayUsersScreenState();
}

class _DisplayUsersScreenState extends State<DisplayUsersScreen> {
  // Live stream of the "users" collection from Firestore
  final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("saved-data".tr()),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () {
              // Switch between English and Arabic
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("something_went_wrong".tr()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // All saved records (each one is a document)
          final records = snapshot.data!.docs;

          if (records.isEmpty) {
            return Center(child: Text("no_data".tr()));
          }

          // One ListView for all documents, one Card per document
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data();

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${data['age'] ?? "--"}')),
                  title: Text('${data['name'] ?? "--"}'),
                  subtitle: Text('${data['hobby'] ?? "--"}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
