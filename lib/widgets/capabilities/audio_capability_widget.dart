import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:runic_flutter/widgets/capabilities/audio_cap.dart';

class AudioCapabilityWidget extends StatefulWidget {
  final Function() notifyParent;
  final AudioCap cap;
  final single;

  AudioCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
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
                        child: Stack(children: [
                          Container(
                              width: double.infinity,
                              child: LineChart(
                                audioData(widget.cap),
                              )),
                        ])),
                    Container(
                      child: Text(
                        "Audio Input",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      padding: EdgeInsets.all(10),
                    )
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
