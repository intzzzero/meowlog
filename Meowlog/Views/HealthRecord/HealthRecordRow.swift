import SwiftUI
import SwiftData

struct HealthRecordRow: View {
    let record: HealthRecord
    
    var body: some View {
        NavigationLink(destination: HealthRecordDetailView(record: record)) {
            HStack(spacing: 12) {
            // 아이콘
            Text(record.type.icon)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                // 제목
                Text(record.type.rawValue)
                    .font(.headline)
                
                // 세부 정보
                if let details = getRecordDetails() {
                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 날짜와 시간
                HStack {
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let catName = record.cat?.name {
                        Text("• \(catName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 상태 표시
            getSeverityIndicator()
            
            // 사진 있음 표시
            if record.imageData != nil {
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getRecordDetails() -> String? {
        switch record.type {
        case .bowelMovement:
            var details: [String] = []
            
            if let type = record.bowelMovementType {
                details.append(type.rawValue)
            }
            
            if let consistency = record.bowelMovementConsistency {
                details.append(consistency.rawValue)
            }
            
            return details.isEmpty ? nil : details.joined(separator: " • ")
            
        case .urination:
            var details: [String] = []
            
            if let type = record.urineType {
                details.append(type.rawValue)
            }
            
            if let color = record.urineColor {
                details.append(color.rawValue)
            }
            
            if let frequency = record.urineFrequency {
                details.append(frequency.rawValue)
            }
            
            return details.isEmpty ? nil : details.joined(separator: " • ")
            
        case .respiratoryRate:
            if let rate = record.respiratoryRate {
                return "\(rate) 회/분"
            }
            
        case .heartRate:
            if let rate = record.heartRate {
                return "\(rate) bpm"
            }
            
        case .weight:
            if let weight = record.weight {
                return String(format: "%.1f kg", weight)
            }
            
        case .temperature:
            if let temp = record.temperature {
                return String(format: "%.1f°C", temp)
            }
            
        default:
            break
        }
        
        return nil
    }
    
    @ViewBuilder
    private func getSeverityIndicator() -> some View {
        switch record.type {
        case .bowelMovement:
            if let type = record.bowelMovementType {
                if type.severity >= 4 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                } else if type.severity >= 2 {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                } else if type.severity > 0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            
        case .urination:
            let maxSeverity = max(
                record.urineType?.severity ?? 0,
                record.urineColor?.severity ?? 0,
                record.urineFrequency?.severity ?? 0
            )
            
            if maxSeverity >= 4 {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            } else if maxSeverity >= 2 {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            } else if maxSeverity > 0 {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
            
        case .heartRate:
            if let rate = record.heartRate {
                if rate > 200 || rate < 100 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                } else if rate > 180 || rate < 120 {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                }
            }
            
        case .respiratoryRate:
            if let rate = record.respiratoryRate {
                if rate > 40 || rate < 15 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                } else if rate > 35 || rate < 20 {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                }
            }
            
        default:
            EmptyView()
        }
    }
}

#Preview {
    let record = HealthRecord.bowelMovement(
        type: .normal,
        consistency: .normal,
        notes: "정상적인 배변"
    )
    
    NavigationStack {
        List {
            HealthRecordRow(record: record)
        }
        .navigationTitle("건강 기록")
    }
    .modelContainer(for: HealthRecord.self, inMemory: true)
} 