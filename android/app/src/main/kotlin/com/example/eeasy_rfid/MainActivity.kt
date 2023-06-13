package com.example.eeasy_rfid


import android.hardware.usb.UsbManager
import android.os.StrictMode
import android.os.StrictMode.ThreadPolicy
import android.util.Log
import android.widget.Toast
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
import io.flutter.plugin.common.MethodChannel
import java.util.*


class MainActivity: IAsynchronousMessage, FlutterActivity() {

    private val METHOD_CHANNEL = "com.example.eeasy_rfid/method"
    private val EVENT_CHANNEL = "com.example.eeasy_rfid/event"
    private  val TAGS_EVENT_CHANNEL = "com.example.eeasy_rfid/event/tags"

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
        /***dicPower[1] = 30
        dicPower[2] = 30
        dicPower[3] = 30
        dicPower[4] = 30
        RFIDReader._Config.SetANTPowerParam(connParam, dicPower)*/
        Toast.makeText(applicationContext, rt.toString(), Toast.LENGTH_SHORT).show()
        return rt

    }


    private fun readTags(): Int {
        val connParam = "192.168.1.116:9090"
        return Tag6C.GetEPC(connParam, 1, eReadType.Inventory)
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
