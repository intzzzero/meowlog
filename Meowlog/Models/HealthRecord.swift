import SwiftData
import Foundation

@Model
final class HealthRecord {
    var id: UUID
    var type: HealthRecordType
    var date: Date
    var notes: String
    var imageData: Data?
    var createdAt: Date
    
    // 타입별 특화 데이터
    var bowelMovementType: BowelMovementType?
    var bowelMovementConsistency: BowelMovementConsistency?
    var respiratoryRate: Int? // 분당 호흡수
    var heartRate: Int? // 분당 심박수
    var weight: Double? // kg
    var temperature: Double? // 섭씨
    
    // 관계형 데이터
    var cat: Cat?
    
    init(
        type: HealthRecordType,
        date: Date = Date(),
        notes: String = "",
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.date = date
        self.notes = notes
        self.imageData = imageData
        self.createdAt = Date()
    }
    
    // 배변 기록 전용 생성자
    static func bowelMovement(
        date: Date = Date(),
        type: BowelMovementType,
        consistency: BowelMovementConsistency,
        notes: String = "",
        imageData: Data? = nil
    ) -> HealthRecord {
        let record = HealthRecord(type: .bowelMovement, date: date, notes: notes, imageData: imageData)
        record.bowelMovementType = type
        record.bowelMovementConsistency = consistency
        return record
    }
    
    // 호흡수 기록 전용 생성자
    static func respiratoryRate(
        date: Date = Date(),
        rate: Int,
        notes: String = ""
    ) -> HealthRecord {
        let record = HealthRecord(type: .respiratoryRate, date: date, notes: notes)
        record.respiratoryRate = rate
        return record
    }
    
    // 심박수 기록 전용 생성자
    static func heartRate(
        date: Date = Date(),
        rate: Int,
        notes: String = ""
    ) -> HealthRecord {
        let record = HealthRecord(type: .heartRate, date: date, notes: notes)
        record.heartRate = rate
        return record
    }
}

enum HealthRecordType: String, CaseIterable, Codable {
    case bowelMovement = "배변"
    case respiratoryRate = "호흡수"
    case heartRate = "심박수"
    case weight = "체중"
    case temperature = "체온"
    case symptom = "증상"
    case general = "일반"
    
    var icon: String {
        switch self {
        case .bowelMovement: return "💩"
        case .respiratoryRate: return "🫁"
        case .heartRate: return "❤️"
        case .weight: return "⚖️"
        case .temperature: return "🌡️"
        case .symptom: return "🏥"
        case .general: return "📝"
        }
    }
    
    var color: String {
        switch self {
        case .bowelMovement: return "brown"
        case .respiratoryRate: return "blue"
        case .heartRate: return "red"
        case .weight: return "green"
        case .temperature: return "orange"
        case .symptom: return "purple"
        case .general: return "gray"
        }
    }
}

enum BowelMovementType: String, CaseIterable, Codable {
    case normal = "정상"
    case diarrhea = "설사"
    case constipation = "변비"
    case blood = "혈변"
    case mucus = "점액변"
    
    var severity: Int {
        switch self {
        case .normal: return 0
        case .constipation: return 1
        case .mucus: return 2
        case .diarrhea: return 3
        case .blood: return 4
        }
    }
}

enum BowelMovementConsistency: String, CaseIterable, Codable {
    case hard = "딱딱함"
    case normal = "정상"
    case soft = "무름"
    case watery = "물같음"
    
    var bristolScale: Int {
        switch self {
        case .hard: return 1
        case .normal: return 3
        case .soft: return 5
        case .watery: return 7
        }
    }
} 