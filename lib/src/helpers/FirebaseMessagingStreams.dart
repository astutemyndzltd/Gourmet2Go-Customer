import 'dart:async';

class FirebaseMessagingStreams {
  StreamController<Map<String, dynamic>> onMessageStreamController;
  StreamController<Map<String, dynamic>> onResumeStreamController;
  StreamController<Map<String, dynamic>> onLaunchStreamController;

  FirebaseMessagingStreams() {
    onMessageStreamController = new StreamController.broadcast();
    onResumeStreamController = new StreamController.broadcast();
    onLaunchStreamController = new StreamController.broadcast();
  }

  Stream<Map<String, dynamic>> get onMessageStream => onMessageStreamController.stream;
  Stream<Map<String, dynamic>> get onResumeStream => onResumeStreamController.stream;
  Stream<Map<String, dynamic>> get onLaunchStream => onLaunchStreamController.stream;

}