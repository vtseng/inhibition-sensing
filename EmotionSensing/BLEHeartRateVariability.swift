//
//  ScoscheHRV.swift
//  EmotionSensing
//
//  Created by Vincent on 2/28/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

// String constants
let SENSOR_PLUGIN_BLE_HRV = "plugin_ble_heart_rate_variability"
let KEY_HRV_BATTERY_LEVEL = "battery_level"
let KEY_HRV_BODY_LOCATION = "body_location"
let KEY_HRV_HEART_RATE = "heart_rate"
let KEY_HRV_RR_INTERVAL = "rr_interval"
let KEY_HRV_RSSI = "rssi"
let KEY_HRV_TIMESTAMP = "timestamp"
let KEY_HRV_DEVICE_ID = "device_id" // The device id of the phone.
let KEY_HRV_MANUFACTURER = "manufacturer"
let KEY_HRV_PERIPHERAL_ID = "peripheral_id"

//let PERIPHERAL_ID = "751FF690-947A-6A0A-7248-209FDF502805"
//let PERIPHERAL_ID = "77EA86F3-A874-9262-F3F7-C0A077724D6E" // Small Polar H10
//let PERIPHERAL_ID = "EA4CE0DD-88E5-31FD-57A3-30B8FFB29DEB" // Medium Polar H10

let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let batteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")
let bodyLocationCharacteristicCBUUID = CBUUID(string: "0x2A38")
let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let batteryServiceCBUUID = CBUUID(string: "0x180F")



class BLEHeartRateVariability: AWARESensor {
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    // TODO: Update these properties when connect gets set up
    var batteryLevel: Int = -1
    var bodyLocation: Int = -1
    var rssi: NSNumber = -1.0
    var manufacturer: String = ""
    var peripheralId: String!
    
    static let BATTERY_LEVEL_NOTIFICATION_KEY = "batteryLevel"
    static let RR_INTERVAL_NOTIFICATION_KEY = "rrInterval"

    
    override convenience init() {
        self.init(awareStudy: nil, dbType: AwareDBTypeSQLite)
    }
    
    override convenience init!(awareStudy study: AWAREStudy!) {
        self.init(awareStudy: study, dbType: AwareDBTypeSQLite)
    }
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {

        var storage = AWAREStorage()
        if dbType == AwareDBTypeJSON{
            print("DBTypeJSON is currently not implemented for HRV sensor.")
        }else if dbType == AwareDBTypeCSV{
            print("DBTypeCSV is currently not implemented for HRV sensor.")
        }else{
            storage = SQLiteStorage(study: study, sensorName: SENSOR_PLUGIN_BLE_HRV, entityName: String(describing: EntityBLEHeartRateVariability.self), insertCallBack: { (dataDict, childContext, entity) in
                let entityHRV = NSEntityDescription.insertNewObject(forEntityName: entity!, into: childContext!) as! EntityBLEHeartRateVariability
                
                entityHRV.battery_level = dataDict![KEY_HRV_BATTERY_LEVEL] as? NSNumber
                entityHRV.body_location = dataDict![KEY_HRV_BODY_LOCATION] as? NSNumber
                entityHRV.heart_rate = dataDict![KEY_HRV_HEART_RATE] as? NSNumber
                entityHRV.rr_interval = dataDict![KEY_HRV_RR_INTERVAL] as? NSNumber
                entityHRV.rssi = dataDict![KEY_HRV_RSSI] as? NSNumber
                entityHRV.timestamp = dataDict![KEY_HRV_TIMESTAMP] as? NSNumber
                entityHRV.device_id = dataDict![KEY_HRV_DEVICE_ID] as? String
                entityHRV.manufacturer = dataDict![KEY_HRV_MANUFACTURER] as? String
                entityHRV.peripheral_id = dataDict![KEY_HRV_PERIPHERAL_ID] as? String

            })
        }
    
        super.init(awareStudy: study, sensorName: SENSOR_PLUGIN_BLE_HRV, storage: storage)
    }
    
    

    override func createTable() {
        if self.isDebug(){
            print("\(String(describing: self.getName())) Create Table")
        }
        let queryMaker = TCQMaker()
        queryMaker.addColumn(KEY_HRV_BATTERY_LEVEL, type: TCQTypeReal, default: "-1")
        queryMaker.addColumn(KEY_HRV_BODY_LOCATION, type: TCQTypeReal, default: "-1")
        queryMaker.addColumn(KEY_HRV_HEART_RATE, type: TCQTypeReal, default: "-1")
        queryMaker.addColumn(KEY_HRV_RR_INTERVAL, type: TCQTypeReal, default: "0")
        queryMaker.addColumn(KEY_HRV_RSSI, type: TCQTypeReal, default: "-1")
        queryMaker.addColumn(KEY_HRV_MANUFACTURER, type: TCQTypeText, default: "''")
        queryMaker.addColumn(KEY_HRV_PERIPHERAL_ID, type: TCQTypeText, default: "''")
        
        storage.createDBTableOnServer(with: queryMaker)
    }
    
    
    override func startSensor() -> Bool {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        return super.startSensor()
    }
    
    
    override func stopSensor() -> Bool {
        if centralManager != nil {
            centralManager.stopScan()
            centralManager.cancelPeripheralConnection(heartRatePeripheral)
            centralManager = nil
        }
        return super.stopSensor()
    }    
    
