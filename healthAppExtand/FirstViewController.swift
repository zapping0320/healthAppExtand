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
    
    private var shouldStartUpdating: Bool = false
    private var startDate: Date? = nil
    
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var activityTypeLabel: UILabel!
    @IBOutlet weak var StartButton: UIButton!
    
    @IBAction func walkAction(_ sender: Any) {
        shouldStartUpdating = !shouldStartUpdating
        shouldStartUpdating ? (onStart()) : (onStop())
    }
    
    private func onStart() {
        StartButton.setTitle("Stop", for: .normal)
        startDate = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    
    private func onStop() {
        StartButton.setTitle("Start", for: .normal)
        startDate = nil
        stopUpdating()
    }
    
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        } else {
            activityTypeLabel.text = "Not available"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            stepCount.text = "Not available"
        }
    }
    
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            activityTypeLabel.text = "Not available"
            stepCount.text = "Not available"
        default:break
        }
    }
    
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
    private func on(error: Error) {
        //handle error
    }
    
    private func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            if let error = error {
                self?.on(error: error)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.stepCount.text = String(describing: pedometerData.numberOfSteps)
                }
            }
        }
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
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.stepCount.text = pedometerData.numberOfSteps.stringValue
            }
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func updateWalkInfo(_ sender: UIButton) {
    }
    
    override func awakeFromNib() {
        print("awakeFromNib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stepCount.text = "0"
        self.activityTypeLabel.text = "-"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let startDate = startDate else { return }
        updateStepsCountLabelUsing(startDate: startDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    
    deinit {
        print("deinit")
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



