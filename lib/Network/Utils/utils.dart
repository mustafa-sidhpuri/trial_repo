import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fimber/fimber.dart';

Future<bool> checkInternetConnectionAndShowMessage() async {
  ConnectivityResult connectivityResult =
      await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    Fimber.i(">> No Connection Available <<");
// Get.snackbar("", LanguageConst.internetNotAvailable);
    return false;
  } else {
    Fimber.i(">> Connection Available <<");
    return true;
  }
}
