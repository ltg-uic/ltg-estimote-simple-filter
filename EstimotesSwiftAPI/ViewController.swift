//
//  ViewController.swift
//  EstimotesSwiftAPI
//
//  Created by PauloGF on 6/11/14.
//  Copyright (c) 2014 LTG. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate {
    
        var range : Double = 0.0
        let beaconManager : ESTBeaconManager = ESTBeaconManager()
        var beaconsInRange : Beacon [] = []
        var timeout : NSNumber = 1500
    
        @IBOutlet var numBeacons: UILabel
        @IBOutlet var rangeSlider: UISlider
        @IBOutlet var rangeLabel: UILabel
    
        //action slider affecting range change
        @IBAction func rangeChanged(slider:UISlider) {
            range = Double(slider.value)
            rangeLabel.text =  NSString(format: "%.02f", range)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        range = 0.5
        
        // Do any additional setup after loading the view, typically from a nib.
        beaconManager.delegate = self
        
        var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID:
            NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "LTG")
        
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("ranging")
    }
    
        func beaconManager(manager: ESTBeaconManager, didRangeBeacons: ESTBeacon[], inRegion: ESTBeaconRegion){
            
            //println(didRangeBeacons.count)
            //println(beaconsInRange.count)

    
            //count number of beacons in patch range
            for cBeacon in didRangeBeacons{
    
                let sBeacon : ESTBeacon = cBeacon
                let distFactor = (Double(sBeacon.rssi) + 30.0)/Double(-70.0);
                
                if distFactor <= range && distFactor > 0.0 {
                    
                    if let beacon = beaconForID(sBeacon.minor.stringValue) {
                        beacon.lastSigh = NSDate().timeIntervalSinceReferenceDate*1000
                        beacon.rssi = sBeacon.rssi
                    }
                    else{
                        let bec : Beacon = Beacon()
                        bec.name = "EST"
                        bec.id = sBeacon.minor.stringValue
                        bec.rssi = sBeacon.rssi
                        bec.lastSigh = NSDate().timeIntervalSinceReferenceDate*1000
                        beaconsInRange.append(bec)
                    }
                }
            }
    
            checkBeaconsAge()
            
            numBeacons.text = "\(beaconsInRange.count)"
    
        }
    
        func beaconForID(id:String)->Beacon?{
            var beaconToReturn : Beacon?
            
            for eBeacon in beaconsInRange{
               if eBeacon.id == id{
                beaconToReturn  = eBeacon
                return beaconToReturn
                }
            }
            return beaconToReturn
        }
    
    
        func checkBeaconsAge (){
            for var index = 0; index < beaconsInRange.count; ++index {
                if isBeaconAgedOut(beaconsInRange[index]){
                    beaconsInRange.removeAtIndex(index)
                    --index
                }
            }
        }
    
    
        func isBeaconAgedOut(beacon:Beacon) -> Bool {
            var now : NSNumber = NSDate().timeIntervalSinceReferenceDate*1000
            var then : NSNumber = beacon.lastSigh
            
            if now.intValue - then.intValue >= timeout.intValue {
                return true
            }
            
            return false
            
        }
}

