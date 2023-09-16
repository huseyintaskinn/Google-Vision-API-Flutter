import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecordedPage extends StatelessWidget {
  RecordedPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>?> FirebaseData() async {
      FirebaseAuth auth = FirebaseAuth.instance;
      final users = FirebaseFirestore.instance.collection('users');
      final userDoc = await users.doc(auth.currentUser!.uid).get();
      final userData = userDoc.data();

      return userData;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kaydedilenler'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirebaseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Veri yüklenene kadar bekleyin
          }

          if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'Veri bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ));
          }

          final userData = snapshot.data!;
          return ListView.builder(
            itemCount: userData['obj'].length,
            itemBuilder: (context, index) {
              final results = userData['obj'][index]['results'];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Stack(
                          children: [
                            Image.network(
                              userData['obj'][index]['photoUrls'],
                              width: 350,
                              height: 350,
                              fit: BoxFit.fill,
                            ),
                            Stack(
                              children: results.map<Widget>((annotation) {
                                final rect = annotation['boundingPoly'];
                                final imageWidth = 350;
                                final imageHeight = 350;

                                final left = rect['v1'][0] * imageWidth;
                                final top = rect['v1'][1] * imageHeight;
                                final width = (rect['v3'][0] - rect['v1'][0]) *
                                    imageWidth;
                                final height = (rect['v3'][1] - rect['v1'][1]) *
                                    imageHeight;

                                return Container(
                                  width: imageWidth.toDouble(),
                                  height: imageHeight.toDouble(),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: left,
                                        top: top,
                                        child: Container(
                                          width: width,
                                          height: height,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 0, 255, 8),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: left,
                                        top: top,
                                        child: Container(
                                          width: width,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              '${annotation['name']} (${annotation['score'].toStringAsFixed(2)})',
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255, 0, 255, 8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        144, 0, 0, 0),
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Bulunan nesne sayısı: ${userData['obj'][index]['results'].length}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Sütun içinde soldan hizalama
                          children: results.map<Widget>((annotation) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    '${annotation['name']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    '${annotation['score']}',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
