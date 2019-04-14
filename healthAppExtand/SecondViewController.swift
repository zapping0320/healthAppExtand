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
    var weightData:[HKQuantitySample] = [HKQuantitySample]()
    private let dateFormatter = DateFormatter()
    
    let hkStore: HKHealthStore = HKHealthStore()
    var hkAvaiable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY/MM/dd hh:mm"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTable(notification:)),
                                               name: NSNotification.Name(rawValue: "BodyMassDataAvailable"),
                                               object: nil)
        
        if(!hkAvaiable)
        {
            getAuth()
        }
        self.fetchWeightData()
    }
    
    @objc func updateTable(notification: Notification) {
        print(notification.object!)
        weightData = notification.object as! Array<HKQuantitySample>
        
        self.tableView.reloadData()

    }
    
    @IBAction func refreshBodyMass(_ sender: Any) {
        self.fetchWeightData()
        
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
    @IBAction func addWeightInfo(_ sender: Any) {
        
        let weightSample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, quantity: HKQuantity(unit: HKUnit(from: "kg"), doubleValue: 80.0), start: Date(), end: Date())
        
        self.hkStore.save(weightSample, withCompletion:
            {
                (success, error) -> Void in
                if success {
                    print("new weight info add success")
                } else {
                    print("new weight info add fail")
                }
        })
        self.fetchWeightData()
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
        return self.weightData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boyMassCell", for: indexPath)
        
        let weightCell = self.weightData[indexPath.row]
        
        cell.textLabel?.text = dateFormatter.string(from: weightCell.startDate) + " " + String(format:"%f", weightCell.quantity.doubleValue(for: HKUnit.init(from: .kilogram)))
        
        return cell
        
    }

}

