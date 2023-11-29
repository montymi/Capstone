import 'package:flutter/material.dart';
import '../models/station.dart';

class StationScreen extends StatefulWidget {
  final Station station;
  const StationScreen({Key? key, required this.station}) : super(key: key);

  @override
  _StationScreenState createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  int? twoDigitInputValue; // Store the value entered by the user
  int? portNum; // Variable to store the selected dropdown value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("M2Solar"),
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/station_marker_black.png', // Replace with your actual image path
                      height: 50, // Adjust the height as needed
                      width: 50,
                    ),
                    Title(
                      color: Colors.black, 
                      child: Text(widget.station.name, style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: PortDropDownWidget(
                  ports: widget.station.ports,
                  onPortSelected: (value) {
                    setState(() {
                      portNum = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150, // Adjust the height as needed
                    width: 250,
                    child: TwoDigitInput(
                      onValueChanged: (value) {
                        setState(() {
                          twoDigitInputValue = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black87,
          label: const Text("Submit"),
          onPressed: () {
            if (twoDigitInputValue != null) {
              mqttPublish(twoDigitInputValue!);
            }
          },
          icon: const Icon(Icons.send),
        ),
      ),
    );
  }

  void mqttPublish(int value) {
    // Implement your MQTT publishing logic here
    print('Publishing value to MQTT: $value');
    // Add your MQTT publishing code here
  }
}

class TwoDigitInput extends StatefulWidget {
  final ValueChanged<int>? onValueChanged;

  const TwoDigitInput({Key? key, this.onValueChanged}) : super(key: key);

  @override
  _TwoDigitInputState createState() => _TwoDigitInputState();
}

class _TwoDigitInputState extends State<TwoDigitInput> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      enableSuggestions: false,
      autocorrect: false,
      autofocus: true,
      maxLength: 2,
      onChanged: (value) {
        if (widget.onValueChanged != null) {
          widget.onValueChanged!(int.tryParse(value) ?? 0);
        }
      },
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 36.0, // Adjust the font size as needed
      ),
      cursorColor: Colors.deepOrange,
      decoration: const InputDecoration(
        labelText: 'Enter 2FA',
        labelStyle: TextStyle(color: Colors.black87), // Label text color
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87), // Border color when focused
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87), // Border color when not focused
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.black87), // Lock icon
      ),
    );
  }
}

class PortDropDownWidget extends StatefulWidget {
  final int ports;
  final ValueChanged<int>? onPortSelected;

  const PortDropDownWidget({Key? key, required this.ports, this.onPortSelected})
      : super(key: key);

  @override
  PortDropDownWidgetState createState() => PortDropDownWidgetState();
}

class PortDropDownWidgetState extends State<PortDropDownWidget> {
  int selectedPort = 1;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: selectedPort,
      onChanged: (value) {
        setState(() {
          selectedPort = value!;
        });
        if (widget.onPortSelected != null) {
          widget.onPortSelected!(value!);
        }
      },
      items: List.generate(
        widget.ports,
        (index) => DropdownMenuItem<int>(
          value: index + 1,
          child: Text('Port ${index + 1}'),
        ),
      ),
      hint: const Text('Select a Port'),
    );
  }
}
