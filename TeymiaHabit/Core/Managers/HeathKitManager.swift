import HealthKit
import SwiftUI

@Observable
final class HealthKitManager {
    private let healthStore = HKHealthStore()

    var isAuthorized = false
    var stepCount: Int = 0
    var sleepHours: Double = 0
    var errorMessage: String?

    func requestAuthorization(for types: Set<HKObjectType>) async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            self.isAuthorized = true
        } catch {
            self.errorMessage = "Authorization failed: \(error.localizedDescription)"
            self.isAuthorized = false
        }
    }

    private func fetchQuantity(identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double {
        let quantityType = HKQuantityType(identifier)
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: now.startOfDay, end: now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if error != nil {
                    continuation.resume(returning: 0)
                    return
                }
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            self.healthStore.execute(query)
        }
    }

    private func fetchSleepHours() async -> Double {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let now = Date()
        let startOfYesterday = now.startOfDay.yesterday
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard let sleepSamples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalSeconds = sleepSamples.reduce(0.0) { total, sample in
                    total + sample.endDate.timeIntervalSince(sample.startDate)
                }
                continuation.resume(returning: totalSeconds / 3600)
            }
            self.healthStore.execute(query)
        }
    }

    func fetchSteps() async {
        let steps = await fetchQuantity(identifier: .stepCount, unit: HKUnit.count())
        self.stepCount = Int(steps)
    }

    func fetchSleep() async {
        self.sleepHours = await fetchSleepHours()
    }

    func refreshAll() async {
        async let stepsUpdate: () = fetchSteps()
        async let sleepUpdate: () = fetchSleep()
        _ = await (stepsUpdate, sleepUpdate)
    }
}
