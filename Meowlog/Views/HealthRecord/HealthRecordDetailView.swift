import SwiftUI
import SwiftData

struct HealthRecordDetailView: View {
    let record: HealthRecord
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더 영역
                headerSection
                
                // 기본 정보
                basicInfoSection
                
                // 타입별 상세 정보
                detailSection
                
                // 이미지 (있는 경우)
                if let imageData = record.imageData,
                   let uiImage = UIImage(data: imageData) {
                    imageSection(uiImage: uiImage)
                }
                
                // 메모 (있는 경우)
                if !record.notes.isEmpty {
                    notesSection
                }
                
                // 건강 우려사항
                healthConcernSection
            }
            .padding()
        }
        .navigationTitle("건강기록 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("기록 삭제", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) {
                deleteRecord()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 건강기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            Text(record.type.icon)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(record.type.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(record.date.formatted(date: .complete, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let catName = record.cat?.name {
                    Text(catName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // 심각도 표시기
            getSeverityBadge()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("기본 정보")
                .font(.headline)
            
            VStack(spacing: 8) {
                HealthInfoRow(label: "등록일시", value: record.createdAt.formatted(date: .abbreviated, time: .shortened))
                HealthInfoRow(label: "기록일시", value: record.date.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Detail Section
    @ViewBuilder
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상세 정보")
                .font(.headline)
            
            VStack(spacing: 8) {
                switch record.type {
                case .bowelMovement:
                    bowelMovementDetails
                case .urination:
                    urinationDetails
                case .respiratoryRate:
                    respiratoryRateDetails
                case .heartRate:
                    heartRateDetails
                case .weight:
                    weightDetails
                case .temperature:
                    temperatureDetails
                default:
                    Text("세부 정보가 없습니다.")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Type-specific Details
    @ViewBuilder
    private var bowelMovementDetails: some View {
        if let type = record.bowelMovementType {
            HealthInfoRow(label: "배변 유형", value: type.rawValue)
        }
        
        if let consistency = record.bowelMovementConsistency {
            HealthInfoRow(label: "변 상태", value: consistency.rawValue)
            HealthInfoRow(label: "브리스톨 척도", value: "\(consistency.bristolScale)단계")
        }
    }
    
    @ViewBuilder
    private var urinationDetails: some View {
        if let type = record.urineType {
            HealthInfoRow(label: "배뇨 유형", value: type.rawValue)
        }
        
        if let color = record.urineColor {
            HealthInfoRow(label: "소변 색상", value: color.rawValue)
        }
        
        if let frequency = record.urineFrequency {
            HealthInfoRow(label: "배뇨 빈도", value: frequency.rawValue)
        }
    }
    
    @ViewBuilder
    private var respiratoryRateDetails: some View {
        if let rate = record.respiratoryRate {
            HealthInfoRow(label: "호흡수", value: "\(rate) 회/분")
            
            let status = getRespiratoryRateStatus(rate)
            HealthInfoRow(label: "상태", value: status.description, valueColor: status.color)
        }
    }
    
    @ViewBuilder
    private var heartRateDetails: some View {
        if let rate = record.heartRate {
            HealthInfoRow(label: "심박수", value: "\(rate) bpm")
            
            let status = getHeartRateStatus(rate)
            HealthInfoRow(label: "상태", value: status.description, valueColor: status.color)
        }
    }
    
    @ViewBuilder
    private var weightDetails: some View {
        if let weight = record.weight {
            HealthInfoRow(label: "체중", value: String(format: "%.1f kg", weight))
        }
    }
    
    @ViewBuilder
    private var temperatureDetails: some View {
        if let temp = record.temperature {
            HealthInfoRow(label: "체온", value: String(format: "%.1f°C", temp))
            
            let status = getTemperatureStatus(temp)
            HealthInfoRow(label: "상태", value: status.description, valueColor: status.color)
        }
    }
    
    // MARK: - Image Section
    private func imageSection(uiImage: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("첨부 이미지")
                .font(.headline)
            
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메모")
                .font(.headline)
            
            Text(record.notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Health Concern Section
    @ViewBuilder
    private var healthConcernSection: some View {
        if let concern = getHealthConcern() {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("건강 상태 분석")
                        .font(.headline)
                    
                    Spacer()
                    
                    getSeverityBadge()
                }
                
                Text(concern)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(getSeverityColor().opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(getSeverityColor().opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Helper Functions
    private func getHealthConcern() -> String? {
        switch record.type {
        case .bowelMovement:
            return record.bowelMovementType?.healthConcern
        case .urination:
            return record.urineType?.healthConcern
        default:
            return nil
        }
    }
    
    private func getSeverityLevel() -> Int {
        switch record.type {
        case .bowelMovement:
            return record.bowelMovementType?.severity ?? 0
        case .urination:
            return max(
                record.urineType?.severity ?? 0,
                record.urineColor?.severity ?? 0,
                record.urineFrequency?.severity ?? 0
            )
        case .heartRate:
            if let rate = record.heartRate {
                if rate > 200 || rate < 100 { return 4 }
                if rate > 180 || rate < 120 { return 2 }
            }
            return 0
        case .respiratoryRate:
            if let rate = record.respiratoryRate {
                if rate > 40 || rate < 10 { return 4 }
                if rate > 30 || rate < 15 { return 1 }
            }
            return 0
        default:
            return 0
        }
    }
    
    private func getSeverityColor() -> Color {
        let severity = getSeverityLevel()
        if severity >= 4 { return .red }
        if severity >= 2 { return .orange }
        if severity > 0 { return .blue }
        return .green
    }
    
    private func getSeverityBadge() -> some View {
        let severity = getSeverityLevel()
        let color = getSeverityColor()
        
        let text: String
        switch severity {
        case 0: 
            text = "정상"
        case 1: 
            text = "관찰 필요"
        case 2: 
            text = "주의"
        case 3: 
            text = "경고"
        default: 
            text = "위험"
        }
        
        return Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private func getRespiratoryRateStatus(_ rate: Int) -> (description: String, color: Color) {
        if rate > 40 || rate < 10 {
            return ("비정상 - 즉시 병원 방문", .red)
        } else if rate > 30 || rate < 15 {
            return ("관찰 필요", .orange)
        } else {
            return ("정상 범위 - 휴식시 20-30회/분, 수면시 15-25회/분", .green)
        }
    }
    
    private func getHeartRateStatus(_ rate: Int) -> (description: String, color: Color) {
        if rate > 200 || rate < 100 {
            return ("비정상 - 즉시 병원 방문", .red)
        } else if rate > 180 || rate < 120 {
            return ("주의 필요", .orange)
        } else {
            return ("정상 범위", .green)
        }
    }
    
    private func getTemperatureStatus(_ temp: Double) -> (description: String, color: Color) {
        if temp > 39.5 || temp < 37.5 {
            return ("비정상 - 병원 방문 권장", .red)
        } else if temp > 39.0 || temp < 38.0 {
            return ("주의 필요", .orange)
        } else {
            return ("정상 범위", .green)
        }
    }
    
    private func deleteRecord() {
        modelContext.delete(record)
        dismiss()
    }
}

// MARK: - HealthInfoRow Component
struct HealthInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    let record = HealthRecord.bowelMovement(
        type: .bloodFresh,
        consistency: .watery,
        notes: "혈변이 나왔습니다. 병원에 가야겠어요."
    )
    
    NavigationStack {
        HealthRecordDetailView(record: record)
    }
    .modelContainer(for: HealthRecord.self, inMemory: true)
}