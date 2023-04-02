import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //geolocator code
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
    print(
        "My Latitude is ${position!.latitude} Longitute is ${position!.longitude}");
  }

  Position? position;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  //api calling system with map

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=4bf57ffc86d378aa6a06548c360ae10b&units=metric")); //&units=metric celcius converter code

    var forecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=4bf57ffc86d378aa6a06548c360ae10b&units=metric")); //&units=metric celcius converter code

    var weatherData = jsonDecode(weather.body);
    var forecastData = jsonDecode(forecast.body);

    setState(() {
      weatherMap = Map<String, dynamic>.from(weatherData);
      forecastMap = Map<String, dynamic>.from(forecastData);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap != null
          ? Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 30,),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //default time collection
                      //Text("${Jiffy.parse('${DateTime.now()}').format(pattern: 'MMMM do yyyy, h:mm:ss a')}"),
                      //api time collection
                      Text("${weatherMap!["name"]}",style: TextStyle(fontSize: 30),),
                      Text(
                          "${Jiffy.parse('${DateTime.now()}').format(pattern: 'MMM do yyyy, h:mm')}"),

                    ],
                  ),
                ),
                Image.network(
                  "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]["icon"]}@2x.png",
                ),
                Text(
                  "${weatherMap!["main"]["temp"]} °",
                  style: TextStyle(fontSize: 24),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(

                    children: [
                      Text(
                        "Feels Like: ${weatherMap!["main"]["feels_like"]}",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Description: ${weatherMap!["weather"][0]["description"]}",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Humidity: ${weatherMap!["main"]["humidity"]}, Pressure: ${weatherMap!["main"]["pressure"]}",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Sunrise: ${Jiffy.parse("${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format(pattern: "hh mm a")}, Sunset: ${Jiffy.parse("${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format(pattern: "hh mm a")}",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                SizedBox(
                  height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: forecastMap!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.blueGrey[300],
                          width: 150,
                          margin: EdgeInsets.only(right: 12),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${Jiffy.parse("${forecastMap!["list"][index]["dt_txt"]}").format(pattern: "EEE h:mm:")}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Image.network(
                                  "https://openweathermap.org/img/wn/${forecastMap!["list"][index]["weather"][0]["icon"]}@2x.png",
                                ),
                                Text(
                                    "${forecastMap!["list"][index]["main"]["temp_min"]} / ${forecastMap!["list"][index]["main"]["temp_max"]}"),
                                Text(
                                    "${forecastMap!["list"][index]["weather"][0]["description"]} "),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
