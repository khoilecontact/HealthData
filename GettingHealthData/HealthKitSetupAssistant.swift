//
//  HealthKitSetupAssistant.swift
//  GettingHealthData
//
//  Created by KhoiLe on 10/06/2022.
//

import Foundation
import HealthKit

class HealthKitSetupAssistant {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    public class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }

        guard let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let dob = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let floorsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
              let walkingStepLength = HKObjectType.quantityType(forIdentifier: .walkingStepLength),
              let walkingSpeed = HKObjectType.quantityType(forIdentifier: .walkingSpeed)
        else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        let workoutType = HKObjectType.workoutType()

        let healthKitTypesToWrite: Set<HKSampleType> = [stepsCount,
                                                        HKObjectType.workoutType()]
        let healthKitTypesToRead: Set<HKObjectType> = [stepsCount, dob, biologicalSex, bloodType, height, weight, floorsClimbed, walkingStepLength, walkingSpeed, workoutType ]

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}

extension HealthKitSetupAssistant {
    public class func saveSteps(stepsCountValue: Int, date: Date, completion: @escaping (Error?) -> Swift.Void) {
            guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                fatalError("Step Count Type is no longer available in HealthKit")
            }

            let stepsCountUnit: HKUnit = HKUnit.count()
            let stepsCountQuantity = HKQuantity(unit: stepsCountUnit, doubleValue: Double(stepsCountValue))

            let stepsCountSample = HKQuantitySample(type: stepCountType,
                                                    quantity: stepsCountQuantity,
                                                    start: date,
                                                    end: date)

            HKHealthStore().save(stepsCountSample) { (_, error) in
                if let error = error {
                    completion(error)
                    print("Error Saving Steps Count Sample: \(error.localizedDescription)")
                } else {
                    completion(nil)
                    print("Successfully saved Steps Count Sample")
                }
            }
        }
}
