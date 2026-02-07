


import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstant {
  // This looks into your .env file for the value next to 'publishableKey'
  static String publishableKey = dotenv.env['publishableKey'] ?? "";

  // This looks for the value next to 'secretKey'
  static String secretKey = dotenv.env['secretKey'] ?? "";
}