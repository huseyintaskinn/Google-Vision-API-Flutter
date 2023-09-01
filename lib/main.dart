import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_vision/google_vision.dart' as gv;
import 'package:image_picker/image_picker.dart';

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
      home: AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  File? _resimDosyasi;
  List<gv.LocalizedObjectAnnotation> _nesneSonuclari = [];
  File? _sonucDosyasi;
  XFile? secilenResim;

  Future _galeridenResimAl() async {
    secilenResim = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (secilenResim != null) {
      setState(() {
        _resimDosyasi = File(secilenResim!.path);
        _nesneSonuclari.clear();
        _sonucDosyasi = null;
      });
    }
  }

  Future _kameradanResimCek() async {
    secilenResim = await ImagePicker().pickImage(source: ImageSource.camera);

    if (secilenResim != null) {
      setState(() {
        _resimDosyasi = File(secilenResim!.path);
        _nesneSonuclari.clear();
        _sonucDosyasi = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nesne Dedektörü'),
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
              _resimDosyasi != null
                  ? Image.file(
                      _resimDosyasi!,
                      width: 350,
                      height: 350,
                      fit: BoxFit.contain,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Text('Seçilen resim yok'),
                    ),
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _galeridenResimAl,
                  child: Text('Galeriden Resim Seç'),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _kameradanResimCek,
                  child: Text('Fotoğraf Çek'),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _nesneBul,
                  child: Text('Nesneleri Bul'),
                ),
              ),
              SizedBox(height: 10),
              Stack(
                children: [
                  _sonucDosyasi != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: SizedBox(
                            width: 350,
                            height: 350,
                            child: Image.file(
                              _sonucDosyasi!,
                              width: 350,
                              height: 350,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Container(),
                  Stack(
                    children: _nesneSonuclari.map((annotation) {
                      final rect = annotation.boundingPoly.normalizedVertices;
                      final imageWidth = 350;
                      final imageHeight = 350;

                      final left = rect[0].x * imageWidth;
                      final top = rect[0].y * imageHeight;
                      final width = (rect[2].x - rect[0].x) * imageWidth;
                      final height = (rect[2].y - rect[0].y) * imageHeight;

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
                                    color: const Color.fromARGB(255, 0, 255, 8),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: left,
                              top: top - 30,
                              child: Container(
                                width: width,
                                child: Text(
                                  '${annotation.name} (${annotation.score.toStringAsFixed(2)})',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 255, 8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _nesneBul() async {
    if (_resimDosyasi == null) {
      _showSnackBar("Önce bir resim seçmelisiniz.");
      return;
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
    _sonucDosyasi = _resimDosyasi;

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
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
}
