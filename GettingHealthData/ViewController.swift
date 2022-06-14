//
//  ViewController.swift
//  GettingHealthData
//
//  Created by KhoiLe on 10/06/2022.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    @IBOutlet var dobLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var sexLabel: UILabel!
    @IBOutlet var bloodTypeLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var stepsCountLabel: UILabel!
    @IBOutlet var climbedFloorsLabel: UILabel!
    @IBOutlet var stepLengthLabel: UILabel!
    @IBOutlet var walkingSpeedLabel: UILabel!
    
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Check healthKit authorization
        HealthKitSetupAssistant.authorizeHealthKit { [weak self] (result, _) in
            if result {
                print("Auth ok")

                DispatchQueue.main.async {
                    self?.initData()
                }
            } else {
                print("Auth denied")
            }
        }
    }
    
    func initData() {
        // Set date for dob label
        if let dobDate = PersonalData.shared.getDayOfBirth() {
            let dob = dobDate.toString(dateFormat: "dd-MM-yyyy")

            dobLabel.text = "Day of birth: \(String(describing: dob))"
        }

        // Set data for age label
        if let age = PersonalData.shared.getAge() {
            ageLabel.text = "Age: \(age)"
        }

        // Set data for sex label
        if let sex = PersonalData.shared.getBiologicalSex() {
            sexLabel.text = "Sex: \(sex)"
        }

        // Set data for blood type label
        if let bloodType = PersonalData.shared.getBloodType() {
            bloodTypeLabel.text = "Blood type: \(bloodType)"
        }

        // Set data for height label
        PersonalData.shared.getHeight(completion: { [weak self] height in
            DispatchQueue.main.async {
                self?.heightLabel.text = "Height \(height)"
            }
        })

        // Set data for weight label
        PersonalData.shared.getWeight(completion: { [weak self] weight in
            DispatchQueue.main.async {
                self?.weightLabel.text = "Weight \(weight)"
            }
        })
        
        // Set data for step count label
        PersonalData.shared.getTotalSteps(completion: { [weak self] steps in
            DispatchQueue.main.async {
                self?.stepsCountLabel.text = "Steps count: \(steps)"
            }
        })

        // Set data for climbed floors
        PersonalData.shared.getTotalFloorsClimbed(completion: { [weak self] floors in
            DispatchQueue.main.async {
                self?.climbedFloorsLabel.text = "Climbed floors: \(floors)"
            }
        })

        // Set data for step length
        PersonalData.shared.getStepLength(completion: {[weak self] length in
            DispatchQueue.main.async {
                self?.stepLengthLabel.text = "Step length: \(length)"
            }
        })

        // Set data for walking speed
        PersonalData.shared.getWalkingSpeed(completion: { [weak self] speed in
            DispatchQueue.main.async {
                self?.walkingSpeedLabel.text = "Walking speed: \(speed)"
            }
        })
    }
}
