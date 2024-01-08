import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  BannerAdListener get adListener => _adListener;

  final _adListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded: ${ad.adUnitId}.'),
    onAdClosed: (ad) => debugPrint('Ad closed: ${ad.adUnitId}.'),
    onAdFailedToLoad: (ad, error) =>
        debugPrint('Ad failed to load: ${ad.adUnitId}, $error.'),
    onAdOpened: (ad) => debugPrint('Ad opened: ${ad.adUnitId}.'),
    onPaidEvent: (ad, valueMicros, precision, currencyCode) => debugPrint(
        'Ad paid event: ${ad.adUnitId}, $valueMicros, $precision, $currencyCode.'),
    onAdClicked: (ad) => debugPrint('Ad clicked: ${ad.adUnitId}.'),
    onAdImpression: (ad) => debugPrint('Ad impression: ${ad.adUnitId}.'),
    onAdWillDismissScreen: (ad) =>
        debugPrint('Ad will dismiss screen: ${ad.adUnitId}.'),
  );

  static void debugPrint(String msg) {
    if (kDebugMode) print(msg);
  }
}
