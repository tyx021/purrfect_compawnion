import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:purrfect_compawnion/shared/loading.dart';
import '../../models/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  Weather? weather;
  final String APP_ID = '397ae723cbabc3756170e7a70b4c8869';
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return weather == null
    ? Loading()
    : Scaffold(
      appBar: AppBar(
        title: Text('Weather',
          style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.red[200],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(

            //BACKGROUND!!!!!!!!!!!!

            //image: AssetImage("assets/rainbg.jpg"),
            image: AssetImage("assets/sunnybg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Singapore",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 40,
                              color: Colors.white),
                        ),
                      ),
                      Text("Chinese Garden, Singapore",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      Text(" 31°",
                        style: GoogleFonts.heebo(
                          textStyle: TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.w200,
                              color: Colors.white),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("clear",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black54),
                              ),
                            ),
                            SizedBox(width: 40,),
                            Text("clear sky",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black54),
                              ),
                            ),
                          ]
                      ),
                      // Text("Rainy",
                      //   style: GoogleFonts.lato(
                      //     textStyle: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.w300,
                      //         color: Colors.white),
                      //   ),
                      // ),
                      SizedBox(height: 10,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("H: 34°",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54),
                              ),
                            ),
                            SizedBox(width: 50,),
                            Text("L: 29°",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54),
                              ),
                            ),
                          ]
                      ),

                    ],
                  ),
                  Expanded(
                      flex: 5,

                      //SOCCAT ANIMATION !!!!!!!!!!!

                      //child: Image.asset('assets/rainanimation.GIF')
                      child: Image.asset('assets/sunanimation2.GIF')
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("sunrise time: 05 00",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54),
                              ),
                            ),
                          ]
                      )
                  )

                  // Expanded(
                  //     flex: 1,
                  //     child: Container())
                ]
            )
        ),
      ),
    );
  }

  Future getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }
  Future getWeather() async {
    try {
      await getLocation();
      Response response = await get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${_locationData.latitude}&lon=${_locationData.longitude}&appid=${APP_ID}'));
      Map data = jsonDecode(response.body);

      var weatherData = jsonDecode(jsonEncode(data['weather'][0]));
      print("weatherData");
      var mainData = jsonDecode(jsonEncode(data['main']));
      print("main");
      var sysData = jsonDecode(jsonEncode(data['sys']));
      print("sys");


      setState(() => weather = Weather(
        id: weatherData['id'],
        main: weatherData['main'],
        description: weatherData['description'],
        icon: weatherData['icon'],
        temp: mainData['temp'],
        temp_min: mainData['temp_min'],
        temp_max: mainData['temp_max'],
        country: sysData['country'],
        sunrise: DateTime.fromMillisecondsSinceEpoch(sysData['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(sysData['sunset'] * 1000),
        city: data['name'],
      ));
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }

}

