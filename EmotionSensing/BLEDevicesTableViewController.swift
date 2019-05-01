//
//  BluetoothDevicesTableViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/17/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

let KEY_DEVICE_NAME = "name"
let KEY_DEVICE_IDENTIFIER = "identifier"
let KEY_DEVICE_RSSI = "rssi"

class BLEDeviceCell: UITableViewCell {
    @IBOutlet weak var deviceNameLabel: UILabel!
}

class BLEDevicesTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var devices = [String: [String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        devices = [String: [String: Any]]()
        if UserDefaults.standard.object(forKey: KEY_HRV_PERIPHERAL_ID) != nil {
            performSegue(withIdentifier: "showStudyDashboard", sender: self)
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if devices.count > 0 {
            tableView.separatorStyle = .singleLine
            return 1
        } else {
            tableView.separatorStyle = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothDeviceCell") as! BLEDeviceCell
        //TODO: Assign the device id to the cell
        let device = Array(devices.values)[indexPath.row]
        cell.deviceNameLabel.text = device[KEY_DEVICE_NAME] as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Set the selected device to the UserDefaults
        centralManager.stopScan()
        let device = Array(devices.values)[indexPath.row]
        let peripheralId = device[KEY_DEVICE_IDENTIFIER]
        UserDefaults.standard.set(peripheralId, forKey: KEY_HRV_PERIPHERAL_ID)
        
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID, batteryServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = peripheral.name {
            if devices[name] == nil {
                devices[name] = [
                    KEY_DEVICE_NAME: name,
                    KEY_DEVICE_IDENTIFIER: peripheral.identifier.uuidString,
                    KEY_DEVICE_RSSI: RSSI
                ]
                
                print("items: \(devices)")
                //TODO: Change reload frequency
                tableView.reloadData()
            }
            
        }
        
    }
    
    
    
}



