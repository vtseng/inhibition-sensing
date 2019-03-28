//
//  ScoscheHRV.swift
//  EmotionSensing
//
//  Created by Vincent on 2/28/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import AWAREFramework

class Scosche: AWARESensor {
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let batteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let batteryServiceCBUUID = CBUUID(string: "0x180F")
    
    override convenience init() {
        self.init(awareStudy: nil, dbType: AwareDBTypeSQLite)
    }
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {

        let SENSOR_NAME = "ScoscheHRV"
        let KEY_SCOSCHE_HRV_DEVICE_ID = "device_id"
        let KEY_SCOSCHE_HRV_TIMESTAMP = "timestamp"
        let KEY_SCOSCHE_HRV_RR_INTERVAL = "rr_interval"

        var storage = AWAREStorage()
        if dbType == AwareDBTypeJSON{
            print("DBTypeJSON is currently not implemented for HRV sensor.")
        }else if dbType == AwareDBTypeCSV{
            print("DBTypeCSV is currently not implemented for HRV sensor.")
        }else{
            storage = SQLiteStorage(study: study, sensorName: SENSOR_NAME, entityName: String(describing: EntityScoscheHRV.self), insertCallBack: { (dataDict, childContext, entity) in
                let entityHRV = NSEntityDescription.insertNewObject(forEntityName: entity!, into: childContext!) as! EntityScoscheHRV
                
                entityHRV.device_id = dataDict![KEY_SCOSCHE_HRV_DEVICE_ID] as? String
                entityHRV.timestamp = dataDict?[KEY_SCOSCHE_HRV_TIMESTAMP] as? NSNumber
                entityHRV.rr_interval = dataDict?[KEY_SCOSCHE_HRV_RR_INTERVAL] as? NSNumber

            })
        }

        super.init(awareStudy: study, sensorName: SENSOR_NAME, storage: storage)
    }
    
    

    override func createTable() {
        if self.isDebug(){
            print("\(String(describing: self.getName())) Create Table")
        }
        let queryMaker = TCQMaker()
        queryMaker.addColumn("timestamp", type: TCQTypeReal, default: "0")
        queryMaker.addColumn("rr_interval", type: TCQTypeReal, default: "0")
        self.storage.createDBTableOnServer(with: queryMaker)
    }
    
    
    override func startSensor() -> Bool {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        return super.startSensor()
    }
    
    
    override func stopSensor() -> Bool {
        if centralManager != nil {
            centralManager.stopScan()
            centralManager = nil
        }
        return super.stopSensor()
    }
    
    
    override func startSyncDB() {
        super.startSyncDB()
    }
    
    
    override func stopSyncDB() {
        super.stopSyncDB()
    }
    
    func onHeartRateReceived(_ heartRate: Int, _ rr: Float) {
        print("BPM: \(heartRate)")
        print(rr != -1 ? "RR: \(rr)" : "RR: none")
    }
}

// MARK: Confirming to CBCentralManagerDelegate protocol.
extension Scosche: CBCentralManagerDelegate {
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
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, batteryServiceCBUUID])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.connect(heartRatePeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID, batteryServiceCBUUID])
    }
}

// MARK: Confirming to CBPeripheralDelegate protocol.
extension Scosche : CBPeripheralDelegate {
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
            print("battery level: \(battery)")
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    // MARK: Helper functions
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        print("byteArray: \(byteArray)")
        
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
        return Int(characteristicData[0])
    }
    
}
