import 'package:connectivity/connectivity.dart';


Connectivity _connectivity = new Connectivity();

Connectivity getConnectivityInstance() {
  return _connectivity;
}

Future<ConnectivityResult> checkConnectivity () async {
  ConnectivityResult result = await _connectivity.checkConnectivity();
  return result;
}


