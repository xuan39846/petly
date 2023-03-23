import CoreData
import SwiftUI

extension OverrideProfilesConfig {
    final class StateModel: BaseStateModel<Provider> {
        @Published var percentage: Double = 100
        @Published var isEnabled = false
        @Published var _indefinite = true
        @Published var duration: Decimal = 0

        let coredataContext = CoreDataStack.shared.persistentContainer.viewContext

        func savedSettings() {
            coredataContext.performAndWait {
                var overrideArray = [Override]()
                let requestEnabled = Override.fetchRequest() as NSFetchRequest<Override>
                let sortIsEnabled = NSSortDescriptor(key: "date", ascending: false)
                requestEnabled.sortDescriptors = [sortIsEnabled]
                requestEnabled.fetchLimit = 1
                try? overrideArray = coredataContext.fetch(requestEnabled)
                isEnabled = overrideArray.first?.enabled ?? false
                percentage = overrideArray.first?.percentage ?? 100
                _indefinite = overrideArray.first?.indefinite ?? true
                duration = (overrideArray.first?.duration ?? 0) as Decimal

                var newDuration = Double(duration)
                if isEnabled {
                    let duration = Int(truncating: overrideArray.first?.duration ?? 0) * 60
                    let date = overrideArray.first?.date ?? Date()
                    if date.addingTimeInterval(duration.hours.timeInterval) < Date(), !_indefinite {
                        isEnabled = false
                    }
                    newDuration = Date().distance(to: date.addingTimeInterval(duration.minutes.timeInterval)).minutes
                }

                if newDuration < 0 {
                    newDuration = 0
                } else { duration = Decimal(newDuration / 60) }

                if !isEnabled {
                    _indefinite = true
                    percentage = 100
                    duration = 0
                }
            }
        }
    }
}
