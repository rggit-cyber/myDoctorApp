import 'package:doctor_app/login_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //
  Stripe.publishableKey =
      "pk_test_51Qvvon00BO3mx0P1sr3yC2O5jOgnJ3VCMRjE7D2qFMTjaDVqzfd5aHsilvKRuO1R8vziz9TeogZh1Z5oKj5oquJS00YiUK6bnP";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hospital Management App',
        home: LoginType()
        // HomePage(),
        );
  }
}
