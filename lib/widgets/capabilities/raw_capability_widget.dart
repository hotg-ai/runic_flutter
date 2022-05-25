import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';

class RawCapabilityWidget extends StatefulWidget {
  final Function() notifyParent;
  final RawCap cap;
  final single;
  RawCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      this.single = true})
      : super(key: key);

  @override
  _RawCapabilityState createState() => _RawCapabilityState();
}

class _RawCapabilityState extends State<RawCapabilityWidget> {
  String dataType = "UTF8";
  final TextEditingController controller = new TextEditingController();

  final FocusNode inputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Stack(children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 55, 0),
                            child: TextField(
                              focusNode: inputFocusNode,
                              expands: true,
                              style: TextStyle(color: Colors.white),
                              onChanged: (String text) {
                                widget.cap.inputTensor.bytes =
                                    RawCap.stringToData(text, dataType);
                              },
                              controller: controller,
                              //keyboardType: TextInputType.,
                              maxLines: null,
                            )),
                        Positioned(
                            right: 0,
                            top: 0,
                            width: 60,
                            child: DropdownButton<String>(
                              value: dataType,
                              //icon: const Icon(Icons.arrow_downward),
                              elevation: 0,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              underline: Container(
                                height: 1,
                                color: Colors.white,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dataType = "$newValue";
                                  controller.text = RawCap.dataToString(
                                      widget.cap.inputTensor.bytes!, dataType);
                                });
                              },
                              items: <String>[
                                'UTF8',
                                'ASCII',
                                'U8',
                                'F32'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
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
