import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class DataVisualizationScreen extends StatefulWidget {
  const DataVisualizationScreen({super.key});
  static const String id = 'data_screen';

  @override
  State<DataVisualizationScreen> createState() =>
      _DataVisualizationScreenState();
}

class _DataVisualizationScreenState extends State<DataVisualizationScreen> {
  List<dynamic> _pollutionData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPollutionData();
  }

  Future<void> _fetchPollutionData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:5000/pollution_data'));
    if (response.statusCode == 200) {
      setState(() {
        _pollutionData = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load pollution data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pollution Data Visualization'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Gaseous Pollutants',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildGaseousPollutantsChart(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Particulate Pollutants',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildParticulatePollutantsChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildGaseousPollutantsChart() {
    List<FlSpot> co2Spots = [];
    List<FlSpot> coSpots = [];
    List<FlSpot> h2sSpots = [];
    List<FlSpot> o3Spots = [];
    List<FlSpot> noxSpots = [];
    List<FlSpot> no2Spots = [];
    List<FlSpot> benSpots = [];
    List<FlSpot> ch4Spots = [];
    List<FlSpot> cnSpots = [];
    List<FlSpot> hcnmSpots = [];
    List<FlSpot> xilSpots = [];

    for (var data in _pollutionData) {
      DateTime dateTime = DateTime.parse(data['datetime']);
      double time = dateTime.millisecondsSinceEpoch.toDouble();
      if (data['CO2'] != null)
        co2Spots.add(FlSpot(time, (data['CO2'] as num).toDouble()));
      if (data['CO'] != null)
        coSpots.add(FlSpot(time, (data['CO'] as num).toDouble()));
      if (data['H2S'] != null)
        h2sSpots.add(FlSpot(time, (data['H2S'] as num).toDouble()));
      if (data['O3'] != null)
        o3Spots.add(FlSpot(time, (data['O3'] as num).toDouble()));
      if (data['NOx'] != null)
        noxSpots.add(FlSpot(time, (data['NOx'] as num).toDouble()));
      if (data['NO2'] != null)
        no2Spots.add(FlSpot(time, (data['NO2'] as num).toDouble()));
      if (data['BEN'] != null)
        benSpots.add(FlSpot(time, (data['BEN'] as num).toDouble()));
      if (data['CH4'] != null)
        ch4Spots.add(FlSpot(time, (data['CH4'] as num).toDouble()));
      if (data['CN'] != null)
        cnSpots.add(FlSpot(time, (data['CN'] as num).toDouble()));
      if (data['HCNM'] != null)
        hcnmSpots.add(FlSpot(time, (data['HCNM'] as num).toDouble()));
      if (data['XIL'] != null)
        xilSpots.add(FlSpot(time, (data['XIL'] as num).toDouble()));
    }

    return _buildChart([
      co2Spots,
      coSpots,
      h2sSpots,
      o3Spots,
      noxSpots,
      no2Spots,
      benSpots,
      ch4Spots,
      cnSpots,
      hcnmSpots,
      xilSpots
    ], [
      'CO2',
      'CO',
      'H2S',
      'O3',
      'NOx',
      'NO2',
      'BEN',
      'CH4',
      'CN',
      'HCNM',
      'XIL'
    ]);
  }

  Widget _buildParticulatePollutantsChart() {
    List<FlSpot> pm25Spots = [];
    List<FlSpot> pm10Spots = [];

    for (var data in _pollutionData) {
      DateTime dateTime = DateTime.parse(data['datetime']);
      double time = dateTime.millisecondsSinceEpoch.toDouble();
      if (data['PM2.5'] != null)
        pm25Spots.add(FlSpot(time, (data['PM2.5'] as num).toDouble()));
      if (data['PM10'] != null)
        pm10Spots.add(FlSpot(time, (data['PM10'] as num).toDouble()));
    }

    return _buildChart([pm25Spots, pm10Spots], ['PM2.5', 'PM10']);
  }

  Widget _buildChart(List<List<FlSpot>> spots, List<String> labels) {
    List<LineChartBarData> lines = [];

    for (int i = 0; i < spots.length; i++) {
      lines.add(
        LineChartBarData(
          spots: spots[i],
          isCurved: true,
          barWidth: 2,
          color: Colors.blue,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: false),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 300, // Set a fixed height for the chart
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(date.toString().split(' ')[0]);
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10, // y-axis interval
                  getTitlesWidget: (value, meta) {
                    return Text(value.toString());
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // disable right y-axis labels
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // disable top x-axis labels
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            lineBarsData: lines,
          ),
        ),
      ),
    );
  }
}
