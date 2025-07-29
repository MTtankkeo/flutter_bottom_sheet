import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter_scroll_bottom_sheet/flutter_bottom_sheet.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: TestView())
      ),
    );
  }
}

class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          BottomSheet.open(context, ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: 100,
            itemBuilder: (context, index) {
              return Text("Hello, World!");
            },
          ));
        },
        child: Text("Oepn Bottom Sheet"),
      ),
    );
  }
}