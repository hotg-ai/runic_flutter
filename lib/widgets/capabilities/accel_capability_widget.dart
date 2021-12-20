import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:runic_flutter/widgets/capabilities/accel_cap.dart';
import 'package:fl_chart/fl_chart.dart';

class AccelCapabilityWidget extends StatefulWidget {
  final Function() notifyParent;
  final AccelCap cap;
  final single;

  AccelCapabilityWidget(
      {Key? key,
      required this.cap,
      required this.notifyParent,
      this.single = true})
      : super(key: key);

  @override
  _AccelCapabilityWidgetState createState() => _AccelCapabilityWidgetState();
}

class _AccelCapabilityWidgetState extends State<AccelCapabilityWidget> {
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
                                accelometerData(widget.cap),
                              )),
                        ])),
                    Container(
                      child: Text(
                        "Accelerometer",
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
List<Color> gradientColorsY = [
  Colors.lightGreen[200]!,
  Colors.lightGreen[600]!,
];
List<Color> gradientColorsZ = [
  Colors.yellow[200]!,
  Colors.yellow[600]!,
];
List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

LineChartData accelometerData(AccelCap cap) {
  final List<double> minMax = [-15, 15];
  List<FlSpot> spotsX = [];
  List<double> x = cap.xAxis;
  for (int i = 0; i < x.length; i++) {
    double value =
        x[i] > minMax[1] ? minMax[1] : (x[i] < minMax[0] ? minMax[0] : x[i]);
    spotsX.add(FlSpot(i * 1.0, value));
  }
  if (spotsX.length == 0) {
    spotsX.add(FlSpot(0, 0));
  }
  List<FlSpot> spotsY = [];
  List<double> y = cap.yAxis;
  for (int i = 0; i < y.length; i++) {
    double value =
        y[i] > minMax[1] ? minMax[1] : (y[i] < minMax[0] ? minMax[0] : y[i]);
    spotsY.add(FlSpot(i * 1.0, value));
  }
  if (spotsY.length == 0) {
    spotsY.add(FlSpot(0, 0));
  }
  List<FlSpot> spotsZ = [];
  List<double> z = cap.zAxis;
  for (int i = 0; i < z.length; i++) {
    double value =
        z[i] > minMax[1] ? minMax[1] : (z[i] < minMax[0] ? minMax[0] : z[i]);
    spotsZ.add(FlSpot(i * 1.0, value));
  }
  if (spotsZ.length == 0) {
    spotsZ.add(FlSpot(0, 0));
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
    maxX: cap.xAxis.length * 1.0,
    minY: minMax[0],
    maxY: minMax[1],
    lineBarsData: [
      LineChartBarData(
        spots: spotsX,
        isCurved: false,
        colors: gradientColorsX,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color.withOpacity(0.1)).toList(),
        ),
      ),
      LineChartBarData(
        spots: spotsY,
        isCurved: false,
        colors: gradientColorsY,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColorsY.map((color) => color.withOpacity(0.1)).toList(),
        ),
      ),
      LineChartBarData(
        spots: spotsZ,
        isCurved: false,
        colors: gradientColorsZ,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColorsZ.map((color) => color.withOpacity(0.1)).toList(),
        ),
      ),
    ],
  );
}
