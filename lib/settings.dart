import 'package:flutter/material.dart';

class SettingPopUp extends StatefulWidget {
  SettingPopUp({Key key, this.data}) : super(key: key);
  final String data;

  @override
  _SettingPopUpState createState() => _SettingPopUpState();
}

class _SettingPopUpState extends State<SettingPopUp> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height / 5,
        width: MediaQuery.of(context).size.width / 0.1,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              right: -40.0,
              top: -40.0,
              child: InkResponse(
                onTap: () {
                  myController.clear();
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  child: Icon(Icons.close),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Text(
                //   "Settings",
                //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Value a: ",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[900]),
                    ),
                    Text(
                      (widget.data == null
                          ? "--"
                          : (int.parse(widget.data.toString().split(',')[0]))
                              .toString()),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Value b: ",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange),
                    ),
                    Text(
                      (widget.data == null
                          ? "--"
                          : (int.parse(widget.data.toString().split(',')[1]))
                              .toString()),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
