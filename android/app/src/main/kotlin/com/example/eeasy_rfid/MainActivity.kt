package com.example.eeasy_rfid


import android.hardware.usb.UsbManager
import android.os.StrictMode
import android.os.StrictMode.ThreadPolicy
import android.util.Log
import android.widget.Toast
import com.MFG.eeasyMagnati.EcrToPos
import com.MFG.eeasyusbserial.ConfigData
import com.MFG.eeasyusbserial.ConfigLoader
import com.example.rfid_mvp_final.PublicData
import com.rfidread.Enumeration.eReadType
import com.rfidread.Interface.IAsynchronousMessage
import com.rfidread.Models.GPI_Model
import com.rfidread.Models.Tag_Model
import com.rfidread.Protocol.Frame_0001_01
import com.rfidread.RFIDReader
import com.rfidread.Tag6C
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileNotFoundException
import java.util.*


class MainActivity: IAsynchronousMessage, FlutterActivity() {

    private val METHOD_CHANNEL = "com.example.eeasy_rfid/method"
    private val EVENT_CHANNEL = "com.example.eeasy_rfid/event"
    private  val TAGS_EVENT_CHANNEL = "com.example.eeasy_rfid/event/tags"

    var TerminalInterface : EcrToPos = EcrToPos()

    var eventSink: EventChannel.EventSink? = null
    var tagsEventSink: EventChannel.EventSink? = null

