import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:runic_mobile/rune/capabilities/accelerometer.dart';
import 'package:runic_mobile/rune/registry.dart';

List<Color?> gradientColorsX = [
  Colors.red[200],
  Colors.red[600],
];
List<Color?> gradientColorsY = [
  Colors.lightGreen[200],
  Colors.lightGreen[600],
];
List<Color?> gradientColorsZ = [
  Colors.yellow[200],
  Colors.yellow[600],
];
List<Color?> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

LineChartData audioData(List<int> x) {
  final List<double> minMax = [-32768 * 0.1, 32768 * 0.1];
  List<FlSpot> spotsX = [];

  for (int i = 0; i < x.length; i++) {
    double value = x[i] > minMax[1]
        ? minMax[1]
        : (x[i] * 1.0 < minMax[0] ? minMax[0] : x[i] * 1.0);
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
        getTextStyles: (value) => const TextStyle(
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
        getTextStyles: (value) => const TextStyle(
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
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: x.length * 1.0,
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
              gradientColors.map((color) => color?.withOpacity(0.1)).toList(),
        ),
      ),
    ],
  );
}

LineChartData runTime(List<int> input) {
  List<int> x =
      (input.length > 200) ? input.sublist(input.length - 200) : input;
  final List<double> minMax = [0, 10000];
  List<FlSpot> spotsX = [];
  double max = 0;
  for (int i = 0; i < x.length; i++) {
    double value = x[i] > minMax[1]
        ? minMax[1]
        : (x[i] * 1.0 < minMax[0] ? minMax[0] : x[i] * 1.0);
    max = (max > value) ? max : value;
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
        getTextStyles: (value) => const TextStyle(
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
        getTextStyles: (value) => const TextStyle(
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
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: x.length * 1.0,
    minY: 0,
    maxY: max,
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
              gradientColors.map((color) => color?.withOpacity(0.1)).toList(),
        ),
      ),
    ],
  );
}

LineChartData accelometerData(AcceleroMeter accelerometer) {
  final List<double> minMax = [-15, 15];
  List<FlSpot> spotsX = [];
  List<double> x = accelerometer.getXBuffer();
  for (int i = 0; i < x.length; i++) {
    double value =
        x[i] > minMax[1] ? minMax[1] : (x[i] < minMax[0] ? minMax[0] : x[i]);
    spotsX.add(FlSpot(i * 1.0, value));
  }
  if (spotsX.length == 0) {
    spotsX.add(FlSpot(0, 0));
  }
  List<FlSpot> spotsY = [];
  List<double> y = accelerometer.getYBuffer();
  for (int i = 0; i < y.length; i++) {
    double value =
        y[i] > minMax[1] ? minMax[1] : (y[i] < minMax[0] ? minMax[0] : y[i]);
    spotsY.add(FlSpot(i * 1.0, value));
  }
  if (spotsY.length == 0) {
    spotsY.add(FlSpot(0, 0));
  }
  List<FlSpot> spotsZ = [];
  List<double> z = accelerometer.getZBuffer();
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
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 10,
        getTextStyles: (value) => const TextStyle(
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
        showTitles: true,
        getTextStyles: (value) => const TextStyle(
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
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: accelerometer.bufferLength * 1.0,
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
              gradientColors.map((color) => color?.withOpacity(0.1)).toList(),
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
              gradientColorsY.map((color) => color?.withOpacity(0.1)).toList(),
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
              gradientColorsZ.map((color) => color?.withOpacity(0.1)).toList(),
        ),
      ),
    ],
  );
}

LineChartData mainData(List<dynamic> answer) {
  List<FlSpot> spots = [];
  if (answer.length == 0) {
    spots.add(FlSpot(0, 0));
  }

  print("Points found: $answer");
  for (Map point in answer) {
    if (point.containsKey("in")) {
      spots.add(FlSpot(point["in"], point["out"]));
    }
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
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        getTextStyles: (value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 12),
        getTitles: (value) {
          switch (value) {
          }
          return value.toString();
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (value) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        getTitles: (value) {
          switch (value) {
          }
          return value.toString();
        },
        reservedSize: 12,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: 0,
    maxX: 7,
    minY: -1,
    maxY: 1,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        colors: gradientColors,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color?.withOpacity(0.3)).toList(),
        ),
      ),
    ],
  );
}
