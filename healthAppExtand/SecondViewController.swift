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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTable(notification:)),
                                               name: NSNotification.Name(rawValue: "BodyMassDataAvailable"),
                                               object: nil)
        
        if(!hkAvaiable)
        {
            getAuth()
        }
    }
    
    @objc func updateTable(notification: Notification) {
        print(notification.object!)
        let weightArray = notification.object as! Array<HKQuantitySample>
        
        // Find the HKQuantitySample with the largest quantity.
        let maxSample = weightArray.max { a, b in a.quantity.doubleValue(for: HKUnit.init(from: .pound)) < b.quantity.doubleValue(for: HKUnit.init(from: .pound)) }
        

    }
    
    func fetchWeightData() {
        print("Fetching weight data")
        
        let quantityType : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        //Fetch the last 7 days of bodymass.
        
        let startDate = Date.init(timeIntervalSinceNow: -7*24*60*60)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        
        let sampleQuery = HKSampleQuery.init(sampleType: quantityType.first!,
                                             predicate: predicate,
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: nil,
                                             resultsHandler: { (query, results, error) in
                                                DispatchQueue.main.async(execute: {
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BodyMassDataAvailable"),
                                                                                    object: results as! [HKQuantitySample],
                                                                                    userInfo: nil)
                                                })
        })
        
        self.hkStore .execute(sampleQuery)
        
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
                print("Authorization error: \(String(describing: error?.localizedDescription))")
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

