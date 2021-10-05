import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/modules/camera_screen.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';

class ImageCapabilityWidget extends StatelessWidget {
  final Function() notifyParent;
  final ImageCap cap;
  ImageCapabilityWidget(
      {Key? key, required this.cap, required this.notifyParent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Card(
        shape: RoundedRectangleBorder(
          //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
          side: BorderSide(color: Colors.white.withAlpha(30), width: 1),
          borderRadius: BorderRadius.circular(19.0),
        ),
        color: Colors.white.withAlpha(0),
        margin: EdgeInsets.all(0),
        child: Container(
          //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
          height: cap.thumb == null ? 60 : 260,
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
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                              child: cap.thumb == null
                                  ? Text(
                                      "Select image source",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
                            final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);
                            cap.thumb = await image?.readAsBytes();
                            cap.raw = ImageUtils.convertImage(
                                cap.thumb!, cap.parameters);
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
                                    builder: (context) => CameraScreen(
                                          cap: cap,
                                        ))).then((value) {
                              notifyParent();
                            });
                          },
                        )
                      ],
                    )
                  ]))),
        ));
  }
}
