import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
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
    lat = position!.latitude;
    lon = position!.longitude;
    print("position is ${position!.latitude}  ${position!.longitude}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=1584f9980d28c90848d36312e18c7919";

    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=1584f9980d28c90848d36312e18c7919";

    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });

    print("ppppppppppppppppppppppppp${weatherResponce.body}");
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var farenhight = weatherMap!["main"]["temp"];
    var celcious = farenhight - 273.15;
    var feelsLike = weatherMap!["main"]["feels_like"] - 273.15;
    var maxTem = weatherMap!["main"]["temp_max"] - 273.15;
    var minTem = weatherMap!["main"]["temp_min"] - 273.15;
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
          centerTitle: true,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20), child: Icon(Icons.menu))
          ],
          backgroundColor: Colors.blueAccent,
          leading: Icon(Icons.add),
          title: Text("${weatherMap!["name"]}")),
      body: weatherMap == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Text(
                    "${Jiffy(DateTime.now()).format("MMM do yy, h:mm")}",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("${celcious.round()} °",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26)),
                  Text("Feels like ${feelsLike.round()} °",
                      style: TextStyle(
                          color: Colors.redAccent.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 26)),
                  Text("${weatherMap!["weather"][0]["description"]}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(weatherMap!["weather"][0]["main"] ==
                            "haze"
                        ? "https://images.pexels.com/photos/2529973/pexels-photo-2529973.jpeg?cs=srgb&dl=pexels-trace-hudson-2529973.jpg&fm=jpg"
                        : weatherMap!["weather"][0]["main"] == "Clear"
                            ? "https://img.freepik.com/free-photo/white-clouds-with-blue-sky-background_1253-224.jpg?w=2000"
                            : "https://media.istockphoto.com/photos/storm-sky-rain-picture-id512218646?k=20&m=512218646&s=612x612&w=0&h=C-2Gn8nsMG-o7QNiXYPqu4FeJJFABhPpe4rTG0CIMWQ="),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      "Humidity :${weatherMap!["main"]["humidity"]} Pressure :${weatherMap!["main"]["pressure"]}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(
                      "Sunrise :${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}  sunset :${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: forecastMap!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.teal.withOpacity(.9)),
                              width: 90,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE, h:mm")}"),
                                  Icon(
                                    weatherMap!["weather"][0]["main"] == "Clear"
                                        ? Icons.sunny
                                        : Icons.foggy,
                                  ),
                                  Text(
                                      "${forecastMap!["list"][index]["weather"][0]["description"]}"),
                                  Text("Max ${maxTem.round()}"),
                                  Text("Max ${minTem.round()}")
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
    );
  }
}
