import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_vision/google_vision.dart' as gv;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nesne Dedektörü',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: "assets/logo.png",
        nextScreen: AnaSayfa(),
        splashTransition: SplashTransition.scaleTransition,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  File? _resimDosyasi;
  File? _sonucDosyasi;
  List<gv.LocalizedObjectAnnotation> _nesneSonuclari = [];
  XFile? secilenResim;
  var flag = 0;

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

class ResultPage extends StatelessWidget {
  final List<gv.LocalizedObjectAnnotation> nesneSonuclari;
  File? _resimDosyasi;

  ResultPage(this.nesneSonuclari, this._resimDosyasi);

  @override
  Widget build(BuildContext context) {
    // Sonuçları gösterme işlemini burada yapabilirsiniz.
    return Scaffold(
      appBar: AppBar(
        title: Text('Sonuçlar'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 40),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: Container(
                        width: 350,
                        height: 350,
                        child: Stack(
                          children: nesneSonuclari.map((annotation) {
                            final rect =
                                annotation.boundingPoly.normalizedVertices;
                            final imageWidth = 350;
                            final imageHeight = 350;

                            final left = rect[0].x * imageWidth;
                            final top = rect[0].y * imageHeight;
                            final width = (rect[2].x - rect[0].x) * imageWidth;
                            final height =
                                (rect[2].y - rect[0].y) * imageHeight;

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
                                          '${annotation.name} (${annotation.score.toStringAsFixed(2)})',
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
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Bulunan Nesneler",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Sütun içinde soldan hizalama
                children: nesneSonuclari.map((annotation) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          '${annotation.name}',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          '${annotation.score}',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
