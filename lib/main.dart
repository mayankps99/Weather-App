import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'Util/resources.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WeatherAppScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C2B4B),
      body: Column(
        children: <Widget>[
          SizedBox
          (
            height: 20,
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Container(
                  width: 450,
                  height: 450,
                  child: Column
                  (
                    children: <Widget>[
                      Container(
                        width: 300,
                        height: 300,
                        child: Icon(
                          Icons.ac_unit,
                          color: Colors.white,
                          size: 150,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Weather',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: 250,
              height: 10,
              child: Center(
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xff2C2B4B),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherAppScreen extends StatefulWidget {
  @override
  _WeatherAppScreenState createState() => _WeatherAppScreenState();
}

class _WeatherAppScreenState extends State<WeatherAppScreen> {
  Position _currentPosition;
  static double latitude, longitude;
  void getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        getTemp();
      });
    }).catchError((e) {
      print(e);
    });
  }

  var currentTemp, nextHour, nextDay;

  void getTemp() async {
    String url;
    setState(() {
      url = 'https://api.openweathermap.org/data/2.5/onecall?lat=' +
          latitude.toString() +
          '&lon=' +
          longitude.toString() +
          '&%20exclude=minutely&appid={YOUR_API_KEY}';
    });
    var res = await http.get(url, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    Map<String, dynamic> map = jsonDecode(res.body);
    if (!mounted) return;
    setState(() {
      currentTemp = map["current"]["temp"] - 273;
      nextHour = map["hourly"][1]["temp"] - 273;
      nextDay = map["daily"][1]["temp"]["day"] - 273;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentLocation();
    latitude = 0.0;
    longitude = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'Weather',
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 50.0,
                        ),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 35,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'lat: ${latitude}',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'lon: ${longitude}',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Temperature',
                                style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: 25,
                                    color: fontMedium),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              currentTemp == null
                                  ? Column(
                                    children: <Widget>[
                                      SizedBox(height: 30,),
                                      Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Color(0xff2C2B4B),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                    ],
                                  )
                                  : Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Current',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${currentTemp.toString().substring(0, (currentTemp.toString().indexOf('.') + 3))} \u00B0C',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Next Hour',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${nextHour.toString().substring(0, (nextHour.toString().indexOf('.') + 3))} \u00B0C',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Next Day',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${nextDay.toString().substring(0, (nextDay.toString().indexOf('.') + 3))}  \u00B0C',
                                              style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  fontSize: 25,
                                                  color: fontMedium),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
