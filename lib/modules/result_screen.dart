import 'dart:io';
import 'dart:typed_data';
//import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Background(),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            leadingWidth: 42,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Column(children: [
              Text(RuneEngine.runeMeta["name"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                RuneEngine.runeMeta["description"],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              )
            ]),
            actions: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icons/notification.png",
                    width: 16,
                  ),
                  onPressed: () {}),
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        barneyPurpleColor.withAlpha(150),
                        indigoBlueColor.withAlpha(150),
                      ],
                    )),
                width: 30,
                height: 30,
                child: IconButton(
                    icon: Icon(Icons.segment, size: 16),
                    splashColor: Colors.white,
                    splashRadius: 21,
                    onPressed: () {}),
              )),
              Container(
                width: 10,
              )
            ],
          ),
          body: Container(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    if (index == 0 &&
                        RuneEngine.capabilities[0].type ==
                            CapabilitiesIds["RawCapability"]) {
                      return new Card(
                          shape: RoundedRectangleBorder(
                            //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                            side: BorderSide(
                                color: Colors.white.withAlpha(30), width: 1),
                            borderRadius: BorderRadius.circular(19.0),
                          ),
                          color: Colors.white.withAlpha(0),
                          margin: EdgeInsets.all(0),
                          child: Container(
                            //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                            height: 320,
                            //padding: EdgeInsets.all(3),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                    color: Colors.white.withAlpha(30),
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Stack(children: [
                                      Center(
                                          child: Container(
                                              height: 256,
                                              width: 256,
                                              color: Colors.white,
                                              child: Stack(children: [
                                                FittedBox(
                                                  child: Text(
                                                      "${RuneEngine.output["output"]}"),
                                                  fit: BoxFit.fill,
                                                ),
                                              ])))
                                    ]))),
                          ));
                    }
                    if (index == 0 &&
                        RuneEngine.capabilities[0].type ==
                            CapabilitiesIds["ImageCapability"]) {
                      return RuneEngine.output["type"] == "none"
                          ? Container()
                          : new Card(
                              shape: RoundedRectangleBorder(
                                //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                                side: BorderSide(
                                    color: Colors.white.withAlpha(30),
                                    width: 1),
                                borderRadius: BorderRadius.circular(19.0),
                              ),
                              color: Colors.white.withAlpha(0),
                              margin: EdgeInsets.all(0),
                              child: Container(
                                //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                height: 320,
                                //padding: EdgeInsets.all(3),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Container(
                                        color: Colors.white.withAlpha(30),
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Stack(children: [
                                          RuneEngine.output["type"] == "Objects"
                                              ? Center(
                                                  child: Container(
                                                      height: 256,
                                                      width: 256,
                                                      color: Colors.white,
                                                      child: Stack(children: [
                                                        FittedBox(
                                                          child: Image.memory(
                                                            (RuneEngine.capabilities[
                                                                        0]
                                                                    as ImageCap)
                                                                .thumb!,
                                                            fit: BoxFit.fill,
                                                          ),
                                                          fit: BoxFit.fill,
                                                        ),
                                                        CustomPaint(
                                                            painter: ShapePainter(
                                                                RuneEngine
                                                                    .objects),
                                                            child: Container(
                                                              width: 256,
                                                              height: 256,
                                                            )),
                                                      ])))
                                              : Container(),
                                          RuneEngine.output["type"] == "Image"
                                              ? Image.memory(
                                                  RuneEngine.output["output"]!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                              : Container(),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Center(
                                                    child: RuneEngine.output[
                                                                "type"] ==
                                                            "String"
                                                        ? Text(
                                                            "${RuneEngine.output["output"]}",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        : Container()),
                                              ),
                                            ],
                                          )
                                        ]))),
                              ));
                    }
                    if (index == 1) {
                      return Row(mainAxisSize: MainAxisSize.max, children: [
                        Expanded(
                            child: Container(
                          height: 42,
                          margin: EdgeInsets.only(top: 11, bottom: 11),
                          decoration: new BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 6,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20.5),
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  charcoalGrey.withAlpha(125),
                                  barneyPurpleColor.withAlpha(50),
                                  indigoBlueColor.withAlpha(125),
                                ],
                              )),
                          child: RawMaterialButton(
                            elevation: 4.0,
                            child: new Text(
                              'Try Again',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )),
                        Container(
                          width: 11,
                        ),
                        Expanded(
                            child: Container(
                          height: 42,
                          margin: EdgeInsets.only(top: 11, bottom: 11),
                          decoration: new BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 6,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20.5),
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  charcoalGrey.withAlpha(125),
                                  barneyPurpleColor.withAlpha(50),
                                  indigoBlueColor.withAlpha(125),
                                ],
                              )),
                          child: RawMaterialButton(
                            elevation: 4.0,
                            child: Row(children: [
                              Container(
                                width: 10,
                              ),
                              Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 14,
                              ),
                              Expanded(
                                  child: new Text(
                                'Share the Result',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ))
                            ]),
                            onPressed: () async {
                              Uint8List out = RuneEngine.output["output"];
                              if (kIsWeb) {
                                /*final blob =
                                    html.Blob(<dynamic>[out], 'image/png');
                                final anchorElement = html.AnchorElement(
                                  href: html.Url.createObjectUrlFromBlob(blob),
                                )
                                  ..setAttribute('download', 'rune_output.png')
                                  ..click();*/
                              } else {
                                final directory = await getTemporaryDirectory();
                                await new File(
                                        directory.path + "/image_out.png")
                                    .writeAsBytes(out);
                                Share.shareFiles(
                                    ['${directory.path}/image_out.png'],
                                    text:
                                        'Runic image from ${RuneEngine.runeMeta["name"]}');
                              }
                            },
                          ),
                        ))
                      ]);
                    }
                    return Container(
                      height: 30,
                    );
                  }))),
      MainMenu()
    ]);
  }
}

class ShapePainter extends CustomPainter {
  final List<dynamic> objects;
  ShapePainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint()
      ..color = indigoBlueColor
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    paint.style = PaintingStyle.stroke;

    for (Map object in objects) {
      print(objects);
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 8,
      );
      final textSpan = TextSpan(
        text: object["name"],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: 200,
      );
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
          new Rect.fromLTWH(
              object["x"] * size.width - object["w"] * size.width / 2,
              object["y"] * size.height - object["h"] * size.height / 2,
              object["w"] * size.width,
              11),
          paint);
      paint.style = PaintingStyle.stroke;
      textPainter.paint(
          canvas,
          Offset(object["x"] * size.width - textPainter.width / 2,
              object["y"] * size.height - object["h"] * size.height / 2 + 0));
      canvas.drawRect(
          new Rect.fromLTWH(
              object["x"] * size.width - object["w"] * size.width / 2,
              object["y"] * size.height - object["h"] * size.height / 2,
              object["w"] * size.width,
              object["h"] * size.height),
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