    var enabledAntenna : Int = 4

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("fabiola", "CONFIG FLUTTER ENGINE !!!")
        val policy = ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink) {
                Log.d("fabiola", "LISTENED ON ANDROID!!!")
                eventSink = events
                eventSink!!.success("Logs event initialized")
            }
            override fun onCancel(args: Any?) {
                eventSink = null
            }
        })

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, TAGS_EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink) {
                Log.d("fabiola", "LISTENED ON  TAGS ANDROID!!!")
                tagsEventSink = events
                tagsEventSink!!.success("Logs event initialized")
            }
            override fun onCancel(args: Any?) {
                tagsEventSink = null
            }
        })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method.equals("connectTCP")) {
                    result.success(connectTcp())
                }
                else if(call.method.equals("connectUSB")) {
                    result.success(connectUSB(this))
                }
                else if(call.method.equals("readTags")) {
                    result.success(readTags())
                }
                else if (call.method == "vfiInit") {
                    VFIInit(call)
                    val temp: MutableMap<String, String> = HashMap()
                    temp["VFI_RespMess"] = TerminalInterface.vfI_RespMess
                    temp["VFI_RespCode"] = TerminalInterface.VFI_RespCode
                    result.success(temp)
                }
                else if(call.method == "vfiInitAuth") {
                    TerminalInterface.SetContext(this)
                    VFIInitAuth(call)
                    val temp: MutableMap<String, String> = HashMap()
                    temp["VFI_TID"] = TerminalInterface.vfI_TID
                    temp["VFI_RespMess"] = TerminalInterface.vfI_RespMess
                    temp["VFI_RespCode"] = TerminalInterface.VFI_RespCode
                    result.success(temp)
                }
                else if ((call.method == "vfiGetAuth")) {
                    TerminalInterface.SetContext(this)
                    VFIGetAuth(call)
                    val temp: MutableMap<String, String> = HashMap()
                    temp["vfI_RespMess"] = TerminalInterface.vfI_RespMess
                    temp["VFI_MsgType"] = TerminalInterface.VFI_MsgType
                    temp["VFI_ECRRcptNum"] = TerminalInterface.VFI_ECRRcptNum
                    temp["VFI_TransType"] = TerminalInterface.VFI_TransType
                    temp["VFI_Amount"] = TerminalInterface.VFI_Amount
                    temp["VFI_CashAmount"] = TerminalInterface.VFI_CashAmount
                    temp["VFI_CardNumber"] = TerminalInterface.VFI_CardNumber
                    temp["VFI_Expiry"] = TerminalInterface.VFI_Expiry
                    temp["VFI_CHName"] = TerminalInterface.VFI_CHName
                    temp["VFI_MessNum"] = TerminalInterface.VFI_MessNum
                    temp["VFI_CardSchemeName"] = TerminalInterface.VFI_CardSchemeName
                    temp["VFI_TransSource"] = TerminalInterface.VFI_TransSource
                    temp["VFI_AuthMode"] = TerminalInterface.VFI_AuthMode
                    temp["VFI_CHVerification"] = TerminalInterface.VFI_CHVerification
                    temp["VFI_RespCode"] = TerminalInterface.VFI_RespCode
                    temp["VFI_RespMess"] = TerminalInterface.VFI_RespMess
                    temp["VFI_ApprovalCode"] = TerminalInterface.VFI_ApprovalCode
                    temp["VFI_DateTime"] = TerminalInterface.VFI_DateTime
                    temp["VFI_EMVLabel"] = TerminalInterface.VFI_EMVLabel
                    temp["VFI_EMVAID"] = TerminalInterface.VFI_EMVAID
                    temp["VFI_EMVTVR"] = TerminalInterface.VFI_EMVTVR
                    temp["VFI_EMVTSI"] = TerminalInterface.VFI_EMVTSI
                    temp["VFI_EMVAC"] = TerminalInterface.VFI_EMVAC
                    temp["VFI_TIPAmount"] = TerminalInterface.VFI_TIPAmount
                    temp["VFI_PreauthComplAmount"] = TerminalInterface.VFI_PreauthComplAmount
                    temp["VFI_VoidReceiptNum"] = TerminalInterface.VFI_VoidReceiptNum
                    temp["VFI_DBCount"] = TerminalInterface.VFI_DBCount
                    temp["VFI_CRCount"] = TerminalInterface.VFI_CRCount
                    temp["VFI_DBAmount"] = TerminalInterface.VFI_DBAmount
                    temp["VFI_CRAmount"] = TerminalInterface.VFI_CRAmount
                    temp["VFI_AdditionalInfo"] = TerminalInterface.VFI_AdditionalInfo
                    temp["VFI_ReportType"] = TerminalInterface.VFI_ReportType
                    temp["VFI_TID"] = TerminalInterface.VFI_TID
                    temp["VFI_MID"] = TerminalInterface.VFI_MID
                    temp["VFI_Batch"] = TerminalInterface.VFI_Batch
                    temp["VFI_RRN"] = TerminalInterface.VFI_RRN
                    temp["VFI_MAC"] = TerminalInterface.VFI_MAC
                    temp["VFI_OriginalRcptNum"] = TerminalInterface.VFI_OriginalRcptNum
                    temp["VFI_EMVCID"] = TerminalInterface.VFI_EMVCID
                    temp["VFI_ExchRate"] = TerminalInterface.VFI_ExchRate
                    temp["VFI_PYCAmount"] = TerminalInterface.VFI_PYCAmount
                    temp["VFI_MarkUp"] = TerminalInterface.VFI_MarkUp
                    temp["VFI_PYCCurr"] = TerminalInterface.VFI_PYCCurr
                    temp["VFI_PYCCurrName"] = TerminalInterface.VFI_PYCCurrName
                    temp["VFI_OptOut"] = TerminalInterface.VFI_OptOut
                    temp["VFI_PYCTIPAmount"] = TerminalInterface.VFI_PYCTIPAmount
                    temp["VFI_VoucherNO"] = TerminalInterface.VFI_VoucherNO
                    temp["VFI_AdPaySurcharge"] = TerminalInterface.VFI_AdPaySurcharge
                    temp["VFI_PayByMerchantOrderNo"] = TerminalInterface.VFI_PayByMerchantOrderNo
                    temp["VFI_PayByOrderNo"] = TerminalInterface.VFI_PayByOrderNo
                    temp["VFI_QPSVeps"] = TerminalInterface.VFI_QPSVeps
                    temp["VFI_Epp_Tenor"] = TerminalInterface.VFI_Epp_Tenor
                    temp["VFI_Epp_Invoice"] = TerminalInterface.VFI_Epp_Invoice
                    temp["VFI_RedeemedPoints"] = TerminalInterface.VFI_RedeemedPoints
                    temp["VFI_RedeemedAmount"] = TerminalInterface.VFI_RedeemedAmount
                    temp["VFI_CouponMessage"] = TerminalInterface.VFI_CouponMessage
                    temp["VFI_MNAME"] = TerminalInterface.VFI_MNAME
                    temp["VFI_PTID"] = TerminalInterface.VFI_PTID
                    temp["VFI_SN"] = TerminalInterface.VFI_SN
                    temp["VFI_PN"] = TerminalInterface.VFI_PN
                    temp["VFI_APPDATE"] = TerminalInterface.VFI_APPDATE
                    temp["VFI_DLDATE"] = TerminalInterface.VFI_DLDATE
                    temp["VFI_OS"] = TerminalInterface.VFI_OS
                    temp["VFI_UCLVER"] = TerminalInterface.VFI_UCLVER
                    temp["VFI_CTLSVER"] = TerminalInterface.VFI_CTLSVER
                    temp["VFI_APPVER"] = TerminalInterface.VFI_APPVER
                    temp["VFI_Model"] = TerminalInterface.VFI_Model
                    temp["VFI_IP"] = TerminalInterface.VFI_IP
                    temp["VFI_Port"] = TerminalInterface.VFI_Port
                    temp["VFI_SIMIP"] = TerminalInterface.VFI_SIMIP
                    temp["VFI_PrintTime"] = TerminalInterface.VFI_PrintTime
                    temp["VFI_OS1"] = TerminalInterface.VFI_OS1
                    temp["VFI_RAM"] = TerminalInterface.VFI_RAM
                    temp["VFI_FLASH"] = TerminalInterface.VFI_FLASH
                    temp["VFI_SDKVER"] = TerminalInterface.VFI_SDKVER
                    result.success(temp)
                }
                else {
                    result.notImplemented()
                }
            }

    }


    /*override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        println("Hello wolrd")
        Log.d("fabiola", "CONFIG FLUTTER ENGINE !!!")
        Log.d("fabiola", "SETTING EVENT CHANNEL")
        val policy = ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.d("fabiola", "LISTENED ON ANDROID!!!")
                    eventSink = events
                }

                override fun onCancel(args: Any?) {}
            }
        )
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TAGS_EVENT_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.d("fabiola", "LISTENED ON TAGS EVENT!!!")
                    tagsEventSink = events
                }

                override fun onCancel(args: Any?) {}
            }
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method.equals("connectTCP")) {
                    result.success(connectTcp())
                }
                else if(call.method.equals("connectUSB")) {
                    result.success(connectUSB(this))
                }
                else if(call.method.equals("readTags")) {
                    result.success(readTags())
                }
                else {
                    result.notImplemented()
                }
            }

    } */

    private fun connectTcp() : Boolean {
        //if(count == 0) {
            val rt = Rfid_Tcp_Init(this)
            eventSink!!.success(rt)
            //count ++
        //}
       /* else if(count == 1) {
            readTags()
        } */
        return rt
    }



    fun Rfid_Tcp_Init(log: IAsynchronousMessage): Boolean {

        val policy = ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        var rt: Boolean = true
        val connParam = "192.168.1.116:9090"
        runOnUiThread{eventSink!!.success("Rfid_Tcp_Init Start")}
        val cName: String = Frame_0001_01().javaClass.name
        println("NAME : $cName")
        rt = RFIDReader.CreateTcpConn(connParam, log)
        val dicPower = HashMap<Int, Int>()
        dicPower[1] = 30
        dicPower[2] = 30
        dicPower[3] = 30
        dicPower[4] = 30
        RFIDReader._Config.SetANTPowerParam(connParam, dicPower)
        Toast.makeText(applicationContext, rt.toString(), Toast.LENGTH_SHORT).show()
        return rt

    }


    private fun readTags(): Int {
        val connParam = "192.168.1.116:9090"
        return Tag6C.GetEPC(connParam, 4, eReadType.Inventory)
    }

    fun VFIInit(methodCall: MethodCall) {
        try {
            val activity : MainActivity = this
            TerminalInterface.SetContext(activity)
            ConfigData.InitConfigData(this, "", "", "320", "320", "320", "", "", "", "", "","","","","","","", "")
            ConfigLoader.strMacKey = ""
            ConfigLoader.strPTid = methodCall.argument("pt_id")
            ConfigLoader.strSN = methodCall.argument("device_serial_number")
            ConfigLoader.iTrace = (methodCall.argument<String>("trace")!!).toInt()
            ConfigLoader.strPosTraceLog = ""
            ConfigLoader.iPOSAckTimeOut = (methodCall.argument<String>("connection_timeout")!!).toInt()
            ConfigLoader.iTimeOut = (methodCall.argument<String>("transaction_timeout")!!).toInt()
            ConfigLoader.iUploadTimeOut = (methodCall.argument<String>("settlement_timeout")!!).toInt()
            ConfigLoader.sVendorId = (methodCall.argument<String>("vendor_id"))
            ConfigLoader.sProductId = (methodCall.argument<String>("product_id"))
            ConfigLoader.sDriverType = (methodCall.argument<String>("driver_type"))
            ConfigLoader.sPortNum =  (methodCall.argument<String>("port_num"))
            ConfigLoader.sPosBaudRate = (methodCall.argument<String>("baud_rate"))
            ConfigLoader.sDCCFlag = (methodCall.argument<String>("dcc_enable"))
            ConfigLoader.sApacs = (methodCall.argument<String>("apacs_flag"))
            ConfigLoader.sDriverLoc = (methodCall.argument("driver_location"))
            ConfigLoader.SaveConfig()
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        }
    }


    fun VFIInitAuth(methodCall: MethodCall) {
        TerminalInterface.setVFI_TransType(methodCall.argument<String>("transaction_type")!!)
        TerminalInterface.setVFI_Amount(methodCall.argument<String>("transaction_amount")!!)
        TerminalInterface.setVFI_CashAmount(methodCall.argument<String>("cash_amount")!!)
        TerminalInterface.setVFI_TID(methodCall.argument<String>("tid")!!)
        TerminalInterface.setVFI_ECRRcptNum(methodCall.argument<String>("ecrrcpt_num")!!)
        TerminalInterface.setVFI_MessNum(methodCall.argument("mess_num")!!)
        TerminalInterface.setVFI_ReportType(methodCall.argument("report_type")!!)
        TerminalInterface.VFI_InitTransaction()
        /// SetOutputDataValues(bReturn)
    }


    fun VFIGetAuth(methodCall: MethodCall) {
        val activity : MainActivity = this
        TerminalInterface.SetContext(activity)
        TerminalInterface.setVFI_TransType(methodCall.argument<String>("transaction_type")!!)
        TerminalInterface.setVFI_Amount(methodCall.argument<String>("transaction_amount")!!)
        TerminalInterface.setVFI_CashAmount(methodCall.argument<String>("cash_amount")!!)
        TerminalInterface.setVFI_TID(methodCall.argument<String>("tid")!!)
        TerminalInterface.setVFI_ECRRcptNum(methodCall.argument<String>("ecrrcpt_num")!!)
        TerminalInterface.setVFI_MessNum(methodCall.argument<String>("mess_num")!!)
        TerminalInterface.setVFI_RRN(methodCall.argument<String>("rrn")!!)
        TerminalInterface.setVFI_ApprovalCode(methodCall.argument<String>("approval_code")!!)
        TerminalInterface.setVFI_VoucherNO(methodCall.argument<String>("voucher_no")!!)
        TerminalInterface.setVFI_AdPaySurcharge(methodCall.argument<String>("surcharge")!!)
        TerminalInterface.setVFI_PayByMerchantOrderNo(methodCall.argument<String>("payby_merchant_orderno")!!)
        TerminalInterface.setVFI_PayByOrderNo(methodCall.argument<String>("payby_orderno")!!)
        TerminalInterface.VFI_GetAuth()
    }


    private fun connectUSB(log: IAsynchronousMessage) : String {

        val policy = ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)

        object : Thread() {

            override fun run() {
                var rt = false
                var connectParam: String = ""
                val usbNum: Int = getUsbHidDeviceList()
                if (usbNum > 0) {
                    runOnUiThread {eventSink!!.success("RECEIVED USB HID LIST")}
                    connectParam = PublicData.usbHidListStr!![0].trim()
                }
                if (!RFIDReader.GetUsbHIDPermission(applicationContext, connectParam)) {
                    runOnUiThread {eventSink!!.success("PERMISSION FAILURE")}
                }
                else {
                    runOnUiThread {eventSink!!.success("PERMISSION SUCCESS")}
                    //val toast = Toast.makeText(applicationContext, "PERMISSION RECEIVED : $connectParam", Toast.LENGTH_LONG)
                    //toast.setGravity(Gravity.CENTER, 0, 0)
                    //toast.show()
                    rt = RFIDReader.CreateUsbConn(connectParam, log)
                    if(rt) {
                        runOnUiThread{eventSink!!.success("CONNECTION SUCCESS : $connectParam")}
                    } else {
                        runOnUiThread{eventSink!!.success("CONNECTION FAILURE : $connectParam")}
                    }
                }
            }
        }.start()
        return "USB Connect start"
    }

    private fun getUsbHidDeviceList(): Int {
        PublicData.mUsbManager = getSystemService(USB_SERVICE) as UsbManager
        PublicData.sHidList = RFIDReader.GetUSBHIDList(PublicData.mUsbManager)
        PublicData.usbHidListStr = RFIDReader.GetUsbHIDDeviceStrList(PublicData.sHidList)
        return (PublicData.usbHidListStr)!!.size
    }

    override fun WriteDebugMsg(p0: String?) {
        runOnUiThread{eventSink!!.success("-- Write Debug Msg : $p0")}
    }

    override fun WriteLog(p0: String?) {
        runOnUiThread{eventSink!!.success("-- Write Log : $p0")}
    }

    override fun PortConnecting(p0: String?) {
        runOnUiThread{eventSink!!.success("-- Port Connecting : $p0")}
    }

    override fun PortClosing(p0: String?) {
        runOnUiThread{eventSink!!.success("-- Port Closing : $p0")}
    }

    override fun OutPutTags(model: Tag_Model?) {
        if(model != null) {
            runOnUiThread{tagsEventSink!!.success(model._EPC + model._TID)}
        }
        //try {
            /**if(model != null) {
                if (hmList.containsKey(model._EPC + model._TID)) {
                    val tModel: Tag_Model = hmList[model._EPC + model._TID]!!
                    tModel._TotalCount++
                    model._TotalCount = tModel._TotalCount
                    hmList.remove(model._EPC + model._TID)
                    hmList[model._EPC + model._TID] = model
                } else {
                    model._TotalCount = 1
                    hmList[model._EPC + model._TID] = model
                }
            }

            val newHmList = HashMap<String, String>()


            hmList.forEach { (key, value) ->
                newHmList[key] = value.toString()
            }

            runOnUiThread{eventSink!!.success(newHmList)}
            /**if(!tagsList.contains(model!!._EPC + model._TID)) {
                tagsList.add(model._EPC + model._TID)
                if(model != null) {
                    runOnUiThread{eventSink!!.success("-- Output Tags : ${model!!._EPC + model._TID}")}
                }
            else {
                    runOnUiThread{eventSink!!.success("-- Output Tags : Empty")}
            }
            }
              /**  if (hmList.containsKey(model!!._EPC + model._TID)) {
                    val tModel: Tag_Model? = hmList.get(model._EPC + model._TID)
                    tModel!!._TotalCount++
                    model._TotalCount = tModel._TotalCount
                    hmList.remove(model._EPC + model._TID)
                    hmList.put(model._EPC + model._TID, model)
                } else {
                    model._TotalCount = 1
                    hmList.put(model._EPC + model._TID, model)
                } */
            */
            */
        //} catch (ex: Exception) {
        //    Log.d("Debug", "Tags output exceptions:" + ex.message)
        //}
    }

    override fun OutPutTagsOver() {
        runOnUiThread{eventSink!!.success("-- Output tags Over ")}
    }

    override fun GPIControlMsg(p0: GPI_Model?) {
        runOnUiThread{eventSink!!.success("-- GPI Control Msg : $p0")}
    }

    override fun OutPutScanData(p0: ByteArray?) {
        runOnUiThread{eventSink!!.success("-- Output Scan Data : $p0")}
    }


}
