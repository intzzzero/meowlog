import SwiftData
import Foundation

@Model
final class Cat {
    var id: UUID
    var name: String
    var birthDate: Date?
    var adoptionDate: Date?
    var breed: String
    var gender: CatGender
    var isNeutered: Bool
    var weight: Double?
    var profileImageData: Data?
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    // 관계형 데이터
    @Relationship(deleteRule: .cascade) var healthRecords: [HealthRecord] = []
    @Relationship(deleteRule: .cascade) var medicationSchedules: [MedicationSchedule] = []
    
    init(
        name: String,
        birthDate: Date? = nil,
        adoptionDate: Date? = nil,
        breed: String = "",
        gender: CatGender = .unknown,
        isNeutered: Bool = false,
        weight: Double? = nil,
        profileImageData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.adoptionDate = adoptionDate
        self.breed = breed
        self.gender = gender
        self.isNeutered = isNeutered
        self.weight = weight
        self.profileImageData = profileImageData
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 계산된 속성
    var age: Int {
        guard let birthDate = birthDate else { return 0 }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var ageInMonths: Int {
        guard let birthDate = birthDate else { return 0 }
        return Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
    }
    
    var daysSinceAdoption: Int {
        guard let adoptionDate = adoptionDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: adoptionDate, to: Date()).day ?? 0
    }
}

enum CatGender: String, CaseIterable, Codable {
    case male = "수컷"
    case female = "암컷"
    case unknown = "알 수 없음"
    
    var icon: String {
        switch self {
        case .male: return "♂"
        case .female: return "♀"
        case .unknown: return "?"
        }
    }
} 