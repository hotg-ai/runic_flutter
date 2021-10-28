import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/modules/camera_screen.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';

class RawCapabilityWidget extends StatelessWidget {
  final Function() notifyParent;
  final RawCap cap;
  final single;

  RawCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      this.single = true})
      : super(key: key);

  TextEditingController controller = new TextEditingController();

  String utf8toString(Uint8List raw) {
    return utf8.decode(raw);
  }

  Uint8List stringToUtf8(String text) {
    while (text.length < 1500) {
      text = text + " ";
    }
    while (text.length > 1500) {
      text = text.substring(0, text.length - 1);
    }
    return new Uint8List.fromList(utf8.encode(text));
  }

  final FocusNode inputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    if (cap.raw != null) {
      controller.text = utf8toString(cap.raw!);
    }
    return new Column(children: [
      new Card(
          shape: RoundedRectangleBorder(
            //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
            side: BorderSide(color: Colors.white.withAlpha(30), width: 1),
            borderRadius: BorderRadius.circular(19.0),
          ),
          color: Colors.white.withAlpha(0),
          margin: EdgeInsets.all(0),
          child: Stack(children: [
            Container(
              //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
              height: 200,
              //padding: EdgeInsets.all(3),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                      color: Colors.white.withAlpha(30),
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Stack(children: [
                        Container(
                            child: TextField(
                          focusNode: inputFocusNode,
                          expands: true,
                          style: TextStyle(color: Colors.white),
                          onChanged: (String text) {
                            cap.raw = stringToUtf8(text);
                          },
                          controller: controller,
                          //keyboardType: TextInputType.,
                          maxLines: null,
                        )),
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: IconButton(
                                onPressed: () {
                                  inputFocusNode.unfocus();
                                },
                                icon: Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )))
                      ]))),
            )
          ]))
    ]);
  }
}
