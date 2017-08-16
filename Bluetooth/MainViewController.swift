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
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        
    }
    

    // MARK: - Outlets
    
    @IBOutlet weak var receivedMessageLabel: UILabel!
    
    
    // MARK: - Variables
    
    var mainCharacterisitc: CBCharacteristic? = nil
    var mainPeripheral: CBPeripheral? = nil
    var manager: CBCentralManager? = nil
    
    // bluno service address
    let BLEService = "DFB0"
    
    // writable bluno characterisitc
    let BLECharacteristic = "DFB1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        customizeNavBar()
    }
    
    func customizeNavBar() {
        
        self.navigationItem.rightBarButtonItem = nil
        let rightButton = UIButton()
        
        if mainPeripheral == nil {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    @objc func scanButtonPressed() {
        
        

    }
    
    @objc func disconnectButtonPressed() {
        
        
    }


    // MARK: - IBActions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        
    }
    
}

