import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerTimesApp extends StatefulWidget {
  @override
  _PrayerTimesAppState createState() => _PrayerTimesAppState();
}

class _PrayerTimesAppState extends State<PrayerTimesApp> {
  String prayerTimesUrl =
      'http://api.aladhan.com/v1/timingsByCity/07-07-2023?city=Kuala+Lumpur&country=Malaysia&method=8';
  Map<String, String> prayerTimes = {};
  String hijriDate = '';

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
    fetchHijriDate();
  }

  Future<void> fetchPrayerTimes() async {
    try {
      final response = await http.get(Uri.parse(prayerTimesUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        setState(() {
          prayerTimes = timings.cast<String, String>();
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchHijriDate() async {
    var gregorianDate = '12-05-2023'; // Specify your desired Gregorian date
    var hijriApiUrl = 'http://api.aladhan.com/v1/gToH/$gregorianDate';

    try {
      final response = await http.get(Uri.parse(hijriApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          setState(() {
            hijriDate = data['data']['hijri']['date'];
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  heightFactor: 0.45, // Adjust the height factor as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        'Prayer Times - Kuala Lumpur',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      if (prayerTimes.isEmpty)
                        CircularProgressIndicator()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrayerTimeItem(
                              title: 'Fajr',
                              time: prayerTimes['Fajr']!,
                            ),
                            PrayerTimeItem(
                              title: 'Sunrise',
                              time: prayerTimes['Sunrise']!,
                            ),
                            PrayerTimeItem(
                                title: 'Dhuhr', time: prayerTimes['Dhuhr']!),
                            PrayerTimeItem(
                              title: 'Asr',
                              time: prayerTimes['Asr']!,
                            ),
                            PrayerTimeItem(
                              title: 'Maghrib',
                              time: prayerTimes['Maghrib']!,
                            ),
                            PrayerTimeItem(
                              title: 'Isha',
                              time: prayerTimes['Isha']!,
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Text(
                        'Hijri Date: $hijriDate',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Note: Prayer times are based on the Gulf Region method.',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerTimeItem extends StatelessWidget {
  final String title;
  final String time;

  const PrayerTimeItem({
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
