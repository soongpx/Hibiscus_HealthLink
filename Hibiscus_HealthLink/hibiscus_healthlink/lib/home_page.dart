import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'health_data.dart';
import 'community_support_page.dart';
import 'lifestyle_management_page.dart';
import 'resource_article_page.dart';
import 'bluetooth_connect.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ValueNotifier<DateTime?> lastSyncNotifier =
      ValueNotifier<DateTime?>(null);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final healthData = Provider.of<HealthData>(context, listen: false);

    if (user != null) {
      healthData.setUserId(user.uid);
    }

    return Consumer<HealthData>(
      builder: (context, healthData, child) {
        if (healthData.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Determine the latest date from the fetched data
        DateTime? latestDate = _findLatestDate(healthData);

        // Update lastSyncNotifier if we have a latest date
        if (latestDate != null) {
          lastSyncNotifier.value = latestDate;
        }

        // Prepare values and chart data
        final heartRateValue = healthData.heartRates.isNotEmpty
            ? healthData.heartRates.last['value'].toString()
            : 'No Data';
        final List<FlSpot> heartRateSpots = healthData.heartRates.isNotEmpty
            ? _prepareChartData(healthData.heartRates)
            : [];

        final spO2Value = healthData.spO2Levels.isNotEmpty
            ? healthData.spO2Levels.last['value'].toString()
            : 'No Data';
        final List<FlSpot> spO2Spots = healthData.spO2Levels.isNotEmpty
            ? _prepareChartData(healthData.spO2Levels)
            : [];

        final glucoseValue = healthData.glucoseLevels.isNotEmpty
            ? healthData.glucoseLevels.last['value'].toString()
            : 'No Data';
        final List<FlSpot> glucoseSpots = healthData.glucoseLevels.isNotEmpty
            ? _prepareChartData(healthData.glucoseLevels)
            : [];

        final cholesterolValue = healthData.cholesterolLevels.isNotEmpty
            ? healthData.cholesterolLevels.last['value'].toString()
            : 'No Data';
        final List<FlSpot> cholesterolSpots =
            healthData.cholesterolLevels.isNotEmpty
                ? _prepareChartData(healthData.cholesterolLevels)
                : [];

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 246, 254),
          appBar: AppBar(
            title: Text(
              'Home',
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
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  Text(
                    '👋 Hello, Peng Xiang',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<DateTime?>(
                        valueListenable: lastSyncNotifier,
                        builder: (context, lastSync, _) {
                          return Text(
                            'Last sync: \n${lastSync != null ? DateFormat('MM/dd/yyyy HH:mm').format(lastSync) : 'Never'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          );
                        },
                      ),
                      BluetoothSyncButton(
                        esp32DeviceName: 'ESP32 Heart Rate Monitor',
                        onDataReceived: (data) {
                          // If you also want to update last sync on Bluetooth receive:
                          // lastSyncNotifier.value = DateTime.now();
                          // But now we rely on data from Firestore, so no need here.
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Health Metrics Section
                  _buildMetricsRow([
                    _buildMetricWithChart(
                      title: 'Heart Rate',
                      value: heartRateValue,
                      unit: 'bpm',
                      chartData: heartRateSpots,
                      color: Colors.red,
                    ),
                    _buildMetricWithChart(
                      title: 'SpO2',
                      value: spO2Value,
                      unit: '%',
                      chartData: spO2Spots,
                      color: Colors.blue,
                    ),
                  ]),
                  SizedBox(height: 16.h),
                  _buildMetricsRow([
                    _buildMetricWithChart(
                      title: 'Glucose Level',
                      value: glucoseValue,
                      unit: '\nmg/dL',
                      chartData: glucoseSpots,
                      color: Colors.green,
                    ),
                    _buildMetricWithChart(
                      title: 'Cholesterol Level',
                      value: cholesterolValue,
                      unit: '\nmg/dL',
                      chartData: cholesterolSpots,
                      color: Colors.purple,
                    ),
                  ]),

                  _buildHealthAlertsSection(healthData),
                  SizedBox(height: 24.h),

                  // Actionable Buttons
                  _buildFeaturesSection(context),
                  SizedBox(height: 24.h),

                  // Featured Articles
                  _buildSectionTitle('📚 Featured Articles'),
                  _buildArticlesCarousel(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _prepareChartData(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble(), (entry.value['value'] as num).toDouble());
    }).toList();
  }

  Widget _buildMetricWithChart({
    required String title,
    required String value,
    required String unit,
    required List<FlSpot> chartData,
    required Color color,
  }) {
    final hasData = value != 'No Data' && chartData.isNotEmpty;

    // If we have data, find min and max values
    double minY = 0;
    double maxY = 100; // A default range, adjust as needed

    if (hasData) {
      final double dataMin =
          chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      final double dataMax =
          chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

      // Add some padding or choose a fixed range to increase scale
      minY =
          (dataMin - 10).clamp(0, double.infinity); // Ensure not going below 0
      maxY = dataMax + 10; // Increase top scale by 10 units
    }

    return Container(
      width: (1.sw / 2) - 24.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8.r)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8.h),
          if (hasData) ...[
            Text('$value $unit',
                style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 8.h),
            SizedBox(
              height: 60.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: minY, // Set the minimum Y axis value
                  maxY: maxY, // Set the maximum Y axis value
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      spots: chartData,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // If no data, show this text
            Text(
              'No data available',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 30.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAlertsSection(HealthData healthData) {
    final List<Widget> alerts = [];

    if (healthData.glucoseLevels.isNotEmpty &&
        healthData.glucoseLevels.last['value'] > 250 &&
        healthData.heartRates.isNotEmpty &&
        healthData.heartRates.last['value'] > 100) {
      alerts.add(_buildAlertItem(
          'Diabetic Ketoacidosis (DKA) is noticed. \nIf you have nausea and vomiting, seek doctor immediately!'));
    }

    if (healthData.glucoseLevels.isNotEmpty &&
        healthData.glucoseLevels.last['value'] < 50 &&
        healthData.heartRates.isNotEmpty &&
        healthData.heartRates.last['value'] > 100) {
      alerts.add(_buildAlertItem(
          'Hypoglycemic Shock is noticed. \nIf you have sweating and dizziness, seek doctor immediately!'));
    }

    if (healthData.glucoseLevels.isNotEmpty &&
        healthData.spO2Levels.last['value'] < 90 &&
        healthData.heartRates.isNotEmpty &&
        (healthData.heartRates.last['value'] > 100 ||
            healthData.heartRates.last['value'] < 60)) {
      alerts.add(_buildAlertItem(
          'Hypoxia is noticed. \nIf you have cyanosis and short of breath, seek doctor immediately!'));
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        SizedBox(height: 8.h),
        _buildSectionTitle('🚨 Health Alerts'),
        SizedBox(height: 8.h),
        ...alerts,
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 Features',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF11698E),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(context, 'Community \nSupport', Icons.group,
                  Colors.blue, const CommunitySupportPage()),
              _buildActionButton(
                  context,
                  'Lifestyle \nManagement',
                  Icons.fitness_center,
                  Colors.green,
                  const LifestyleManagementPage()),
              _buildActionButton(context, 'Resources \n& Articles', Icons.book,
                  Colors.orange, const ResourcesArticlesPage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesCarousel() {
    final List<Map<String, String>> articles = [
      {
        "title": "5 Simple Tips to Maintain a Healthy Heart",
        "description":
            "Learn how to keep your heart healthy with these easy lifestyle changes, including regular exercise and balanced eating."
      },
      {
        "title": "The Importance of SpO2 Monitoring in Daily Life",
        "description":
            "Discover why tracking your blood oxygen levels can be a critical part of managing your overall health."
      },
      {
        "title": "Understanding Cholesterol: Good vs. Bad",
        "description":
            "Break down the facts about cholesterol and how it impacts your cardiovascular health."
      },
      {
        "title": "How to Maintain Balanced Blood Sugar Levels",
        "description":
            "Manage your glucose levels effectively with these diet and exercise strategies."
      },
      {
        "title": "Top 10 Foods to Boost Your Immune System",
        "description":
            "Enhance your body’s defenses with these nutrient-packed foods."
      },
    ];

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 8.r)
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article["title"]!,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    article["description"]!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(List<Widget> cards) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cards,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF11698E),
      ),
    );
  }

  DateTime? _findLatestDate(HealthData healthData) {
    List<DateTime?> lastDates = [];
    if (healthData.heartRates.isNotEmpty) {
      lastDates.add(healthData.heartRates.last['date'] as DateTime);
    }
    if (healthData.spO2Levels.isNotEmpty) {
      lastDates.add(healthData.spO2Levels.last['date'] as DateTime);
    }
    if (healthData.glucoseLevels.isNotEmpty) {
      lastDates.add(healthData.glucoseLevels.last['date'] as DateTime);
    }
    if (healthData.cholesterolLevels.isNotEmpty) {
      lastDates.add(healthData.cholesterolLevels.last['date'] as DateTime);
    }

    // Find the maximum of the available dates
    DateTime? maxDate;
    for (var d in lastDates) {
      if (d != null) {
        if (maxDate == null || d.isAfter(maxDate)) {
          maxDate = d;
        }
      }
    }
    return maxDate;
  }
}
