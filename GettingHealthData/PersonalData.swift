//
//  PersonalData.swift
//  GettingHealthData
//
//  Created by KhoiLe on 10/06/2022.
//

import Foundation
import HealthKit

class PersonalData {
    public static var shared = PersonalData()

    let healthKitStore = HKHealthStore()
}

extension PersonalData {
    func saveData() {
        let now = Date()
        let healthStore = HKHealthStore()
        let configuration = HKWorkoutConfiguration()
        
        configuration.activityType = .running
        configuration.locationType = Int.random(in: 0..<2) == 0 ? .indoor : .outdoor

        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        let stepsCountSample = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let meterUnit = HKQuantity.init(unit: HKUnit.meter(), doubleValue: 1230)
        let sample = HKCumulativeQuantitySample(type: stepsCountSample, quantity: meterUnit, start: now - 3600, end: now)
        builder.add([sample]) { success, error in
            guard success else {
                print("Error: \(String(describing: error))")
                return
            }
            print("Added Sample")
        }
    }

    func getDayOfBirth() -> Date? {
        do {
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            let birthDay = Calendar.current.date(from: birthdayComponents)

            return birthDay
        } catch {
            print("Error in getting day of birth")
            return nil
        }
    }

    func getAge() -> Int? {
        do {
            let birthdayComponents =  try healthKitStore.dateOfBirthComponents()

            // Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                              from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!

            return age
        } catch {
            print("Error in getting age")
            return nil
        }
    }

    func getBloodType() -> String? {
        do {
            let bloodType = try healthKitStore.bloodType()

            switch bloodType.bloodType {
            case .abNegative:
                return "AB-"
            case .abPositive:
                return "AB+"
            case .aNegative:
                return "A-"
            case .aPositive:
                return "A+"
            case .bNegative:
                return "B-"
            case .bPositive:
                return "B+"
            case .oNegative:
                return "O-"
            case .oPositive:
                return "O+"
            default:
                return "Not Set"
            }
        } catch {
            print("Error in getting blood type")
            return nil
        }
    }

    func getBiologicalSex() -> String? {
        do {
            let biologicalSexValue = try healthKitStore.biologicalSex()
            var biologicalSex: String?

            switch biologicalSexValue.biologicalSex.rawValue {
            case 0:
                biologicalSex = nil
            case 1:
                biologicalSex = "Female"
            case 2:
                biologicalSex = "Male"
            case 3:
                biologicalSex = "Other"
            default:
                biologicalSex = nil
            }

            return biologicalSex
        } catch {
            print("Error in getting biological sex")
            return nil
        }
    }

    func getHeight(completion: @escaping (String) -> Void) {
        let heightType = HKSampleType.quantityType(forIdentifier: .height)!
        var height: String! = ""

        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil, resultsHandler: { _, result, _ in

            if let result = result?.first as? HKQuantitySample {
                let quanity = result.quantity
                height = "\(quanity)"
                completion(height)

            } else {
                print("Height error")
                completion("Not found")
            }
        })

        self.healthKitStore.execute(query)
    }

    func getWeight(completion: @escaping (String) -> Void) {
        let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        var weight: String! = ""

        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: nil, resultsHandler: { _, result, _ in

            if let result = result?.first as? HKQuantitySample {
                let quanity = result.quantity
                weight = "\(quanity)"
                completion(weight)

            } else {
                print("Weight error")
                completion("Not found")
            }
        })

        self.healthKitStore.execute(query)
    }

    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getTotalSteps(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getStepFromDate(startDate: Date, completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let now = Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getStepFromDateToDate(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getTodaysFloorsClimbed(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let floorsQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: floorsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getTotalFloorsClimbed(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let floorsQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!

        let query = HKStatisticsQuery(
            quantityType: floorsQuantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getFloorsClimbedFromDate(startDate: Date, completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let floorsQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!

        let now = Date()
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: floorsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getFloorsClimbedFromDateToDate(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let floorsQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: floorsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getStepLength(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getStepLengthMin(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteMin
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getStepLengthMax(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteMax
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getWalkingSpeed(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: walkingSpeedQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getWalkingSpeedMin(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: walkingSpeedQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteMin
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    func getWalkingSpeedMax(completion: @escaping (Double) -> Void) {
        let healthStore = HKHealthStore()
        let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let query = HKStatisticsQuery(
            quantityType: walkingSpeedQuantityType,
            quantitySamplePredicate: nil,
            options: .discreteMax
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }
}

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        // Fix this so real device can run without error
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}
