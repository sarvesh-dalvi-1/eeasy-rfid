class RFIDData {

  final String strMacKey;
  final String strPTid;
  final String strSN;
  final String iTrace;
  final String strPosTraceLog;
  final String iPOSAckTimeOut;
  final String iTimeOut;
  final String iUploadTimeOut;
  final String sVendorId;
  final String sProductId;
  final String sDriverType;
  final String sDriverLoc;
  final String sPortNum;
  final String sPosBaudRate;
  final String sDCCFlag;
  final String sApacs;

  const RFIDData({required this.strMacKey, required this.iPOSAckTimeOut, required this.iTrace, required this.iTimeOut, required this.iUploadTimeOut, required this.sApacs, required this.sDCCFlag, required this.sDriverLoc, required this.sDriverType, required this.sPortNum, required this.sPosBaudRate, required this.sProductId, required this.strPosTraceLog, required this.strPTid, required this.strSN, required this.sVendorId});

  static fromMap(Map<String, dynamic> obj) {
    return RFIDData(iPOSAckTimeOut: obj['iPOSAckTimeOut'], iTimeOut: obj['iTimeOut'], iTrace: obj['iTrace'], iUploadTimeOut: obj['iUploadTimeOut'], sApacs: obj['sApacs'], sDCCFlag: obj['sDCCFlag'], sDriverLoc: obj['sDriverLoc'], sDriverType: obj['sDriverType'], sPortNum: obj['sPortNum'], sPosBaudRate: obj['sPosBaudRate'], sProductId: obj['sProductId'], strMacKey: obj['strMacKey'], strPosTraceLog: obj['strPosTraceLog'], strPTid: obj['strPTid'], strSN: obj['strSN'], sVendorId: obj['sVendorId']);
  }

  toMap() {
    return {
      "strMacKey": strMacKey,
      "strPTid": strPTid,
      "strSN": strSN,
      "iTrace": iTrace,
      "strPosTraceLog": strPosTraceLog,
      "iPOSAckTimeOut": iPOSAckTimeOut,
      "iTimeOut": iTimeOut,
      "iUploadTimeOut": iUploadTimeOut,
      "sVendorId": sVendorId,
      "sProductId": sProductId,
      "sDriverType": sDriverType,
      "sDriverLoc": sDriverLoc,
      "sPortNum": sPortNum,
      "sPosBaudRate": sPosBaudRate,
      "sDCCFlag": sDCCFlag,
      "sApacs": sApacs
    };
  }

}