    override func stopSyncDB() {
        super.stopSyncDB()
    }
    
    func disconnectPeripheral() {
        if centralManager != nil {
            centralManager.cancelPeripheralConnection(heartRatePeripheral)
        }
        
        if heartRatePeripheral != nil {
            heartRatePeripheral.delegate = nil
            heartRatePeripheral = nil
        }
        
    }
}

// MARK: Confirm to CBCentralManagerDelegate protocol.
extension BLEHeartRateVariability: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, batteryServiceCBUUID, bodyLocationCharacteristicCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralId = (UserDefaults.standard.object(forKey: KEY_HRV_PERIPHERAL_ID) as! String)
        if (peripheral.identifier.uuidString == peripheralId) {
            centralManager.stopScan()
            heartRatePeripheral = peripheral
            heartRatePeripheral.delegate = self
            centralManager.connect(heartRatePeripheral)
            rssi = RSSI
            manufacturer = peripheral.name ?? ""
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID, batteryServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if heartRatePeripheral != nil {
            heartRatePeripheral.delegate = nil
            heartRatePeripheral = nil
        }
    }
    
}

// MARK: Confirm to CBPeripheralDelegate protocol.
extension BLEHeartRateVariability : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            let rr = rrInterval(from: characteristic)
            onHeartRateReceived(bpm, rr)
        case batteryLevelCharacteristicCBUUID:
            let battery = batteryLevel(from: characteristic)
            onBatteryLevelReceived(battery)
        case bodyLocationCharacteristicCBUUID:
            bodyLocation = sensorLocation(from: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    
    // MARK: Helper functions
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    private func rrInterval(from characteristic: CBCharacteristic) -> Float {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        let len = byteArray.count
        let rrIntervalPresentBit = byteArray[0] >> 4 & 0x01 // indicates presence of rr interval values
        
        if rrIntervalPresentBit == 1 {
            return Float((Int(byteArray[len-1]) << 8) + Int(byteArray[len-2])) / 1024.0 // resolution is 1/1024 seconds
        } else {
            return -1
        }
    }
    
    private func batteryLevel(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        return Int(byteArray[0])
    }
    
    func onBatteryLevelReceived(_ batteryLevel: Int) {
        self.batteryLevel = batteryLevel
        postBatteryLevel(batteryLevel)
    }
    
    func onHeartRateReceived(_ heartRate: Int, _ rr: Float) {
        print("BPM: \(heartRate)")
        print(rr != -1 ? "RR: \(rr)" : "RR: none")
        
        var dict = [String: Any]()
        let unixtime = AWAREUtils.getUnixTimestamp(NSDate() as Date)
        
        dict[KEY_HRV_BATTERY_LEVEL] = batteryLevel
        dict[KEY_HRV_BODY_LOCATION] = bodyLocation
        dict[KEY_HRV_HEART_RATE] = heartRate
        dict[KEY_HRV_RR_INTERVAL] = rr
        dict[KEY_HRV_RSSI] = rssi
        dict[KEY_HRV_TIMESTAMP] = unixtime
        dict[KEY_HRV_DEVICE_ID] = getDeviceId()
        dict[KEY_HRV_MANUFACTURER] = manufacturer
        dict[KEY_HRV_PERIPHERAL_ID] = peripheralId
        
        print(dict)
        
        storage.saveData(with: dict, buffer: false, saveInMainThread: true)
        setLatestData(dict)
        
        if let handler = getEventHandler(){
            handler(self, dict)
        }
        
        // post notifications to update rr interval and battery level labels
        postRRInterval(rr)
    }
    
    func postBatteryLevel(_ batteryLevel: Int) {
        NotificationCenter.default.post(
            name: .ScoscheDidUpdateBatteryLevel,
            object: self,
            userInfo: [BLEHeartRateVariability.BATTERY_LEVEL_NOTIFICATION_KEY : batteryLevel])
    }
    
    func postRRInterval(_ rr: Float) {
        NotificationCenter.default.post(
            name: .ScoscheDidUpdateRRInterval,
            object: self,
            userInfo: [BLEHeartRateVariability.RR_INTERVAL_NOTIFICATION_KEY : rr])
    }
    
    
    func sensorLocation(from sensorLocationCharacteristic: CBCharacteristic) -> Int {
        
        let sensorLocationValue = sensorLocationCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](sensorLocationValue)
        
        // look at just 8 bits
        return Int(buffer[0])

        /*var sensorLocation = ""
         if buffer[0] == 1 {
            sensorLocation = "Chest"
        } else if buffer[0] == 2 {
            sensorLocation = "Wrist"
        } else {
            sensorLocation = "N/A"
        }*/
        
        
    }
}

extension Notification.Name {
    static let ScoscheDidUpdateBatteryLevel = NSNotification.Name("ScoscheDidUpdateBatteryLevel")
    static let ScoscheDidUpdateRRInterval = NSNotification.Name("ScoscheDidUpdateRRInterval")
}
