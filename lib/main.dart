import 'package:blog_forum/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:blog_forum/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: StyledTitle("Blog App"),
          centerTitle: true,
        ),
        body: Center(
          child: StyledText('Blog Forum'),
        ),
      ),
      theme: defaultTheme,
    );
  }
}