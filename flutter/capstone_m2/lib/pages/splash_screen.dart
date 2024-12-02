import 'package:flutter/material.dart';
import 'package:m2solar/models/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "esp32/test";

  @override
  void initState() {
    setupMqttClient();
    // setupUpdatesListener();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter % 2 == 0) {
        mqttClientManager.publishMessage(
            pubTopic, "on");
      }
      else {
        mqttClientManager.publishMessage(
            pubTopic, "off");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
  }
  
  void setupUpdatesListener() {
    mqttClientManager.getMessagesStream()?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final recMess = c[0].payload as MqttPublishMessage?;
        if (recMess != null) {
          final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
        }
      }
    });
  }


  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}
