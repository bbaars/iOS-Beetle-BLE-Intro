//
//  ViewController.swift
//  Bluetooth
//
//  Created by Brandon Baars on 8/15/17.
//  Copyright © 2017 Brandon Baars. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var receivedMessageLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    
    // MARK: - Variables
    
    var mainCharacterisitc: CBCharacteristic? = nil
    var mainPeripheral: CBPeripheral? = nil
    var manager: CBCentralManager? = nil
    
    var buttonCount = 0
    
    // bluno service address
    let BLEService = "DFB0"
    
    // writable bluno characterisitc
    let BLECharacteristic = "DFB1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        customizeNavBar()
        
        sendButton.layer.cornerRadius = 7.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "scan-segue" {
            let scanController: ScanTableViewController = segue.destination as! ScanTableViewController
            
            // Set the managers delegate to scan controller so it will call relevant methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanController.parentView = self
        }
    }
    
    
    func customizeNavBar() {
        
        self.navigationItem.rightBarButtonItem = nil
        let rightButton = UIButton()
        
        if mainPeripheral == nil {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.white, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.white, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    @objc func scanButtonPressed() {
        
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
    
    @objc func disconnectButtonPressed() {
        
        // this calls didDisconnectPeripheral, but not may immediately disconnect
        manager?.cancelPeripheralConnection(mainPeripheral!)
        receivedMessageLabel.text = "..."
        buttonCount = 0
        sendButton.setTitle("Connect to BLE", for: .normal)
    }
    
    // MARK: - Protocols for CBPeripherals
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        mainPeripheral = nil
        customizeNavBar()
        print("Disconnected from device: " + peripheral.name!)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        // loop through the peripherals and look at their UUID
        // 0x180A is the device information
        // 0x1800 is the identifer for GAP
        for service in peripheral.services! {
            
            print("Service found with " + service.uuid.uuidString)
            
            // Device information
            if service.uuid.uuidString == "180A" {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            // GAP
            if service.uuid.uuidString == "1800" {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            // BLE Service
            if service.uuid.uuidString == BLEService {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Found \(String(describing: service.characteristics?.count)) characteristics")
        
        // GAP
        if service.uuid.uuidString == "1800" {
            
             // get the name of our peripheral
            for characteristic in service.characteristics! {
                
                // Device name characteristic 0x2A00
                if characteristic.uuid.uuidString == "2A00" {
                    peripheral.readValue(for: characteristic)
                    print("Found device name characteristic")
                }
            }
        }
        
        
        // Device information
        if service.uuid.uuidString == "180A" {
        
            // read the manufacturer name characteristic
            for characteristic in service.characteristics! {
                
                if characteristic.uuid.uuidString == "2A29" {
                    peripheral.readValue(for: characteristic)
                    print("Found device manufacturer characteristic")
                } else if characteristic.uuid.uuidString == "2A23" {
                    peripheral.readValue(for: characteristic)
                    print("Found system ID")
                }
            }
        }
        
        // BLUNO (Beetle BLE)
        if service.uuid.uuidString == BLEService {
            
            for characteristic in service.characteristics! {
                if characteristic.uuid.uuidString == BLECharacteristic {
                    
                    // need to save a reference to this characteristic
                    mainCharacterisitc = characteristic
                    
                    // Set notify to read incoming data async
                    // everytime this characteristic changes, the phone will be notified
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Found Bluno Data characteristic")
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        // device name characteristic
        if characteristic.uuid.uuidString == "2A00" {
            let deviceName = characteristic.value
            print(deviceName ?? "No device name found")
        } else if characteristic.uuid.uuidString == "2A29" {
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No manufacturer name listed")
        } else if characteristic.uuid.uuidString == "2A23" {
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        } else if characteristic.uuid.uuidString == BLECharacteristic {
            
            // data received back from the Beetle BLE
            if characteristic.value != nil {
                if let receivedString = String(data: (characteristic.value!), encoding: String.Encoding.utf8) {
                    receivedMessageLabel.text = receivedString
                } else {
                    print("Could not receive data, try turning on serial in Arduino")
                }
            }
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        if mainPeripheral != nil {
            
            if buttonCount % 2 == 0 {
                sendButton.setTitle("Turn LED On", for: .normal)
            } else {
                sendButton.setTitle("Turn LED Off", for: .normal)
            }
            
            buttonCount += 1
            let helloWorld = "\(buttonCount)"
            let data = helloWorld.data(using: String.Encoding.utf8)
            mainPeripheral?.writeValue(data!, for: mainCharacterisitc!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("Havent discovered device yet")
        }
    }
}

