//
//  FirstViewController.swift
//  healthAppExtand
//
//  Created by 김동현 on 12/04/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import CoreMotion

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var activityTypeLabel: UILabel!
    @IBOutlet weak var StartButton: UIButton!
    
    @IBAction func walkAction(_ sender: Any) {
    }
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.activityTypeLabel.text = "Walking"
                } else if activity.stationary {
                    self?.activityTypeLabel.text = "Stationary"
                } else if activity.running {
                    self?.activityTypeLabel.text = "Running"
                } else if activity.automotive {
                    self?.activityTypeLabel.text = "Automotive"
                }
            }
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func updateWalkInfo(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
    
    }
    
    
}



