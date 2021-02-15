import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final String data;
  const Home({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Flutter BLE Example",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              //How to display data with equation
              Text(
                (this.data == null
                    ? "--"
                    : (int.parse(this.data.toString().split(',')[0]) + 10)
                        .toString()),
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
