import 'package:flutter/material.dart';
import 'package:m2solar/pages/station_screen.dart';
import 'package:m2solar/pages/splash_screen.dart';
import 'package:m2solar/models/station.dart';

class StationsList extends StatelessWidget {
  final List<Station> listOfStations;

  const StationsList({Key? key, required this.listOfStations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M2Solar'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(
                0.0), // here to allow for movement of button
            child: FloatingActionButton.extended(
                heroTag: 'user',
                label: const Icon(Icons.account_circle_rounded, size: 30.0),
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage(title: "Test")),
                  );
                }),
          )
        ],
        backgroundColor: Colors.black87,
      ),
      body: ListView.builder(
          itemCount: listOfStations.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StationScreen(station: listOfStations[index])),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Card(
                  color: Colors.black87,
                  shadowColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: const EdgeInsets.all(1.0),
                  child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listOfStations[index].name,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                          Row(children: [
                            const Text("Latitude: ",
                                style: TextStyle(color: Colors.white)),
                            Text(listOfStations[index].latitude.toString(),
                                style: const TextStyle(color: Colors.white70)),
                            const Text(" Longitutde ",
                                style: TextStyle(color: Colors.white)),
                            Text(listOfStations[index].longitude.toString(),
                                style: const TextStyle(color: Colors.white70)),
                          ]),
                          Row(children: [
                            const Text("Ports: ",
                                style: TextStyle(color: Colors.white)),
                            Text(listOfStations[index].ports.toString(),
                                style: const TextStyle(color: Colors.white70)),
                          ]),
                        ],
                      )),
                ),
              ),
            );
          }),
    );
  }
}
