import SwiftData
import Foundation

@Model
final class MedicationSchedule {
    var id: UUID
    var name: String
    var dosage: String
    var frequency: MedicationFrequency
    var startDate: Date
    var endDate: Date?
    var reminderTime: Date
    var isActive: Bool
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    // 관계형 데이터
    var cat: Cat?
    @Relationship(deleteRule: .cascade) var medicationLogs: [MedicationLog] = []
    
    init(
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        startDate: Date = Date(),
        endDate: Date? = nil,
        reminderTime: Date = Date(),
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.reminderTime = reminderTime
        self.isActive = true
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 다음 투약 예정일 계산
    var nextDoseDate: Date? {
        guard isActive else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        
        // 오늘 이미 투약했는지 확인
        let todayLogs = medicationLogs.filter { calendar.isDate($0.date, inSameDayAs: now) }
        
        switch frequency {
        case .daily:
            if todayLogs.isEmpty {
                return calendar.date(bySettingHour: calendar.component(.hour, from: reminderTime),
                                   minute: calendar.component(.minute, from: reminderTime),
                                   second: 0,
                                   of: now)
            } else {
                return calendar.date(byAdding: .day, value: 1, to: reminderTime)
            }
        case .weekly:
            let weekday = calendar.component(.weekday, from: startDate)
            return calendar.nextDate(after: now, matching: DateComponents(hour: calendar.component(.hour, from: reminderTime), minute: calendar.component(.minute, from: reminderTime), weekday: weekday), matchingPolicy: .nextTime)
        case .monthly:
            let day = calendar.component(.day, from: startDate)
            return calendar.nextDate(after: now, matching: DateComponents(day: day, hour: calendar.component(.hour, from: reminderTime), minute: calendar.component(.minute, from: reminderTime)), matchingPolicy: .nextTime)
        case .asNeeded:
            return nil
        }
    }
    
    // 투약 준수율 계산 (지난 30일 기준)
    var adherenceRate: Double {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let expectedDoses = calculateExpectedDoses(from: thirtyDaysAgo, to: Date())
        let actualDoses = medicationLogs.filter { $0.date >= thirtyDaysAgo }.count
        
        guard expectedDoses > 0 else { return 0.0 }
        return min(Double(actualDoses) / Double(expectedDoses), 1.0)
    }
    
    private func calculateExpectedDoses(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        
        switch frequency {
        case .daily:
            return days
        case .weekly:
            return days / 7
        case .monthly:
            return days / 30
        case .asNeeded:
            return 0
        }
    }
}

@Model
final class MedicationLog {
    var id: UUID
    var date: Date
    var wasGiven: Bool
    var notes: String
    var createdAt: Date
    
    // 관계형 데이터
    var medicationSchedule: MedicationSchedule?
    
    init(date: Date = Date(), wasGiven: Bool = true, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.wasGiven = wasGiven
        self.notes = notes
        self.createdAt = Date()
    }
}

enum MedicationFrequency: String, CaseIterable, Codable {
    case daily = "매일"
    case weekly = "매주"
    case monthly = "매월"
    case asNeeded = "필요시"
    
    var description: String {
        switch self {
        case .daily: return "하루에 한 번"
        case .weekly: return "일주일에 한 번"
        case .monthly: return "한 달에 한 번"
        case .asNeeded: return "필요할 때마다"
        }
    }
    
    var icon: String {
        switch self {
        case .daily: return "🗓️"
        case .weekly: return "📅"
        case .monthly: return "🗓️"
        case .asNeeded: return "��"
        }
    }
} 