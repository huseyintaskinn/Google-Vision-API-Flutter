import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_vision/google_vision.dart' as gv;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'result_page.dart';
import 'auth/login_page.dart';
import 'recorded_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _resimDosyasi;
  File? _sonucDosyasi;
  List<gv.LocalizedObjectAnnotation> _nesneSonuclari = [];
  XFile? secilenResim;
  var flag = 0;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> _cameraPermission() async {
    // Kamera izni kontrolü
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      // Kamera izni verilmemişse, izin iste
      var cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        // Kullanıcı izni reddederse uyarı göster
        _showSnackBar("Kamera izni verilmedi.");
        return false;
      }
    }

    return true;
  }

  Future<bool> _galleryPermission() async {
    // Galeri izni kontrolü
    var galleryStatus = await Permission.storage.status;
    if (!galleryStatus.isGranted) {
      // Galeri izni verilmemişse, izin iste
      var galleryPermission = await Permission.storage.request();
      if (!galleryPermission.isGranted) {
        // Kullanıcı izni reddederse uyarı göster
        _showSnackBar("Galeri izni verilmedi.");
        return false;
      }
    }

    return true;
  }

  Future _galeridenResimAl() async {
    bool per = await _galleryPermission();

    if (per) {
      secilenResim = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (secilenResim != null) {
        setState(() {
          _resimDosyasi = File(secilenResim!.path);
          _nesneSonuclari.clear();
        });
      }
    }
  }

  Future _kameradanResimCek() async {
    bool per = await _cameraPermission();

    if (per) {
      secilenResim = await ImagePicker().pickImage(source: ImageSource.camera);

      if (secilenResim != null) {
        setState(() {
          _resimDosyasi = File(secilenResim!.path);
          _nesneSonuclari.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return flag == 0
        ? Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nesne Dedektörü'),
                ],
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecordedPage()),
                    );
                  },
                  icon: Icon(
                    Icons.save,
                    size: 25,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    icon: Icon(
                      Icons.login_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Container(
                        height: 385,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.086),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: _resimDosyasi != null
                                ? Image.file(
                                    _resimDosyasi!,
                                    width: 350,
                                    height: 350,
                                    fit: BoxFit.fill,
                                  )
                                : Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 80,
                                    color: Colors.grey,
                                  )),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: _galeridenResimAl,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text("Galeriden Seç"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _kameradanResimCek,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text("Fotoğraf Çek"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _nesneBul,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.image_search_rounded,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text("Nesneleri Bul"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
              child: SpinKitCircle(
                size: 140,
                color: Colors.white,
              ),
            ),
          );
  }

  Future<void> _nesneBul() async {
    if (_resimDosyasi == null) {
      _showSnackBar("Önce bir fotoğraf yüklemelisiniz.");
      return;
    }

    setState(() {
      flag = 1;
    });

    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}";
    Random random = Random();
    String randomValue = random.nextInt(10000).toString();
    String uniqueFileName = "$formattedDate-$randomValue.png";

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("images")
        .child(auth.currentUser!.uid)
        .child(uniqueFileName);
    UploadTask uploadTask = ref.putFile(_resimDosyasi!);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final photoUrl = await taskSnapshot.ref.getDownloadURL();

    Future<void> addPhotoUrlToFirestore(
        String userId, String photoUrl, List sonuclar) async {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocRef = firestoreInstance.collection('users').doc(userId);

      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        await userDocRef.update({
          'obj': FieldValue.arrayUnion([
            {
              'photoUrls': photoUrl,
              'results': sonuclar,
            }
          ])
        });
      } else {
        await userDocRef.set({
          'obj': [
            {
              'photoUrls': photoUrl,
              'results': sonuclar,
            }
          ]
        });
      }
    }

    String path = await rootBundle
        .loadString('assets/visionapiflutter-90130e680dd0.json');

    final googleVision = await gv.GoogleVision.withJwt(path);

    final painter = gv.Painter.fromFilePath(secilenResim!.path);

    var resim = gv.Image(painter: painter);

    final requests = gv.AnnotationRequests(requests: [
      gv.AnnotationRequest(
          image: resim,
          features: [gv.Feature(maxResults: 10, type: 'OBJECT_LOCALIZATION')])
    ]);

    gv.AnnotatedResponses annotatedResponses =
        await googleVision.annotate(requests: requests);

    List<gv.LocalizedObjectAnnotation> sonuclar = [];

    for (var annotatedResponse in annotatedResponses.responses) {
      for (var objectAnnotation
          in annotatedResponse.localizedObjectAnnotations) {
        sonuclar.add(objectAnnotation);
        print(objectAnnotation);
      }
    }

    setState(() {
      _nesneSonuclari = sonuclar;
    });

    List<List<double>> convertBoundingPolyToFirestoreFormat(
        gv.BoundingPoly boundingPoly) {
      List<List<double>> result = [];
      for (var vertex in boundingPoly.normalizedVertices) {
        result.add([vertex.x, vertex.y]);
      }
      return result;
    }

    List<Map<String, dynamic>> sonuclarData = _nesneSonuclari.map((sonuc) {
      List<List<double>> poly =
          convertBoundingPolyToFirestoreFormat(sonuc.boundingPoly);

      return {
        'name': sonuc.name,
        'boundingPoly': {
          'v1': poly[0],
          'v2': poly[1],
          'v3': poly[2],
          'v4': poly[3],
        },
        'mid': sonuc.mid,
        'score': sonuc.score,
      };
    }).toList();

    addPhotoUrlToFirestore(auth.currentUser!.uid, photoUrl, sonuclarData);

    _sonucDosyasi = _resimDosyasi;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(_nesneSonuclari, _sonucDosyasi),
      ),
    );

    setState(() {
      _resimDosyasi = null;
      flag = 0;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
}
