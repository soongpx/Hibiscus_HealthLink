import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'health_data.dart';

class HealthInsightsPage extends StatelessWidget {
  const HealthInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthData>(context);

    // Prepare datasets for graphs
    final heartRateData = _convertToSpots(healthData.heartRates);
    final spO2Data = _convertToSpots(healthData.spO2Levels);
    final glucoseData = _convertToSpots(healthData.glucoseLevels);
    final cholesterolData = _convertToSpots(healthData.cholesterolLevels);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 254),
      appBar: AppBar(
        title: Text(
          'Health Insights',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 246, 254),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Your Health Insights',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF11698E),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Track your health trends over time.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 24.h),

                // Summary Section
                _buildSummarySection(healthData),
                SizedBox(height: 24.h),

                // Progress Goals
                _buildProgressGoals(healthData),
                SizedBox(height: 12.h),

                // Graphs Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10.r,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Metrics Overview',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF11698E),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Heart Rate Graph
                      HeartRateGraph(
                        title: 'Heart Rate',
                        description: 'Monitor your heart rate for optimal health.',
                        color: Colors.redAccent,
                        dataPoints: heartRateData,
                        dates: _extractDates(healthData.heartRates),
                      ),
                      SizedBox(height: 24.h),

                      // SpO2 Graph
                      SpO2Graph(
                        title: 'SpO2',
                        description: 'Track your oxygen saturation for good health.',
                        color: Colors.blueAccent,
                        dataPoints: spO2Data,
                        dates: _extractDates(healthData.spO2Levels),
                      ),
                      SizedBox(height: 24.h),

                      // Glucose Graph
                      GlucoseGraph(
                        title: 'Glucose Level',
                        description: 'Monitor glucose levels to reduce health risks.',
                        color: Colors.green,
                        dataPoints: glucoseData,
                        dates: _extractDates(healthData.glucoseLevels),
                      ),
                      SizedBox(height: 24.h),

                      // Cholesterol Graph
                      CholesterolGraph(
                        title: 'Cholesterol Level',
                        description: 'Maintain healthy cholesterol levels for a strong heart.',
                        color: Colors.purpleAccent,
                        dataPoints: cholesterolData,
                        dates: _extractDates(healthData.cholesterolLevels),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(HealthData healthData) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF11698E)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your recent health trends at a glance:',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                height: 80,
                child: _buildSummaryMetric(
                    'Heart Rate',
                    healthData.heartRates.isNotEmpty
                        ? '${healthData.heartRates.last['value']} bpm'
                        : 'No Data',
                    Colors.redAccent),
              ),
              SizedBox(
                width: 120,
                height: 80,
                child: _buildSummaryMetric(
                    'SpO2',
                    healthData.spO2Levels.isNotEmpty
                        ? '${healthData.spO2Levels.last['value']}%'
                        : 'No Data',
                    Colors.blueAccent),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 140,
                height: 70,
                child: _buildSummaryMetric(
                    'Glucose Level',
                    healthData.glucoseLevels.isNotEmpty
                        ? '${healthData.glucoseLevels.last['value']} mg/dL'
                        : 'No Data',
                    Colors.green),
              ),
              SizedBox(
                width: 140,
                height: 70,
                child: _buildSummaryMetric(
                    'Cholesterol Level',
                    healthData.cholesterolLevels.isNotEmpty
                        ? '${healthData.cholesterolLevels.last['value']} mg/dL'
                        : 'No Data',
                    Colors.purpleAccent),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
        SizedBox(height: 6.h),
        Text(value,
            style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildProgressGoals(HealthData healthData) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Health Progress',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF11698E)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Visualize how your key health metrics have changed over the past week.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          _buildTrendItem(
            title: 'Heart Rate',
            status: (healthData.heartRates.isNotEmpty &&
                    healthData.heartRates.last['value'] > 100)
                ? 'Rising'
                : 'Stable',
            color: Colors.redAccent,
            message: (healthData.heartRates.isNotEmpty &&
                    healthData.heartRates.last['value'] > 100)
                ? 'Your heart rate is high. Consider relaxation techniques.'
                : 'Heart rate is at normal range.',
          ),
          SizedBox(height: 8.h),
          _buildTrendItem(
            title: 'SpO2',
            status: (healthData.spO2Levels.isNotEmpty &&
                    healthData.spO2Levels.last['value'] < 95)
                ? 'Decreasing'
                : 'Stable',
            color: Colors.blueAccent,
            message: (healthData.spO2Levels.isNotEmpty &&
                    healthData.spO2Levels.last['value'] < 95)
                ? 'SpO2 level is slightly low.'
                : 'SpO2 level is normal.',
          ),
          SizedBox(height: 8.h),
          _buildTrendItem(
            title: 'Glucose Level',
            status: (healthData.glucoseLevels.isNotEmpty &&
                    healthData.glucoseLevels.last['value'] > 100)
                ? 'Rising'
                : 'Stable',
            color: Colors.green,
            message: (healthData.glucoseLevels.isNotEmpty &&
                    healthData.glucoseLevels.last['value'] > 100)
                ? 'Your glucose level is high. Monitor your diet.'
                : 'Your glucose level is within healthy range.',
          ),
          SizedBox(height: 8.h),
          _buildTrendItem(
            title: 'Cholesterol Level',
            status: (healthData.cholesterolLevels.isNotEmpty &&
                    healthData.cholesterolLevels.last['value'] > 200)
                ? 'Rising'
                : 'Stable',
            color: Colors.purpleAccent,
            message: (healthData.cholesterolLevels.isNotEmpty &&
                    healthData.cholesterolLevels.last['value'] > 200)
                ? 'Your cholesterol level is high. Reduce oil intake.'
                : 'Your cholesterol level is within the healthy range.',
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem({
    required String title,
    required String status,
    required Color color,
    required String message,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '\n\n', // two non-breaking spaces
                    style: TextStyle(
                      fontSize: 8.sp,

                    ), // can be default style
                  ),
                  TextSpan(
                    text: '$status - $message',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  List<FlSpot> _convertToSpots(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['value'].toDouble());
    }).toList();
  }

  List<DateTime> _extractDates(List<Map<String, dynamic>> data) {
    return data.map((entry) => entry['date'] as DateTime).toList();
  }
}

