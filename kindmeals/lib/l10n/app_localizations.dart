import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get appTitle => translate('appTitle');
  String get welcome => translate('welcome');
  String get makeDifference => translate('makeDifference');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgotPassword');
  String get continueWithGoogle => translate('continueWithGoogle');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get name => translate('name');
  String get aadharId => translate('aadharId');
  String get address => translate('address');
  String get contactNumber => translate('contactNumber');
  String get type => translate('type');
  String get about => translate('about');
  String get orgName => translate('orgName');
  String get postDonation => translate('postDonation');
  String get viewDonations => translate('viewDonations');
  String get volunteers => translate('volunteers');
  String get recentActivity => translate('recentActivity');
  String get feedbackFromNgo => translate('feedbackFromNgo');
  String get popularNgo => translate('popularNgo');
  String get volunteerFeedback => translate('volunteerFeedback');
  String get foodType => translate('foodType');
  String get quantity => translate('quantity');
  String get description => translate('description');
  String get pickupLocation => translate('pickupLocation');
  String get pickupTime => translate('pickupTime');
  String get addFoodImage => translate('addFoodImage');
  String get accept => translate('accept');
  String get viewDetails => translate('viewDetails');
  String get becomeVolunteer => translate('becomeVolunteer');
  String get contact => translate('contact');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}
