import 'dart:async';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:m2solar/models/mqtt.dart';
import 'package:m2solar/models/station.dart';

class StationScreen extends StatefulWidget {
  final Station station;
  const StationScreen({Key? key, required this.station}) : super(key: key);

  @override
  StationScreenState createState() => StationScreenState();
}

class StationScreenState extends State<StationScreen> with TickerProviderStateMixin {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  late String topic2fa;
  late String topicChargeState;
  int? authNum = 11;
  int? twoDigitInputValue; // Store the value entered by the user
  int? portNum = 1; // Variable to store the selected dropdown value
  bool locked = true;
  final int _duration = 3600; //seconds
  final CountDownController _controller = CountDownController();
  String? chargeTime;
  bool cancelled = false;

  @override
  void initState() {
    topic2fa = 'esp32/stations/${widget.station.id}/auth';
    topicChargeState = 'esp32/stations/${widget.station.id}/state';
    _setupMqttClient();
    _setupUpdatesListener();
    super.initState();
  }

  Future<void> _setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(topic2fa);
    init2fa();
  }

  void _setupUpdatesListener() {
    mqttClientManager.getMessagesStream()?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final recMessage = c[0].payload as MqttPublishMessage?;
        if (recMessage != null) {
          final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
          final parsedPayload = int.tryParse(payload);
          if (parsedPayload != null) {
            setState(() {
              authNum = parsedPayload;
            });
          }
        }
      }
    });
  }

  void init2fa() {
    mqttClientManager.publishMessage(topic2fa, "refresh");
  }

  @override
  Widget build(BuildContext context) {
    if (locked) {
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
                        child: Text(widget.station.name, style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
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
                const SizedBox(height: 100),
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
                SizedBox(
                  width: 350,
                  child: SlideAction(
                    onSubmit: () {
                      if (twoDigitInputValue != null) {
                        mqttCheck(twoDigitInputValue!);
                      }
                      return Future.value(bool);
                    },
                    innerColor: Colors.black87,
                    outerColor: Colors.deepPurple,
                    sliderButtonIcon: const Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    text: "Slide to charge",
                    sliderRotate: false,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      mqttClientManager.publishMessage(topic2fa, "clear");
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
                        child: Text(widget.station.name, style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('Port $portNum', style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                CircularCountDownTimer(
                  // Countdown duration in Seconds.
                  duration: _duration,
                  initialDuration: 0,
                  controller: _controller,
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 2,
                  ringColor: Colors.grey[300]!,
                  ringGradient: null,
                  fillColor: Colors.deepOrange[300]!,
                  fillGradient: null,
                  backgroundColor: null,
                  backgroundGradient: null,
                  strokeWidth: 20.0,
                  strokeCap: StrokeCap.round,
                  textStyle: const TextStyle(
                    fontSize: 33.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textFormat: CountdownTextFormat.MM_SS,
                  isReverse: true,
                  isReverseAnimation: true,
                  isTimerTextShown: true,
                  autoStart: true,
                  onStart: () {
                    mqttClientManager.publishMessage(topicChargeState, "on");
                    debugPrint('Countdown Started');
                  },
                  onComplete: () {
                    mqttClientManager.publishMessage(topicChargeState, "off");
                    debugPrint('Countdown Ended');
                  },
                  onChange: (String timeStamp) {
                    debugPrint('Countdown Changed $timeStamp');
                  },
                  timeFormatterFunction: (defaultFormatterFunction, duration) {
                    if (duration.inMinutes == 0 || _controller.isPaused) {
                      return "UNPLUG";
                    } else {
                      return Function.apply(defaultFormatterFunction, [duration]);
                    }
                  },
                ),
                SizedBox(
                  width: 350,
                  child: cancelled
                    ? null 
                    : SlideAction(
                    onSubmit: () {
                      _controller.pause();
                      mqttClientManager.publishMessage(topicChargeState, "off");
                      if (_controller.getTime() != null) {
                        setState(() {
                          chargeTime = _controller.getTime()!;
                          cancelled = true;
                          
                        });
                      }
                      return Future.value(_controller.getTime());
                    },
                    innerColor: Colors.black87,
                    outerColor: Colors.deepPurple,
                    sliderButtonIcon: const Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    text: "Slide to cancel",
                    sliderRotate: false,
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    height: 2.0,
                    width: 360.0,
                    color: Colors.black,
                  ),
                ),
                if (chargeTime != null) Text('Total Charging Time: $chargeTime', style: const TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold)),
              ]
            )
          )
        ),
      );
    }
  }

  void mqttCheck(int value) {
    if (authNum != null && value == authNum) {
      setState(() {
        locked = false;        
      });
    } else { init2fa(); showIncorrectAuthSnackBar(); }
  }

  void showIncorrectAuthSnackBar() {
    const SnackBar snackBar = SnackBar(
      content: Text('Authentication Failed'),
      backgroundColor: Colors.orangeAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  @override
  void dispose() async {
    mqttClientManager.publishMessage(topicChargeState, "off");
    mqttClientManager.publishMessage(topic2fa, "clear");
    await Future.delayed(const Duration(seconds: 1));
    mqttClientManager.disconnect();
    super.dispose();
  }
}

class TwoDigitInput extends StatefulWidget {
  final ValueChanged<int>? onValueChanged;

  const TwoDigitInput({Key? key, this.onValueChanged}) : super(key: key);

  @override
  TwoDigitInputState createState() => TwoDigitInputState();
}

class TwoDigitInputState extends State<TwoDigitInput> {
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
          child: Text('Port ${index + 1}', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ),
      ),
      hint: const Text('Select a Port'),
    );
  }
}
