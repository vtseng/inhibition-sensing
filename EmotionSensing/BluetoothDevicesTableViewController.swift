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

class BluetoothDeviceCell: UITableViewCell {
    @IBOutlet weak var deviceNameLabel: UILabel!
}

class BluetoothDevicesTableViewController: UITableViewController {
    
    var peripherals: [CBPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
        
        //TODO: This line of code has to be removed later on.
        UserDefaults.standard.set(PERIPHERAL_ID, forKey: KEY_HRV_PERIPHERAL_ID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: KEY_HRV_PERIPHERAL_ID) != nil {
            performSegue(withIdentifier: "showStudyDashboard", sender: self)
        } else {
            peripherals = searchForPeripherals()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if peripherals.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothDeviceCell") as! BluetoothDeviceCell
        
        //TODO: Assign the device id to the cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: Set the selected device to the UserDefaults
    }
    
    
    //TODO: Implement the function to searcher for aviable devices. Feel free to change the function name and the return type.
    func searchForPeripherals() -> [CBPeripheral] {
        return []
    }
    
}
