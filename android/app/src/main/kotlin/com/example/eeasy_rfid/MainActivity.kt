package com.example.eeasy_rfid


import android.hardware.usb.UsbManager
import android.os.StrictMode
import android.os.StrictMode.ThreadPolicy
import android.util.Log
import android.view.Gravity
import android.widget.Toast
import com.MFG.eeasyMagnati.EcrToPos
import com.MFG.eeasyUtility.ConfigData
import com.MFG.eeasyUtility.ConfigLoader
import com.MFG.eeasyusbserial.DoorConfigData
import com.MFG.eeasyusbserial.DoorConfigLoader
import com.eeasy.doorlibrary.EcrToArudino
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


open class MainActivity: IAsynchronousMessage, FlutterActivity() {

    private val METHOD_CHANNEL = "com.example.eeasy_rfid/method"
    private val EVENT_CHANNEL = "com.example.eeasy_rfid/event"
    private  val TAGS_EVENT_CHANNEL = "com.example.eeasy_rfid/event/tags"

    var connParam = "192.168.1.117:9090"

    var TerminalInterface : EcrToPos = EcrToPos()

    var eventSink: EventChannel.EventSink? = null
    var tagsEventSink: EventChannel.EventSink? = null

    var enabledAntennas : Int = 0

    var minPower : Int = 0
    var maxPower : Int = 0

