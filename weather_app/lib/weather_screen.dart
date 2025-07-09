import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "London";
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw data["message"];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather app",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [IconButton(onPressed: () {
          setState(() {
            
          });
        }, icon: Icon(Icons.refresh))],
      ),

      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final weatherData = data['list'][0];
          final currentemp = weatherData['main']['temp'];
          final currentweather = weatherData['weather'][0]['main'];
          final currentPressure = weatherData['main']['pressure'];
          final currentHumidity = weatherData['main']['humidity'];
          final currentWindSpeed = weatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "$currentemp K",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Icon(
                                currentweather == "Clouds" ||
                                        currentweather == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 60,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                currentweather,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Hourly Weather Forecast",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                // Weather forecast card
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForecastWeatherItem(
                //           time: data['list'][i + 1]['dt'].toString(),
                //           icon:
                //               data['list'][i + 1]['weather'][0]['main'] ==
                //                           "Clouds" ||
                //                       data['list'][i +
                //                               1]['weather'][0]['main'] ==
                //                           "Rain"
                //                   ? Icons.cloud
                //                   : Icons.sunny,
                //           temp: data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyData = data['list'][index + 1];
                      final iconDataFound =
                          data['list'][index + 1]['weather'][0]['main'];
                      final time = DateTime.parse(hourlyData['dt_txt']);
                      return HourlyForecastWeatherItem(
                        time: DateFormat.j().format(time),
                        icon:
                            iconDataFound == "Clouds" || iconDataFound == "Rain"
                                ? Icons.cloud
                                : Icons.sunny,
                        temp: hourlyData['main']['temp'].toString(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Additional Information cards
                Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformationItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInformationItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInformationItem(
                      value: currentPressure.toString(),
                      label: "pressure",
                      icon: Icons.beach_access,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HourlyForecastWeatherItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const HourlyForecastWeatherItem({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            Icon(icon),
            SizedBox(height: 10),
            Text(temp),
          ],
        ),
      ),
    );
  }
}

class AdditionalInformationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInformationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 8),
        Text(value),
      ],
    );
  }
}
