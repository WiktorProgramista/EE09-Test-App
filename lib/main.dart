import 'package:ee09/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
    debugShowCheckedModeBanner: false,
    title: 'EE09 Egzamin',
    home: const HomePage(),
  ));
}
