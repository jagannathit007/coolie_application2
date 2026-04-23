import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/services/app_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends GetxController {
  io.Socket? _socket;
  final isConnected = false.obs;
  final reconnectAttempts = 0.obs;
  final connectionError = Rxn<String>();

  final onCoolieSuspended = Rxn<Map<String, dynamic>>();
  final onNewBooking = Rxn<Map<String, dynamic>>();
  final onBookingTimeout = Rxn<Map<String, dynamic>>();
  final onWeightConfirmed = Rxn<Map<String, dynamic>>();
  final onWeightDisputed = Rxn<Map<String, dynamic>>();
  final onPassengerCancelled = Rxn<Map<String, dynamic>>();
  final onCancelAllowed = Rxn<Map<String, dynamic>>();
  final onShiftEnded = Rxn<Map<String, dynamic>>();

  final Map<String, Completer> _pendingRequests = {};

  AudioPlayer player = AudioPlayer();

  Future<void> _whistle(String sound) async {
    await player.setSource(AssetSource(sound)).then((value) {
      player.play(AssetSource(sound));
    });
    player.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.completed) {
        await player.pause();
      }
    });
  }

  Future<void> connect(String userId) async {
    try {
      final token = await AppStorage.read("token") ?? "";
      if (token.isEmpty || userId.isEmpty) {
        log("Socket: Cannot connect - missing token or userId");
        return;
      }
      if (_socket != null && _socket!.connected) {
        _socket!.disconnect();
        _socket!.dispose();
      }
      final options = io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().setAuth({'token': token}).setPath('/socket.io/').build();
      _socket = io.io(NetworkConstants.baseUrl, options);
      _setupEventListeners(userId);
      _socket!.connect();
    } catch (e) {
      log("Socket: Connection error - $e");
      connectionError.value = e.toString();
    }
  }

  void _setupEventListeners(String userId) {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      log('Socket: Connected successfully');
      isConnected.value = true;
      reconnectAttempts.value = 0;
      connectionError.value = null;
      final role = AppStorage.read("isMukadam") == true ? "mukadam" : "coolie";
      _socket!.emit('join', {'userId': userId, 'role': role});
    });

    _socket!.onDisconnect((_) {
      log('Socket: Disconnected');
      isConnected.value = false;
    });

    _socket!.onConnectError((error) {
      log('Socket: Connection error - $error');
      connectionError.value = error.toString();
      reconnectAttempts.value++;
      isConnected.value = false;
    });

    _socket!.onReconnect((attempt) {
      log('Socket: Reconnected after $attempt attempts');
      isConnected.value = true;
    });

    _socket!.on('collie:suspended', (data) {
      log('Socket: Coolie Suspended - $data');
      _whistle("slow_spring_board.mp3");
      onCoolieSuspended.value = data;
    });

    _socket!.on('collie:unsuspended', (data) {
      log('Socket: Coolie Suspended - $data');
      _whistle("slow_spring_board.mp3");
      onCoolieSuspended.value = data;
    });

    _socket!.on('worker:shift_ended', (data) {
      log('Socket: Worker Shift_ended - $data');
      _whistle("slow_spring_board.mp3");
      onShiftEnded.value = data;
    });

    _socket!.on('booking:new', (data) {
      log('Socket: New booking received - $data');
      _whistle("slow_spring_board.mp3");
      onNewBooking.value = data;
    });

    _socket!.on('booking:timeout', (data) {
      log('Socket: Booking timeout - $data');
      onBookingTimeout.value = data;
      _resolvePendingRequest('booking:timeout', data);
    });

    _socket!.on('booking:weight_confirmed', (data) {
      log('Socket: Weight confirmed - $data');
      onWeightConfirmed.value = data;
      _resolvePendingRequest('weight_confirmed', data);
    });

    _socket!.on('booking:weight_disputed', (data) {
      log('Socket: Weight disputed - $data');
      onWeightDisputed.value = data;
      _resolvePendingRequest('weight_disputed', data);
    });

    _socket!.on('booking:cancelled_by_passenger', (data) {
      log('Socket: Passenger cancelled - $data');
      _whistle("slow_spring_board.mp3");
      onPassengerCancelled.value = data;
    });

    _socket!.on('booking:cancel_allowed', (data) {
      log('Socket: Cancel allowed - $data');
      onCancelAllowed.value = data;
    });

    _socket!.on('error', (error) {
      log('Socket: Error - $error');
      connectionError.value = error.toString();
    });
  }

  void _resolvePendingRequest(String id, dynamic data) {
    if (_pendingRequests.containsKey(id)) {
      _pendingRequests[id]?.complete(data);
      _pendingRequests.remove(id);
    }
  }

  bool get isSocketConnected => isConnected.value;

  void disconnect() {
    if (_socket != null) {
      if (_socket!.connected) {
        _socket!.disconnect();
      }
      _socket!.dispose();
      _socket = null;
    }
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

SocketService socketService = SocketService();