class HeartRateGraph extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final List<FlSpot> dataPoints;
  final List<DateTime> dates;

  const HeartRateGraph({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.dataPoints,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    // Check if no data is available
    if (dataPoints.isEmpty || dates.isEmpty) {
      return _buildNoDataContainer(context, title);
    }

    // The rest of the logic is handled by helper methods
    return _buildGraphContainer(context, title, description, color, dataPoints, dates, 'bpm', 5);
  }

  Widget _buildNoDataContainer(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No data available for $title',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildGraphContainer(BuildContext context, String title, String description, Color color,
      List<FlSpot> dataPoints, List<DateTime> dates, String unit, double paddingY) {
    final ValueNotifier<FlSpot?> selectedSpot = ValueNotifier<FlSpot?>(null);
    final double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - paddingY;
    final double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + paddingY;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF11698E),
            ),
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 14.h),

          // Chart
          SizedBox(
            height: 150.h,
            child: ValueListenableBuilder<FlSpot?>(
              valueListenable: selectedSpot,
              builder: (context, spot, child) {
                return Column(
                  children: [
                    Expanded(
                      child: LineChart(
                        _buildLineChartData(dates, dataPoints, minY, maxY, color, selectedSpot, unit),
                      ),
                    ),
                    if (spot != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '${spot.y.toInt()} $unit on ${DateFormat('MM/dd, hh:mm a').format(dates[spot.x.toInt()])}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<DateTime> dates, List<FlSpot> dataPoints, double minY, double maxY,
      Color color, ValueNotifier<FlSpot?> selectedSpot, String unit) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: _buildTitlesData(dates, minY, maxY),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 2,
          spots: dataPoints,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: const FlDotData(show: true),
          showingIndicators: selectedSpot.value != null ? [dataPoints.indexOf(selectedSpot.value!)] : [],
        ),
      ],
      minY: minY,
      maxY: maxY,
      lineTouchData: _buildLineTouchData(dates, selectedSpot, unit),
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> dates, double minY, double maxY) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 18.w,
          getTitlesWidget: (value, _) {
            if (value == minY || value == maxY) {
              return Text(
                '${value.toInt()}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: dates.length > 5 ? (dates.length / 5).ceil().toDouble() : 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < dates.length && index % 2 == 0) {
              return Text(
                DateFormat('MM/dd').format(dates[index]),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _buildLineTouchData(List<DateTime> dates, ValueNotifier<FlSpot?> selectedSpot, String unit) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        tooltipBorder: BorderSide(color: Colors.grey.shade300),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final spot = touchedSpot;
            final dateIndex = spot.x.toInt();
            final date = (dateIndex >= 0 && dateIndex < dates.length)
                ? DateFormat('MM/dd').format(dates[dateIndex])
                : '';
            return LineTooltipItem(
              '${spot.y.toInt()} $unit on $date',
              const TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
      touchCallback: (touchEvent, response) {
        if (response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
          selectedSpot.value = response.lineBarSpots!.first;
        }
      },
      handleBuiltInTouches: true,
    );
  }
}

// Repeat similar no-data checks and `_buildNoDataContainer` for SpO2Graph, GlucoseGraph, and CholesterolGraph.

class SpO2Graph extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final List<FlSpot> dataPoints;
  final List<DateTime> dates;

  const SpO2Graph({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.dataPoints,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty || dates.isEmpty) {
      return _buildNoDataContainer(context, title);
    }

    // Adjust minY and maxY as needed for SpO2
    final ValueNotifier<FlSpot?> selectedSpot = ValueNotifier<FlSpot?>(null);
    final double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2;
    double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2;
    if (maxY > 100) maxY = 100;

    return _buildGraphContainer(context, title, description, color, dataPoints, dates, '%', 5);
  }

  Widget _buildGraphContainer(BuildContext context, String title, String description, Color color,
      List<FlSpot> dataPoints, List<DateTime> dates, String unit, double paddingY) {
    final ValueNotifier<FlSpot?> selectedSpot = ValueNotifier<FlSpot?>(null);
    final double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - paddingY;
    final double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + paddingY;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF11698E),
            ),
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 14.h),

          // Chart
          SizedBox(
            height: 150.h,
            child: ValueListenableBuilder<FlSpot?>(
              valueListenable: selectedSpot,
              builder: (context, spot, child) {
                return Column(
                  children: [
                    Expanded(
                      child: LineChart(
                        _buildLineChartData(dates, dataPoints, minY, maxY, color, selectedSpot, unit),
                      ),
                    ),
                    if (spot != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '${spot.y.toInt()}$unit on ${DateFormat('MM/dd, hh:mm a').format(dates[spot.x.toInt()])}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataContainer(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No data available for $title',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }

  

  LineChartData _buildLineChartData(List<DateTime> dates, List<FlSpot> dataPoints, double minY, double maxY,
      Color color, ValueNotifier<FlSpot?> selectedSpot, String unit) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: _buildTitlesData(dates, minY, maxY),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 2,
          spots: dataPoints,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: const FlDotData(show: true),
          showingIndicators: selectedSpot.value != null ? [dataPoints.indexOf(selectedSpot.value!)] : [],
        ),
      ],
      minY: minY,
      maxY: maxY,
      lineTouchData: _buildLineTouchData(dates, selectedSpot, unit),
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> dates, double minY, double maxY) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 18.w,
          getTitlesWidget: (value, _) {
            if (value == minY || value == maxY) {
              return Text(
                '${value.toInt()}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: dates.length > 5 ? (dates.length / 5).ceil().toDouble() : 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < dates.length && index % 2 == 0) {
              return Text(
                DateFormat('MM/dd').format(dates[index]),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _buildLineTouchData(List<DateTime> dates, ValueNotifier<FlSpot?> selectedSpot, String unit) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        tooltipBorder: BorderSide(color: Colors.grey.shade300),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final spot = touchedSpot;
            final dateIndex = spot.x.toInt();
            final date = (dateIndex >= 0 && dateIndex < dates.length)
                ? DateFormat('MM/dd').format(dates[dateIndex])
                : '';
            return LineTooltipItem(
              '${spot.y.toInt()} $unit on $date',
              const TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
      touchCallback: (touchEvent, response) {
        if (response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
          selectedSpot.value = response.lineBarSpots!.first;
        }
      },
      handleBuiltInTouches: true,
    );
  }
}

// Repeat a similar pattern for GlucoseGraph and CholesterolGraph,
// adding the no-data check and _buildNoDataContainer.

class GlucoseGraph extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final List<FlSpot> dataPoints;
  final List<DateTime> dates;

  const GlucoseGraph({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.dataPoints,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty || dates.isEmpty) {
      return _buildNoDataContainer(context, title);
    }

    final ValueNotifier<FlSpot?> selectedSpot = ValueNotifier<FlSpot?>(null);
    final double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 10;
    final double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10;

    // Replicate chart logic similar to HeartRateGraph or SpO2Graph
    // For simplicity, you could create a shared utility method
    // but here we just show no-data scenario:
    return HeartRateGraph(
      title: title,
      description: description,
      color: color,
      dataPoints: dataPoints,
      dates: dates,
    )._buildGraphContainer(context, title, description, color, dataPoints, dates, 'mg/dL', 10);
  }

  Widget _buildNoDataContainer(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No data available for $title',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }
}

class CholesterolGraph extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final List<FlSpot> dataPoints;
  final List<DateTime> dates;

  const CholesterolGraph({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.dataPoints,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty || dates.isEmpty) {
      return _buildNoDataContainer(context, title);
    }

    final ValueNotifier<FlSpot?> selectedSpot = ValueNotifier<FlSpot?>(null);
    final double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 10;
    final double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10;

    return HeartRateGraph(
      title: title,
      description: description,
      color: color,
      dataPoints: dataPoints,
      dates: dates,
    )._buildGraphContainer(context, title, description, color, dataPoints, dates, 'mg/dL', 10);
  }

  Widget _buildNoDataContainer(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No data available for $title',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ),
    );
  }
}
