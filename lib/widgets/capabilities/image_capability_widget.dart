import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/permissions.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/camera_screen.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';

class ImageCapabilityWidget extends StatelessWidget {
  final Function() notifyParent;
  final Function() back;
  final ImageCap cap;
  final single;

  ImageCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      required this.back,
      this.single = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return new Column(children: [
      Container(
        height: single ? 11 : 0,
      ),
      single
          ? Stack(children: [
              Container(
                height: 42,
                width: double.infinity,
                margin: EdgeInsets.only(top: 11, bottom: 11),
                decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20.5),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        indigoBlueColor.withAlpha(125),
                        barneyPurpleColor.withAlpha(125),
                      ],
                    )),
                child: RawMaterialButton(
                  elevation: 4.0,
                  child: Image.asset(
                    "assets/images/icons/rune_live_mode_text.png",
                    height: 18,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraScreen(
                                  cap: cap,
                                ))).then((value) {
                      back();
                      notifyParent();
                    });
                  },
                ),
              ),
              Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.only(top: 7, bottom: 7),
                padding: EdgeInsets.only(left: 5),
                decoration: new BoxDecoration(
                    boxShadow: [],
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                    ),
                    border: Border.all(color: barneyPurpleColor, width: 2)),
                child: RawMaterialButton(
                  elevation: 4.0,
                  child: Image.asset(
                    "assets/images/icons/rune_live_mode_icon.png",
                    height: 21,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraScreen(
                                  cap: cap,
                                ))).then((value) {
                      notifyParent();
                    });
                  },
                ),
              )
            ])
          : Container(),
      Container(
        height: single ? 11 : 0,
      ),
      single
          ? Stack(children: [
              Container(
                height: 42,
                width: double.infinity,
                margin: EdgeInsets.only(top: 11, bottom: 11),
                decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20.5),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        indigoBlueColor.withAlpha(125),
                        barneyPurpleColor.withAlpha(125),
                      ],
                    )),
                child: RawMaterialButton(
                  elevation: 4.0,
                  child: Image.asset(
                    "assets/images/icons/rune_take_pic_text.png",
                    height: 18,
                  ),
                  onPressed: () async {
                    bool perm = await Permissions.requestPhotos();
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    cap.loading = true;

                    notifyParent();
                    await new Future.delayed(const Duration(milliseconds: 500));
                    List<Uint8List> data = ImageUtils.convertImage(
                        await image!.readAsBytes(), cap.parameters);
                    cap.thumb = data[1];
                    cap.inputTensor.bytes = data[0];
                    cap.loading = false;
                    notifyParent();
                  },
                ),
              ),
              Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.only(top: 7, bottom: 7),
                padding: EdgeInsets.only(left: 5),
                decoration: new BoxDecoration(
                    boxShadow: [],
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                    ),
                    border: Border.all(color: barneyPurpleColor, width: 2)),
                child: RawMaterialButton(
                  elevation: 4.0,
                  child: Image.asset(
                    "assets/images/icons/rune_take_picture_icon.png",
                    height: 21,
                  ),
                  onPressed: () async {
                    bool perm = await Permissions.requestPhotos();
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    cap.loading = true;

                    notifyParent();
                    await new Future.delayed(const Duration(milliseconds: 500));
                    List<Uint8List> data = ImageUtils.convertImage(
                        await image!.readAsBytes(), cap.parameters);

                    cap.thumb = data[1];
                    cap.inputTensor.bytes = data[0];
                    cap.loading = false;
                    notifyParent();
                  },
                ),
              )
            ])
          : Container(),
      cap.loading == true
          ? new Card(
              shape: RoundedRectangleBorder(
                //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                side: BorderSide(color: Colors.white.withAlpha(30), width: 1),
                borderRadius: BorderRadius.circular(19.0),
              ),
              color: Colors.white.withAlpha(0),
              margin: EdgeInsets.all(0),
              child: Container(
                  //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  height: size.width > 500 ? 450 : size.width - 50,
                  width: size.width > 500 ? 450 : size.width - 50,
                  //padding: EdgeInsets.all(3),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                          color: Colors.white.withAlpha(30),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Center(
                              child: Stack(children: [
                            Center(
                                child: Container(
                                    width: 128,
                                    height: 128,
                                    child: LoadingIndicator(
                                        indicatorType: Indicator.orbit,

                                        /// Required, The loading type of the widget
                                        colors: [darkBlueBlue],

                                        /// Optional, The color collections
                                        strokeWidth: 2,

                                        /// Optional, The stroke of the line, only applicable to widget which contains line
                                        backgroundColor: Colors.transparent,

                                        /// Optional, Background of the widget
                                        pathBackgroundColor: Colors.transparent

                                        /// Optional, the stroke backgroundColor
                                        ))),
                            Center(
                                child: Text(
                              "Getting Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ))
                          ]))))))
          : Container(),
      (!single || cap.thumb != null && cap.loading == false)
          ? new Card(
              shape: RoundedRectangleBorder(
                //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                side: BorderSide(color: Colors.white.withAlpha(30), width: 1),
                borderRadius: BorderRadius.circular(19.0),
              ),
              color: Colors.white.withAlpha(0),
              margin: EdgeInsets.all(0),
              child: Container(
                //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                height: cap.thumb == null
                    ? 60
                    : size.width > 500
                        ? 450
                        : size.width - 50,
                width: size.width > 500 ? 450 : size.width - 50,
                //padding: EdgeInsets.all(3),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                        color: Colors.white.withAlpha(30),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Stack(children: [
                          cap.thumb != null
                              ? Image.memory(
                                  cap.thumb!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Container(),
                          !single
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                          child: cap.thumb == null
                                              ? Text(
                                                  "Select image source",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white),
                                                )
                                              : Container()),
                                    ),
                                    IconButton(
                                      splashRadius: 20.0,
                                      iconSize: 80,
                                      padding: EdgeInsetsDirectional.all(0),
                                      icon: Image.asset(
                                        "assets/images/icons/btn-upload-photo.png",
                                        width: 80,
                                      ),
                                      onPressed: () async {
                                        bool perm =
                                            await Permissions.requestPhotos();
                                        final ImagePicker _picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);
                                        List<Uint8List> data =
                                            ImageUtils.convertImage(
                                                await image!.readAsBytes(),
                                                cap.parameters);
                                        cap.thumb = data[1];
                                        cap.inputTensor.bytes = data[0];
                                        notifyParent();
                                      },
                                    ),
                                    IconButton(
                                      splashRadius: 20.0,
                                      iconSize: 80,
                                      padding: EdgeInsetsDirectional.all(0),
                                      icon: Image.asset(
                                        "assets/images/icons/btn-upload-video.png",
                                        width: 80,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CameraScreen(
                                                      cap: cap,
                                                    ))).then((value) {
                                          RuneEngine.output["type"] = "none";
                                          notifyParent();
                                        });
                                      },
                                    )
                                  ],
                                )
                              : Container()
                        ]))),
              ))
          : Container(),
    ]);
  }
}
