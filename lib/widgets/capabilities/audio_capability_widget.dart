import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:runic_flutter/widgets/capabilities/audio_cap.dart';

class AudioCapabilityWidget extends StatefulWidget {
  final Function() notifyParent;
  final Function(bool silent) run;
  final AudioCap cap;
  final single;

  AudioCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      required this.run,
      this.single = true})
      : super(key: key);

  @override
  _AudioCapabilityWidgetState createState() => _AudioCapabilityWidgetState();
}

class _AudioCapabilityWidgetState extends State<AudioCapabilityWidget> {
  @override
  Widget build(BuildContext context) {
    widget.cap.update = () {
      setState(() {});
      if (!widget.cap.recording) {
        widget.run(true);
      }
    };
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
                  child: Stack(children: [
                    Container(
                        color: Colors.white.withAlpha(30),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: AbsorbPointer(
                          child: Container(
                              width: double.infinity,
                              child: LineChart(
                                audioData(widget.cap),
                              )),
                        )),
                    Container(
                      child: Text(
                        "Audio Input",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        left: (MediaQuery.of(context).size.width - 24 * 2) *
                            widget.cap.selectedPos /
                            widget.cap.totalLength,
                        width: (MediaQuery.of(context).size.width - 24 * 2) *
                            widget.cap.length /
                            widget.cap.totalLength,
                        child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              widget.cap.selectedPos = (widget.cap.selectedPos +
                                      widget.cap.totalLength *
                                          (details.delta.dx /
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  24 * 2)))
                                  .round();
                              if (widget.cap.selectedPos < 0) {
                                widget.cap.selectedPos = 0;
                              }
                              if (widget.cap.selectedPos >
                                  widget.cap.totalLength - widget.cap.length) {
                                widget.cap.selectedPos =
                                    widget.cap.totalLength - widget.cap.length;
                              }

                              setState(() {});
                            },
                            onHorizontalDragEnd: (e) {
                              widget.run(true);
                            },
                            child: Container(
                              child: Row(children: [
                                Container(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white.withAlpha(150),
                                ),
                                Expanded(child: Container()),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withAlpha(150),
                                )
                              ]),
                              decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  border: Border.all(
                                      color: Colors.white.withAlpha(50))),
                            ))),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: TextButton(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              !widget.cap.recording
                                  ? Icons.mic
                                  : Icons.record_voice_over,
                              color: Colors.white,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                                widget.cap.recording
                                    ? "Recording... ${widget.cap.milliseconds}ms"
                                    : "Start Recording ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700))
                          ]),
                          onPressed: () {
                            //recording = !recording;
                            if (!widget.cap.recording) {
                              widget.cap.startRecording();
                            } else {
                              //widget.cap.stopRecording();
                            }
                          },
                        )),
                  ])),
            )
          ]))
    ]);
  }
}

List<Color> gradientColorsX = [
  Colors.red[200]!,
  Colors.red[600]!,
];
List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

LineChartData audioData(AudioCap cap) {
  final List<int> minMax = [-20000, 20000];
  List<FlSpot> spotsX = [];
  List<int> x = cap.getBuffer();

  for (int i = 0; i < x.length; i++) {
    int value =
        x[i] > minMax[1] ? minMax[1] : (x[i] < minMax[0] ? minMax[0] : x[i]);
    spotsX.add(FlSpot(i * 1.0, value * 1.0));
  }
  if (spotsX.length == 0) {
    spotsX.add(FlSpot(0, 0));
  }

  return LineChartData(
    showingTooltipIndicators: [],
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: false,
      bottomTitles: SideTitles(
        showTitles: false,
        reservedSize: 10,
        getTextStyles: (value, param) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 12),
        getTitles: (value) {
          switch (value) {
          }
          return (value.round() % 12 == 0) ? value.toString() : "";
        },
        margin: 2,
      ),
      leftTitles: SideTitles(
        showTitles: false,
        getTextStyles: (value, param) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        getTitles: (value) {
          switch (value) {
          }
          return value.round().toString();
        },
        reservedSize: 21,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: x.length * 1.0,
    minY: minMax[0] * 1.0,
    maxY: minMax[1] * 1.0,
    lineBarsData: [
      LineChartBarData(
        spots: spotsX,
        isCurved: false,
        colors: [Colors.red],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
      ),
    ],
  );
}
