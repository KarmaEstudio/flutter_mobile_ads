// GENERATED CODE - DO NOT MODIFY BY HAND

part of flutter_mobile_ads;

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String _$flutterMobileAdsHash() => r'8ced266acb7e93b7e8e16d9d9b3f2a55c5725236';

/// See also [flutterMobileAds].
final flutterMobileAdsProvider = Provider<MobileAdsManager>(
  flutterMobileAds,
  name: r'flutterMobileAdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flutterMobileAdsHash,
);
typedef FlutterMobileAdsRef = ProviderRef<MobileAdsManager>;
String _$canShowAdHash() => r'598193fcd6e1a85e0ea0f329a3b3adea710c52ac';

/// See also [canShowAd].
final canShowAdProvider = Provider<bool>(
  canShowAd,
  name: r'canShowAdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$canShowAdHash,
);
typedef CanShowAdRef = ProviderRef<bool>;
