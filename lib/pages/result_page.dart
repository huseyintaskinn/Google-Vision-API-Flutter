import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_vision/google_vision.dart' as gv;

class ResultPage extends StatelessWidget {
  final List<gv.LocalizedObjectAnnotation> nesneSonuclari;
  File? _resimDosyasi;

  ResultPage(this.nesneSonuclari, this._resimDosyasi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sonuçlar'),
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
