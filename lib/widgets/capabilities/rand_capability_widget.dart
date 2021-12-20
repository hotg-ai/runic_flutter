import 'package:flutter/material.dart';
import 'package:runic_flutter/widgets/capabilities/rand_cap.dart';

class RandomCapabilityWidget extends StatelessWidget {
  final Function() notifyParent;
  final RandCap cap;
  final single;

  RandomCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      this.single = true})
      : super(key: key);

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
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Stack(children: [
                        Container(
                            child: Center(
                                child: Text(
                          "Random Capability",
                          style: TextStyle(color: Colors.white),
                        ))),
                      ]))),
            )
          ]))
    ]);
  }
}
