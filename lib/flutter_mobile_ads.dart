// ignore_for_file: public_member_api_docs, sort_constructors_first
library flutter_mobile_ads;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutter_mobile_ads.g.dart';

// final mobileAdsProvider = Provider<MobileAdsManager>((ref) {
//   return MobileAdsManager(
//       adsInterval: 30,
//       showAds: true,
//       showAppOpenAd: true,
//       showFirstAd: true,
//       showTestAds: false,
//       showBannerAds: true,
//       bannerAdUnit: '',
//       interstitialAdUnit: '',
//       openAppAdUnitId: '');
// });

@Riverpod(keepAlive: true)
MobileAdsManager flutterMobileAds(
  FlutterMobileAdsRef ref,
//   {
//   required bool showAds,
//   required int adsInterval,
//   required bool showAppOpenAd,
//   required bool showFirstAd,
//   required bool showTestAds,
//   required bool showBannerAds,
//   required String interstitialAdUnit,
//   required String openAppAdUnitId,
//   required String bannerAdUnit,
// }
) {
  return MobileAdsManager(
      adsInterval: 40,
      showAds: true,
      showAppOpenAd: true,
      showFirstAd: true,
      showTestAds: true,
      showBannerAds: true,
      bannerAdUnit: 'bannerAdUnit',
      interstitialAdUnit: 'interstitialAdUnit',
      openAppAdUnitId: 'openAppAdUnitId');
}

@Riverpod(keepAlive: true)
bool canShowAd(CanShowAdRef ref) {
  return ref.read(flutterMobileAdsProvider).canShowAd();
}

// final canShowAdProvider = Provider.autoDispose<bool>((ref) {
//   return ref.read(flutterMobileAdsProvider).canShowAd();
// });

class MobileAdsManager {
  InterstitialAd? interstitialAd;
  late AdManagerBannerAd _banner;
  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  //final RemoteConfig remoteConfig;
  final bool showAds;
  final int adsInterval;
  final bool showAppOpenAd;
  final bool showTestAds;
  final bool showFirstAd;
  final bool showBannerAds;
  final String interstitialAdUnit;
  final String openAppAdUnitId;
  final String bannerAdUnit;

  MobileAdsManager({
    this.interstitialAd,
    required this.showAds,
    required this.adsInterval,
    required this.showAppOpenAd,
    required this.showTestAds,
    required this.showFirstAd,
    required this.showBannerAds,
    required this.interstitialAdUnit,
    required this.openAppAdUnitId,
    required this.bannerAdUnit,
  });

  final int _maxFailedLoadAttempts = 3;
  int numInterstitialLoadAttempts = 0;

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  Future<void> init() async {
    if (showAds) {
      await MobileAds.instance.initialize();
      await createInterstitialAd();
    }
    //MobileAds.instance.initialize();
  }

  DateTime? lastInterstitialAdTime;

  AdManagerBannerAd getBanner() {
    _banner = AdManagerBannerAd(
        //adUnitId: '/6499/example/banner',
        adUnitId: showTestAds ? '/6499/example/banner' : openAppAdUnitId,
        sizes: [
          AdSize.largeBanner,
        ],
        request: const AdManagerAdRequest(),
        listener: AdManagerBannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (Ad ad) => print('Ad loaded.'),
          // Called when an ad request failed.
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // Dispose the ad here to free resources.
            ad.dispose();
            print('Ad failed to load: $error');
          },
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (Ad ad) => print('Ad opened.'),
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (Ad ad) => print('Ad closed.'),
          // Called when an impression occurs on the ad.
          onAdImpression: (Ad ad) => print('Ad impression.'),
        ));
    return _banner;
  }

  bool canShowAd() {
    if (lastInterstitialAdTime == null) {
      return true;
    } else {
      final durationSinceLastAd =
          DateTime.now().difference(lastInterstitialAdTime!);
      return durationSinceLastAd.inSeconds >= adsInterval;
    }
  }

  Future<void> createInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: showTestAds
          ? 'ca-app-pub-3940256099942544/1033173712'
          : interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          numInterstitialLoadAttempts = 0;
          interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          numInterstitialLoadAttempts += 1;
          interstitialAd = null;
          if (numInterstitialLoadAttempts < _maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (interstitialAd == null) {
      return;
    }
    if (canShowAd() && interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) async {
          ad.dispose();
          await createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent:
            (InterstitialAd ad, AdError error) async {
          ad.dispose();
          await createInterstitialAd();
        },
      );
      interstitialAd?.show();
      interstitialAd = null;
      lastInterstitialAdTime = DateTime.now();
    }
  }

  bool get isAppOpenAdAvailable {
    return _appOpenAd != null;
  }

  Future<void> loadAppOpenAd() async {
    AppOpenAd.load(
      adUnitId: showTestAds
          ? 'ca-app-pub-3940256099942544/3419835294'
          : openAppAdUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  Future<void> showAdIfAvailable() async {
    if (!showAds) {
      return;
    }
    if (!isAppOpenAdAvailable) {
      print('Tried to show ad before available.');
      await loadAppOpenAd();
      return;
    }
    if (_isShowingAppOpenAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
    lastInterstitialAdTime = DateTime.now();
  }
}

class AppLifecycleReactor {
  final MobileAdsManager appOpenAdManager;
  final WidgetRef ref;
  AppLifecycleReactor({required this.appOpenAdManager, required this.ref});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    print('New AppState state: $appState');
    bool canShowAds = ref.read(canShowAdProvider);

    if (canShowAds && appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
