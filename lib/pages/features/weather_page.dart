import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:purrfect_compawnion/shared/loading.dart';
import '../../models/weather.dart';
import '../../shared/error_page.dart';

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
  bool loading = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return loading
    ? Loading()
    : !_isDataLoaded
        ? ErrorPage()
        : Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('Weather',
              style: TextStyle(color: Colors.white),),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(

                //BACKGROUND!!!!!!!!!!!!
                //image: AssetImage("assets/rainbg.jpg"),
                image:
                weather!.main == "Clouds" || weather!.main == "Atmosphere"
                    ? AssetImage("assets/cloudy.jpg")
                    : weather!.main == "Clear"
                    ? AssetImage("assets/sunnybg.jpg")
                    : weather!.main == "Snow"
                    ? AssetImage("assets/snowybg.jpg")
                    : AssetImage("assets/rainbg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
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
                            Text(weather!.country,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 40,
                                    color:
                                    weather!.main == "Clouds" || weather!.main == "Atmosphere"
                                        ? Colors.black54
                                        : Colors.white),
                              ),
                            ),
                            Text(weather!.city,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    color: weather!.main == "Clouds" || weather!.main == "Atmosphere"
                                        ? Colors.black54
                                        : Colors.white),
                              ),
                            ),
                            Text("${weather!.temp.roundToDouble()}°",
                              style: GoogleFonts.heebo(
                                textStyle: TextStyle(
                                    fontSize: 90,
                                    fontWeight: FontWeight.w200,
                                    color: weather!.main == "Clouds" || weather!.main == "Atmosphere"
                                        ? Colors.black54
                                        : Colors.white),
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(weather!.main,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                          ? Colors.white
                                          : Colors.black54),
                                    ),
                                  ),
                                  SizedBox(width: 40,),
                                  Text(weather!.description,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                              ? Colors.white
                                              : Colors.black54),
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
                                  Text("H: ${weather!.temp_max.roundToDouble()}°",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                              ? Colors.white
                                              : Colors.black54),
                                    ),
                                  ),
                                  SizedBox(width: 50,),
                                  Text("L: ${weather!.temp_min.roundToDouble()}°",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                              ? Colors.white
                                              : Colors.black54),
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
                            child:
                            weather!.main == "Clouds" || weather!.main == "Atmosphere"
                                ? Image.asset('assets/masksoccat.GIF')
                                : weather!.main == "Clear"
                                ? Image.asset('assets/sunanimation2.GIF')
                                : weather!.main == "Snow"
                                ? Image.asset('assets/snowsoccat.GIF')
                                : Image.asset('assets/rainanimation.GIF')

                        ),
                        Expanded(
                            flex: 1,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("sunrise time: ${DateFormat("HH:mm").format(weather!.sunrise)}",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                              ? Colors.white
                                              : Colors.black54),
                                    ),
                                  ),
                                  Text("sunset time: ${DateFormat("HH:mm").format(weather!.sunset)}",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color:
                                          weather!.main == "Rain" ||  weather!.main == "Drizzle" ||  weather!.main == "Thunderstorm"
                                              ? Colors.white
                                              : Colors.black54),
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
          ),
        );
  }

  Future getLocation() async {
    loading = true;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        loading = false;
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        loading = false;
        return;
      }
    }
    _locationData = await location.getLocation();
  }

  Future getWeather() async {
    try {
      await getLocation();
      await CountryCodes.init();
      // To get weather data
      Response response = await get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${_locationData.latitude}&lon=${_locationData.longitude}&appid=${APP_ID}'));
      Map data = jsonDecode(response.body);

      // To get location data (city name)
      Response geoResponse = await get(Uri.parse('http://api.openweathermap.org/geo/1.0/reverse?lat=${_locationData.latitude}&lon=${_locationData.longitude}&limit=1&appid=${APP_ID}'));
      List geoDataList = jsonDecode(geoResponse.body);
      Map geoData = geoDataList[0];
      print('http://api.openweathermap.org/geo/1.0/reverse?lat=${_locationData.latitude}&lon=${_locationData.longitude}&limit=1&appid=${APP_ID}');

      // To get country name
      // CountryDetails myLocale = CountryCodes.detailsForLocale();
      var weatherData = jsonDecode(jsonEncode(data['weather'][0]));
      var mainData = jsonDecode(jsonEncode(data['main']));
      var sysData = jsonDecode(jsonEncode(data['sys']));
        weather = Weather(
          id: weatherData['id'],
          main: weatherData['main'],
          description: weatherData['description'],
          icon: weatherData['icon'],
          temp: mainData['temp'] - 273.15,
          temp_min: mainData['temp_min'] - 273.15,
          temp_max: mainData['temp_max'] - 273.15,
          country: geoData['country'],
          sunrise: DateTime.fromMillisecondsSinceEpoch(sysData['sunrise'] * 1000),
          sunset: DateTime.fromMillisecondsSinceEpoch(sysData['sunset'] * 1000),
          city: geoData['name'],
        );

      setState(() {
        loading = false;
        _isDataLoaded = true;
      });
    } catch(e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }

}

