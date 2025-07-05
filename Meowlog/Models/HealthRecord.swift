import SwiftData
import Foundation
import SwiftUI

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
    var urineType: UrineType?
    var urineColor: UrineColor?
    var urineFrequency: UrineFrequency?
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
    
    // 소변 기록 전용 생성자
    static func urination(
        date: Date = Date(),
        type: UrineType,
        color: UrineColor,
        frequency: UrineFrequency,
        notes: String = "",
        imageData: Data? = nil
    ) -> HealthRecord {
        let record = HealthRecord(type: .urination, date: date, notes: notes, imageData: imageData)
        record.urineType = type
        record.urineColor = color
        record.urineFrequency = frequency
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
    case urination = "소변"
    case respiratoryRate = "호흡수"
    case heartRate = "심박수"
    case weight = "체중"
    case temperature = "체온"
    case symptom = "증상"
    case general = "일반"
    
    var icon: String {
        switch self {
        case .bowelMovement: return "💩"
        case .urination: return "💧"
        case .respiratoryRate: return "🫁"
        case .heartRate: return "❤️"
        case .weight: return "⚖️"
        case .temperature: return "🌡️"
        case .symptom: return "🏥"
        case .general: return "📝"
        }
    }
    
    var color: Color {
        switch self {
        case .bowelMovement: return .brown
        case .urination: return .cyan
        case .respiratoryRate: return .blue
        case .heartRate: return .red
        case .weight: return .green
        case .temperature: return .orange
        case .symptom: return .purple
        case .general: return .gray
        }
    }
}

// MARK: - 대변 관련 Enum (개선된 분류)

enum BowelMovementType: String, CaseIterable, Codable {
    case normal = "정상 (소시지 모양)"
    case constipation = "변비 (토끼똥 모양)"
    case diarrhea = "설사 (물같음)"
    case bloodFresh = "혈변 (선홍색)"
    case bloodDark = "혈변 (검은색)"
    case mucus = "점액변"
    case accident = "배변 실수"
    case strongOdor = "심한 악취"
    
    var severity: Int {
        switch self {
        case .normal: return 0
        case .accident: return 1
        case .strongOdor: return 1
        case .constipation: return 2
        case .mucus: return 2
        case .diarrhea: return 3
        case .bloodFresh: return 4
        case .bloodDark: return 4
        }
    }
    
    var healthConcern: String {
        switch self {
        case .normal: 
            return "건강한 상태입니다. 소시지 모양으로 매끄럽고 부드러우며, 적당한 수분과 영양분을 섭취하고 있음을 나타냅니다."
        case .constipation: 
            return "토끼똥처럼 딱딱하고 끊어지는 변을 보거나, 변을 보는데 어려움을 겪는 경우입니다. 식이섬유 부족이나 장 운동 저하를 의심할 수 있습니다."
        case .diarrhea: 
            return "물처럼 묽은 변을 보거나, 잦은 배변 횟수를 보이는 경우입니다. 식이 문제나 장 질환을 의심할 수 있습니다."
        case .bloodFresh: 
            return "선홍색 변을 보는 경우입니다. 하부 소화기 출혈을 의심할 수 있으며, 즉시 동물병원 방문이 필요합니다."
        case .bloodDark: 
            return "검은색 변을 보는 경우입니다. 상부 소화기 출혈을 의심할 수 있으며, 즉시 동물병원 방문이 필요합니다."
        case .mucus: 
            return "변에 점액이 섞여 나오는 경우입니다. 장의 염증이나 감염을 의심할 수 있습니다."
        case .accident: 
            return "화장실이 아닌 곳에 대변을 보는 경우입니다. 스트레스, 화장실 환경 문제, 건강 문제 등을 의심해 볼 수 있습니다."
        case .strongOdor: 
            return "심한 악취가 나는 변을 보는 경우입니다. 장내 세균 불균형이나 소화기 질환을 의심할 수 있습니다."
        }
    }
}

enum BowelMovementConsistency: String, CaseIterable, Codable {
    case veryHard = "매우 딱딱함 (토끼똥)"
    case hard = "딱딱함"
    case normal = "정상 (소시지 모양)"
    case soft = "무름"
    case loose = "묽음"
    case watery = "물같음"
    
    var bristolScale: Int {
        switch self {
        case .veryHard: return 1
        case .hard: return 2
        case .normal: return 3
        case .soft: return 4
        case .loose: return 5
        case .watery: return 6
        }
    }
}

// MARK: - 소변 관련 Enum (새로 추가)

enum UrineType: String, CaseIterable, Codable {
    case normal = "정상 배뇨"
    case frequent = "잦은 배뇨 (소량)"
    case difficulty = "배뇨 곤란"
    case inability = "배뇨 불가"
    case excessive = "과도한 배뇨"
    case blood = "혈뇨"
    case accident = "배뇨 실수"
    
    var severity: Int {
        switch self {
        case .normal: return 0
        case .accident: return 1
        case .excessive: return 2
        case .frequent: return 3
        case .difficulty: return 4
        case .blood: return 4
        case .inability: return 5 // 가장 심각
        }
    }
    
    var healthConcern: String {
        switch self {
        case .normal: return "건강한 상태"
        case .frequent: return "방광염 또는 신부전 등 질병 가능성"
        case .difficulty: return "요로 결석 또는 염증 가능성"
        case .inability: return "요로 폐색 등 응급상황 - 즉시 병원 방문"
        case .excessive: return "당뇨병 또는 신장 질환 가능성"
        case .blood: return "방광염 또는 요로 결석 등 비뇨기 질환 의심"
        case .accident: return "스트레스, 환경 문제 또는 건강 문제 가능성"
        }
    }
}

enum UrineColor: String, CaseIterable, Codable {
    case clear = "맑고 투명"
    case lightYellow = "연한 노란색"
    case darkYellow = "진한 노란색"
    case brown = "갈색"
    case red = "붉은색"
    case pink = "분홍색"
    
    var severity: Int {
        switch self {
        case .clear, .lightYellow: return 0
        case .darkYellow: return 1
        case .brown: return 3
        case .pink: return 3
        case .red: return 4
        }
    }
    
    var healthConcern: String {
        switch self {
        case .clear, .lightYellow: return "정상"
        case .darkYellow: return "탈수 또는 신장 기능 저하 가능성"
        case .brown: return "간 질환 또는 심한 탈수 가능성"
        case .red: return "혈뇨 - 비뇨기 질환 의심"
        case .pink: return "경미한 혈뇨 - 관찰 필요"
        }
    }
}

enum UrineFrequency: String, CaseIterable, Codable {
    case normal = "정상 (하루 2-3회)"
    case decreased = "감소 (하루 1회 이하)"
    case increased = "증가 (하루 4-6회)"
    case frequent = "빈뇨 (하루 7회 이상)"
    
    var severity: Int {
        switch self {
        case .normal: return 0
        case .decreased: return 2
        case .increased: return 1
        case .frequent: return 3
        }
    }
    
    var healthConcern: String {
        switch self {
        case .normal: return "정상적인 배뇨 빈도"
        case .decreased: return "배뇨 횟수 감소 - 탈수 또는 신장 문제 가능성"
        case .increased: return "배뇨 횟수 증가 - 수분 섭취 증가 또는 스트레스 가능성"
        case .frequent: return "빈뇨 - 방광염, 신부전 등 질병 가능성"
        }
    }
} 