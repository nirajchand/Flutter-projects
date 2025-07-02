import 'package:currency_converter/currency_converter_material_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Types of widget
// 1. Statelesswidget
// 2. Statefulwidget

// types of design
// 1. material design (made by google)
// 2.cupertino design (made by ios)

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CurrencyConverterMaterialPage(),
    );
  }
}
