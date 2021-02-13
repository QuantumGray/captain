import 'package:captain/captain.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    CaptainApp(),
  );
}

class CaptainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Captain(
          config: CaptainConfig(pages: [
        MaterialPage(
          child: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  child: Text("original page"),
                  onPressed: () {
                    Navigator.of(context).actionFunc((pageStack) => pageStack
                      ..add(MaterialPage(
                          child: Scaffold(
                        appBar: AppBar(title: Text("added page")),
                      ))));
                  },
                ),
              ),
            ),
          ),
        ),
      ])),
    );
  }
}
