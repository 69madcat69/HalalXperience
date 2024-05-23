import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/admin_dashboard.dart';
import 'screens/HCO_dashboard.dart';
import 'screens/user_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(adminPage());
  //runApp(startPage());
  //runApp(userDashboard());
  //runApp(HCO_Dashboard());
}
