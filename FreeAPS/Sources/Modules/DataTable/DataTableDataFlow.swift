import Foundation
import SwiftUI

enum DataTable {
    enum Config {}

    enum DataType: String, Equatable {
        case carbs
        case bolus
        case tempBasal
        case tempTarget

        var name: String {
            switch self {
            case .carbs:
                return "Carbs"
            case .bolus:
                return "Bolus"
            case .tempBasal:
                return "Temp Basal"
            case .tempTarget:
                return "Temp Target"
            }
        }
    }

    class Item: Identifiable, Hashable, Equatable {
        let id = UUID()
        let units: GlucoseUnits
        let type: DataType
        let date: Date
        let amount: Decimal
        let secondAmount: Decimal?
        let duration: Decimal?

        private var numberFormater: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter
        }

        init(
            units: GlucoseUnits,
            type: DataType,
            date: Date,
            amount: Decimal,
            secondAmount: Decimal? = nil,
            duration: Decimal? = nil
        ) {
            self.units = units
            self.type = type
            self.date = date
            self.amount = amount
            self.secondAmount = secondAmount
            self.duration = duration
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var amountText: String {
            switch type {
            case .carbs:
                return numberFormater.string(from: amount as NSNumber)! + " g"
            case .bolus:
                return numberFormater.string(from: amount as NSNumber)! + " U"
            case .tempBasal:
                return numberFormater.string(from: amount as NSNumber)! + " U/hr"
            case .tempTarget:
                var converted = amount
                if units == .mmolL {
                    converted = converted.asMmolL
                }

                guard var secondAmount = secondAmount else {
                    return numberFormater.string(from: converted as NSNumber)! + " \(units.rawValue)"
                }
                if units == .mmolL {
                    secondAmount = secondAmount.asMmolL
                }

                return numberFormater.string(from: converted as NSNumber)! + " - " + numberFormater
                    .string(from: secondAmount as NSNumber)! + " \(units.rawValue)"
            }
        }

        var color: Color {
            switch type {
            case .carbs:
                return .loopYellow
            case .bolus:
                return .insulin
            case .tempBasal:
                return Color.insulin.opacity(0.5)
            case .tempTarget:
                return .loopGray
            }
        }

        var durationText: String? {
            guard let duration = duration else {
                return nil
            }
            return numberFormater.string(from: duration as NSNumber)! + " min"
        }
    }
}

protocol DataTableProvider: Provider {
    func pumpHistory() -> [PumpHistoryEvent]
    func tempTargets() -> [TempTarget]
    func carbs() -> [CarbsEntry]
    func deleteCarbs(at date: Date)
}
