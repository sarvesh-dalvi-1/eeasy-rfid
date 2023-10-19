class AppToAppData {

  final String connectionTimeout;
  final String transactionTimeout;
  final String settlementTimeout;
  final String trace;
  final String vendorID;
  final String productID;
  final String driverType;
  final String driverLoc;
  final String tid;
  final String mid;
  final String ptID;
  final String serialNumber;
  final String portNum;
  final String baudRate;
  final String dcc;
  final String apacsFlag;
  final String sLicense;
  final String posTraceLog;
  final String ecrReceiptNum;
  final String messageNum;
  final String reportType;
  final String rrn;
  final String approvalCode;
  final String voucherNumber;
  final String surcharge;
  final String payByMerchantOrderNumber;
  final String payByOrderNumber;
  final String commChannel;
  final String myUuid;
  final String hostPort;

  AppToAppData({required this.connectionTimeout, required this.transactionTimeout, required this.settlementTimeout, required this.trace, required this.vendorID, required this.productID, required this.driverType, required this.driverLoc, required this.tid, required this.mid, required this.ptID, required this.serialNumber, required this.portNum, required this.baudRate, required this.dcc, required this.apacsFlag, required this.sLicense, required this.posTraceLog, required this.ecrReceiptNum, required this.messageNum, required this.reportType, required this.rrn, required this.approvalCode, required this.voucherNumber, required this.surcharge, required this.payByMerchantOrderNumber, required this.payByOrderNumber, required this.commChannel, required this.hostPort, required this.myUuid});

  static AppToAppData fromMap(Map<String, dynamic> obj) {
    return AppToAppData(connectionTimeout: obj['connection_timeout'] ?? '320', transactionTimeout: obj['transaction_timeout'] ?? '320', settlementTimeout: obj['settlement_timeout'] ?? '320', trace: obj['trace'] ?? '', vendorID: obj['vendor_id'] ?? '', productID: obj['product_id'] ?? '', driverType: obj['driver_type'] ?? '', driverLoc: obj['driver_location'] ?? '', tid: obj['tid'] ?? '', mid: obj['mid'] ?? '', ptID: obj['pt_id'] ?? '', serialNumber: obj['device_serial_number'] ?? '', portNum: obj['port_num'] ?? '', baudRate: obj['baud_rate'] ?? '', dcc: obj['dcc_enable'] ?? '', apacsFlag: obj['apacs_flag'] ?? '', sLicense: obj['s_license'] ?? '', posTraceLog: obj['pos_trace_log'] ?? '', ecrReceiptNum: obj['ecrrcpt_num'] ?? '', messageNum: obj['mess_num'] ?? '', reportType: obj['report_type'] ?? '', rrn: obj['rrn'] ?? '', approvalCode: obj['approval_code'] ?? '', voucherNumber: obj['voucher_nun'] ?? '', surcharge: obj['surcharge'] ?? '', payByMerchantOrderNumber: obj['payby_merchant_orderno'] ?? '', payByOrderNumber: obj['payby_orderno'] ?? '', commChannel: obj['comm_channel'], hostPort: obj['host_port'], myUuid: obj['my_uuid']);
  }

  toMap() {
    return {
      'connection_timeout' : connectionTimeout,
      'transaction_timeout' : transactionTimeout,
      'settlement_timeout' : settlementTimeout,
      'trace' : trace,
      'vendor_id' : vendorID,
      'product_id' : productID,
      'driver_type' : driverType,
      'driver_location' : driverLoc,
      'tid' : tid,
      'mid' : mid,
      'pt_id' : ptID,
      'device_serial_number' : serialNumber,
      'port_num' : portNum,
      'baud_rate' : baudRate,
      'dcc_enable' : dcc,
      'apacs_flag' : apacsFlag,
      's_license' : sLicense,
      'pos_trace_log' : posTraceLog,
      'ecrrcpt_num' : ecrReceiptNum,
      'mess_num' : messageNum,
      'report_type' : reportType,
      'rrn' : rrn,
      'approval_code' : approvalCode,
      'voucher_no' : voucherNumber,
      'surcharge' : surcharge,
      'payby_merchant_orderno' : payByMerchantOrderNumber,
      'payby_orderno' : payByOrderNumber,
      'comm_channel' : commChannel,
      'my_uuid' : myUuid,
      'host_port' : hostPort
    };
  }

}