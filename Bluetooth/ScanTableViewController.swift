//
//  ScanTableViewController.swift
//  Bluetooth
//
//  Created by Brandon Baars on 8/15/17.
//  Copyright © 2017 Brandon Baars. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanTableViewController: UITableViewController, CBCentralManagerDelegate {
    
    // Variables
    
    var peripherals: [CBPeripheral] = []
    var manager: CBCentralManager? = nil
    var parentView: MainViewController? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLEDevices()
    }
    
    func scanBLEDevices() {
        
        // Scan for DFRobot BLUNO Devices that match our BLEService variables
        manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        // stop our scan after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.stopScanningForBLEDevices()
        })
    }
    
    func stopScanningForBLEDevices() {
        manager?.stopScan()
    }
    
    // MARK: - Protocols for the CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // if the peripheral isn't already in our array or peripherals
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
        
        tableView.reloadData()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // pass our peripheral reference back to our parent view
        parentView?.mainPeripheral = peripheral
        peripheral.delegate = parentView
        peripheral.discoverServices(nil)
        
        // set the managers delegate view to parent so it can call relevant disconnect methods
        manager?.delegate = parentView
        parentView?.customizeNavBar()
        
        if let controller = self.navigationController {
            controller.popViewController(animated: true)
        }
        
        print("Successfully connected to device: " + peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error.debugDescription)
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath)

        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let peripheral = peripherals[indexPath.row]
        
        // connect when the user selected the device
        manager?.connect(peripheral, options: nil)
    }
}



















