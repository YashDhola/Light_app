import 'dart:convert';

import 'package:demo/map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class feedbackform extends StatelessWidget {
  late String streetlight_id;
  late String Village;
  late int Pincode;
  late String Taluka;
  late String District;

  feedbackform(
      {required this.streetlight_id,
      required this.Village,
      required this.Pincode,
      required this.Taluka,
      required this.District});

  @override
  Widget build(BuildContext context) {
    var costController = TextEditingController();
    var issueController = TextEditingController();
    String _url =
        "https://heroku-backend-hackathone.herokuapp.com/api/history/addHistory";

    _feedbacksubmit() async {
      var data = {
        "streetLightId": streetlight_id,
        "cost": costController.text,
        "issue": issueController.text,
        "village": Village,
        "taluka": Taluka,
        "district": District,
        "workerId": "SS11",
        "repairedBy": "yash_Dhola",
        "pincode": Pincode
      };
      var response = await http.post(Uri.parse(_url),
          body: json.encode(data),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      Map res = jsonDecode(response.body);
      if (res["status"] == 200) {
        await Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CurrentLocationScreen()));
      }
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("FeedBack Form"),
          backgroundColor: Color.fromRGBO(61, 62, 63, 1),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: costController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Cost',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: issueController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Issue',
                ),
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                    child: const Text('Submit'),
                    style: ElevatedButton.styleFrom(primary: Color.fromRGBO(61, 62, 63, 1)),
                    onPressed: () async {
                      await _feedbacksubmit();
                    })),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