    val antennaValueMap : HashMap<Int, Int> = hashMapOf(1 to 1, 2 to 2, 3 to 4, 4 to 8, 5 to 16, 6 to 32, 7 to 64, 8 to 128)

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
                    result.success(call.argument<String>("ip")?.let { connectTcp(it) })
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
                else if(call.method == "vfiDoorInit") {
                    VFIDoorInit(call)
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
                else if(call.method == "setAntenna") {
                    val toast = Toast.makeText(applicationContext, "Set antenna to : ${call.argument<List<Int>>("antennas")!!}", Toast.LENGTH_SHORT)
                    toast.setGravity(Gravity.CENTER, 0, 0)
                    //toast.show()
                    result.success(setAntenna(call.argument<List<Int>>("antennas")!!))
                }
                else if(call.method == "setPower") {
                    result.success(setPower(call.argument<HashMap<Int, Int>>("powerMap")!!))
                }
                else if(call.method == "setInitValues") {
                    val temp: MutableMap<String, Int> = HashMap()
                    UHF_SetReaderProperty()
                    val toast2 = Toast.makeText(applicationContext, "setup res  : ${enabledAntennas}", Toast.LENGTH_SHORT)
                    toast2.setGravity(Gravity.CENTER, 0, 0)
                    //toast2.show()
                    temp["antennaValue"] = enabledAntennas
                    temp["minPower"] = minPower
                    temp["maxPower"] = maxPower
                    result.success(temp)
                }
                else if(call.method == "openDoor") {
                    val activity : MainActivity = this
                    EcrToArudino.SetContext(activity)
                    EcrToArudino.InitDLL()
                    result.success(EcrToArudino.OpenDoor())
                }
                else if(call.method == "closeDoor") {
                    val activity : MainActivity = this
                    EcrToArudino.SetContext(activity)
                    EcrToArudino.InitDLL()
                    result.success(EcrToArudino.CloseDoor())
                }
                else if(call.method == "doorStatus") {
                    val activity : MainActivity = this
                    EcrToArudino.SetContext(activity)
                    EcrToArudino.InitDLL()
                    EcrToArudino.DoorSensorStatus()
                    //val toast2 = Toast.makeText(applicationContext, , Toast.LENGTH_SHORT)
                    //toast2.setGravity(Gravity.CENTER, 0, 0)
                    val toast1 = Toast.makeText(applicationContext, "Door Native state  : ${EcrToArudino.strStatus}", Toast.LENGTH_SHORT)
                    toast1.setGravity(Gravity.CENTER, 0, 0)
                    toast1.show()
                    result.success(EcrToArudino.strStatus == "ALREADY OPENED\n")
                }
                else {
                    result.notImplemented()
                }
            }

    }


    private fun connectTcp(ip : String) : Boolean {
        //if(count == 0) {
            val rt = Rfid_Tcp_Init(this, ip)
            eventSink!!.success(rt)
            //count ++
        //}
       /* else if(count == 1) {
            readTags()
        } */
        return rt
    }



    fun Rfid_Tcp_Init(log: IAsynchronousMessage, ip: String): Boolean {

        if(ip != "") {
            connParam = ip
        }
        val toast1 = Toast.makeText(applicationContext, "IP  : ${connParam}", Toast.LENGTH_SHORT)
        toast1.setGravity(Gravity.CENTER, 0, 0)
        toast1.show()
        val policy = ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        var rt: Boolean = true
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
        return rt

    }


    private fun readTags(): Int {
        return Tag6C.GetEPC(connParam, enabledAntennas, eReadType.Inventory)
    }

    private fun setAntenna(selectedAntennas : List<Int>) : Int {
        enabledAntennas = 0
        for (antennaNo in selectedAntennas) {
            enabledAntennas += antennaValueMap[antennaNo]!!
        }
        val toast = Toast.makeText(applicationContext, "antenna value : ${enabledAntennas}", Toast.LENGTH_SHORT)
        toast.setGravity(Gravity.CENTER, 0, 0)
        //toast.show()
        var x = RFIDReader._Config.Stop(connParam)
        val toast1 = Toast.makeText(applicationContext, "stop res  : ${x}", Toast.LENGTH_SHORT)
        toast1.setGravity(Gravity.CENTER, 0, 0)
       // toast1.show()
        var y = Tag6C.GetEPC(connParam, enabledAntennas, eReadType.Inventory)
        val toast2 = Toast.makeText(applicationContext, "start res  : ${y}", Toast.LENGTH_SHORT)
        toast2.setGravity(Gravity.CENTER, 0, 0)
        //toast2.show()
        return 1
    }


    private fun setPower(powerMap : HashMap<Int, Int>) : Int {
        //val dicPower = HashMap<Int, Int>()
        //dicPower[1] = 30
        //dicPower[2] = 30
        //dicPower[3] = 30
        //dicPower[4] = 30
        //val toast2 = Toast.makeText(applicationContext, "start res  : ${y}", Toast.LENGTH_SHORT)
        //toast2.setGravity(Gravity.CENTER, 0, 0)
        //toast2.show()
        var y = RFIDReader._Config.Stop(connParam)
        val toast1 = Toast.makeText(applicationContext, "setpow stop res  : ${y}", Toast.LENGTH_SHORT)
        toast1.setGravity(Gravity.CENTER, 0, 0)
        //toast1.show()
        val x = RFIDReader._Config.SetANTPowerParam(connParam, powerMap)
        val toast2 = Toast.makeText(applicationContext, "power change res  : ${x}", Toast.LENGTH_SHORT)
        toast2.setGravity(Gravity.CENTER, 0, 0)
       // toast2.show()
        var z = Tag6C.GetEPC(connParam, enabledAntennas, eReadType.Inventory)
        val toast3 = Toast.makeText(applicationContext, "setpow start res  : ${z}", Toast.LENGTH_SHORT)
        toast3.setGravity(Gravity.CENTER, 0, 0)
        //toast3.show()
        return x
    }


    fun VFIDoorInit(methodCall: MethodCall) {
        try {
            val activity : MainActivity = this
            EcrToArudino.SetContext(activity)
            EcrToArudino.InitDLL()
            val toast1 = Toast.makeText(applicationContext, "Door init call native  : ${methodCall.argument<String>("strPTid")}", Toast.LENGTH_SHORT)
            toast1.setGravity(Gravity.CENTER, 0, 0)
            toast1.show()
            DoorConfigData.InitConfigData(this, "", "", "320", "320", "320", "", "", "", "", "","","","","","","", "")
            DoorConfigLoader.strMacKey = methodCall.argument("strMacKey")
            DoorConfigLoader.strPTid = methodCall.argument("strPTid")
            DoorConfigLoader.strSN = methodCall.argument("strSN")
            DoorConfigLoader.iTrace = (methodCall.argument<String>("iTrace")!!).toInt()
            DoorConfigLoader.strPosTraceLog = ""
            DoorConfigLoader.iPOSAckTimeOut = (methodCall.argument<String>("iPOSAckTimeOut")!!).toInt()
            DoorConfigLoader.iTimeOut = (methodCall.argument<String>("iTimeOut")!!).toInt()
            DoorConfigLoader.iUploadTimeOut = (methodCall.argument<String>("iUploadTimeOut")!!).toInt()
            DoorConfigLoader.sVendorId = (methodCall.argument<String>("sVendorId"))
            DoorConfigLoader.sProductId = (methodCall.argument<String>("sProductId"))
            DoorConfigLoader.sDriverType = (methodCall.argument<String>("sDriverType"))
            DoorConfigLoader.sPortNum =  (methodCall.argument<String>("sPortNum"))
            DoorConfigLoader.sPosBaudRate = (methodCall.argument<String>("sPosBaudRate"))
            DoorConfigLoader.sDCCFlag = (methodCall.argument<String>("sDCCFlag"))
            DoorConfigLoader.sApacs = (methodCall.argument<String>("sApacs"))
            DoorConfigLoader.sDriverLoc = (methodCall.argument("sDriverLoc"))
            DoorConfigLoader.SaveConfig()
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        }
    }


    fun VFIInit(methodCall: MethodCall) {
        try {
            Log.d("TAG", methodCall.arguments.toString())
            val activity : MainActivity = this
            TerminalInterface.SetContext(activity)
            ConfigData.InitConfigData(this, "", "", "320", "320", "320", "", "", "", "", "","","","","","","", "",     "" , "" , "")
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

            ConfigLoader.sCommChannel = (methodCall.argument<String>("comm_channel"))
            ConfigLoader.MY_UUID = (methodCall.argument<String>("my_uuid"))
            ConfigLoader.sHostPort = (methodCall.argument<String>("host_port"))
            ConfigLoader.strTid = methodCall.argument<String>("tid")

            ConfigLoader.SaveConfig()
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        }
    }


    fun VFIInitAuth(methodCall: MethodCall) {
        Log.d("TAG", methodCall.arguments.toString())
        TerminalInterface.setVFI_TransType(methodCall.argument<String>("transaction_type")!!)
        TerminalInterface.setVFI_Amount(methodCall.argument<String>("transaction_amount")!!)
        TerminalInterface.setVFI_CashAmount(methodCall.argument<String>("cash_amount")!!)
        TerminalInterface.setVFI_TID(methodCall.argument<String>("tid")!!)
        TerminalInterface.setVFI_ECRRcptNum(methodCall.argument<String>("ecrrcpt_num")!!)
        TerminalInterface.setVFI_MessNum(methodCall.argument("mess_num")!!)
        TerminalInterface.setVFI_ReportType(methodCall.argument("report_type")!!)
        Log.d("TAG", ConfigLoader.sDriverType)
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


    fun UHF_SetReaderProperty() {
        //val toast = Toast.makeText(applicationContext, "Test toast", Toast.LENGTH_SHORT)
        //toast.setGravity(Gravity.CENTER, 0, 0)
        //toast.show()
        val propertyStr = RFIDReader.GetReaderProperty(connParam)
        val propertyArr = propertyStr.split("\\|".toRegex()).toTypedArray()
        val toast1 = Toast.makeText(applicationContext, "Set reader property  : $propertyStr", Toast.LENGTH_SHORT)
        toast1.setGravity(Gravity.CENTER, 0, 0)
        //toast1.show()
        if (propertyArr.size > 3) {
            try {
                minPower = propertyArr[0].toInt()
                maxPower = propertyArr[1].toInt()
                enabledAntennas = propertyArr[2].toInt()
            } catch (ex: Exception) {
                Log.d("Debug", "Get Reader Property failure and conversion failed!")
            }
        } else {
            Log.d("Debug", "Get Reader Property failure")
        }
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
