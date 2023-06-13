import 'app_to_app_data.dart';

class UserSettingsModel {

  final int userId;
  final int? timezoneId;
  final String? timezone;
  final String? countryCode;
  final int? gmtOffset;
  final int? dstOffset;
  final int? rawOffset;
  final int? currencyId;
  final String? currencyName;
  final int? decimalPlaces;
  final int? defaultReturnWindow;
  final String? tid;
  final String? mid;
  final int? isPayByLinkAllowed;
  final AppToAppData? appToAppData;
  final int screenType;         /// 1 : Barcode    |    2 : Touchscreen


  const UserSettingsModel({required this.userId, required this.timezoneId, required this.decimalPlaces, required this.timezone, required this.tid, required this.mid, required this.countryCode, required this.currencyId, required this.currencyName, required this.defaultReturnWindow, required this.dstOffset, required this.gmtOffset, required this.rawOffset, required this.appToAppData, required this.isPayByLinkAllowed, required this.screenType});

  static fromMap(Map<String, dynamic> json) {
    return UserSettingsModel(userId: json['user_id'], timezoneId: json['timezone_id'], timezone: json['timezone'], countryCode: json['country_code'], gmtOffset: json['gmt_offset'], dstOffset: json['dst_offset'], rawOffset: json['raw_offset'], currencyId: json['currency_id'], currencyName: json['currency_name'], decimalPlaces: json['decimal_places_value'], defaultReturnWindow: json['default_return_window'], tid: json['tid'], mid: json['mid'], appToAppData: AppToAppData.fromMap(json['machine_data'] ?? {}), isPayByLinkAllowed: json['allow_paybylink'] ?? 0, screenType: json['screen_type']);
  }

  toMap() {
    return {
      "user_id": 37,
      "timezone_id": 1,
      "timezone": "Europe/Andorra",
      "country_code": "AD",
      "gmt_offset": 1,
      "dst_offset": 2,
      "raw_offset": 1,
      "currency_id": 248,
      "currency_name": "UAE Dirham",
      "decimal_place_value": 2,
      "default_return_window": 30,
      "tid": "00055556",
      "mid": "999982000",
      "machine_data" : appToAppData?.toMap(),
      "allow_paybylink" : false,
      "screen_type" : 1
    };
  }


/*String getHeaderMessageBasedOnLanguage(LanguageEnum languageEnum) {
    switch(languageEnum) {
      case LanguageEnum.ENGLISH:
        return headerMessageEn;
      case LanguageEnum.HINDI:
        return headerMessageHi;
      case LanguageEnum.ARABIC:
        return headerMessageAr;
      case LanguageEnum.BANGLA:
        return headerMessageBa;
      case LanguageEnum.URDU:
        return headerMessageUr;
    }
  }

  getFooterMessageBasedOnLanguage(LanguageEnum languageEnum) {
    switch(languageEnum) {
      case LanguageEnum.ENGLISH:
        return footerMessageEn;
      case LanguageEnum.HINDI:
        return footerMessageHi;
      case LanguageEnum.ARABIC:
        return footerMessageAr;
      case LanguageEnum.BANGLA:
        return footerMessageBa;
      case LanguageEnum.URDU:
        return footerMessageUr;
    }
  } */

}