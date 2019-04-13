//
//  SecondViewController.swift
//  healthAppExtand
//
//  Created by 김동현 on 12/04/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import HealthKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    
    let hkStore: HKHealthStore = HKHealthStore()
    var hkAvaiable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!hkAvaiable)
        {
            getAuth()
        }
    }

    func getAuth() {
        let hkWriteData = Set(arrayLiteral:
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!)
        
        let hkReadData = Set(arrayLiteral:
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!)
        
        if !HKHealthStore.isHealthDataAvailable() {
            self.hkAvaiable = false
        }
        
        hkStore.requestAuthorization(toShare: hkWriteData, read: hkReadData, completion: {
            (success, error) -> Void in
            if success {
                print("Authorization complete")
                 self.hkAvaiable = true
                //self.fetchWeightData()
            } else {
                print("Authorization error: \(error?.localizedDescription)")
                 self.hkAvaiable = false
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boyMassCell", for: indexPath)
        
        cell.textLabel?.text = "BodyMass Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
        
    }

}

