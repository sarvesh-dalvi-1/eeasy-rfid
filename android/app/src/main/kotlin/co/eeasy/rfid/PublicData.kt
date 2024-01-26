package co.eeasy.rfid

import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import com.rfidread.usbserial.driver.UsbSerialPort

object PublicData {
    var _IsCommand6Cor6B = "6C" // 6C表示操作6C标签。6B表示操作6B标签。
    var _PingPong_ReadTime = 10000 // 默认是100:3
    var _PingPong_StopTime = 300
    var serialParam = "/dev/ttySAC1:115200" //串口信息
    var tcpParam = "192.168.1.116:9090" //tcp连接信息
    var usbSerialParam = ""
    var bt4Param = ""
    var rS485Param = "1:/dev/ttySAC1:115200" //串口信息
    var usb485Param = ""
    var usbhidParam = ""

    //usb设备列表
    var sPortList: List<UsbSerialPort>? = null
    var usbListStr: List<String>? = null //usb连接参数列表
    var mUsbManager: UsbManager? = null
    var sHidList: List<UsbDevice>? = null
    var usbHidListStr: List<String>? = null //usb连接参数列表


    var connectIndex = 1
}