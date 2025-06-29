import SwiftUI
import SwiftData
import PhotosUI

struct AddUrineRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [Cat]
    
    @State private var selectedCat: Cat?
    @State private var selectedDate = Date()
    @State private var urineType = UrineType.normal
    @State private var urineColor = UrineColor.lightYellow
    @State private var urineFrequency = UrineFrequency.normal
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                CatSelectionSection(cats: cats, selectedCat: $selectedCat)
                
                DateTimeSection(selectedDate: $selectedDate)
                
                UrineStatusSection(
                    urineType: $urineType,
                    urineColor: $urineColor,
                    urineFrequency: $urineFrequency
                )
                
                PhotoSection(
                    selectedPhoto: $selectedPhoto,
                    imageData: $imageData
                )
                
                NotesSection(notes: $notes)
                
                UrineHealthWarningSection(
                    urineType: urineType,
                    urineColor: urineColor,
                    urineFrequency: urineFrequency
                )
            }
            .navigationTitle("소변 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveUrineRecord()
                    }
                    .disabled(selectedCat == nil)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .alert("알림", isPresented: $showingAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveUrineRecord() {
        guard let selectedCat = selectedCat else {
            alertMessage = "고양이를 선택해주세요."
            showingAlert = true
            return
        }
        
        let record = HealthRecord.urination(
            date: selectedDate,
            type: urineType,
            color: urineColor,
            frequency: urineFrequency,
            notes: notes,
            imageData: imageData
        )
        
        record.cat = selectedCat
        selectedCat.healthRecords.append(record)
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Urine-specific Section Components

struct UrineStatusSection: View {
    @Binding var urineType: UrineType
    @Binding var urineColor: UrineColor
    @Binding var urineFrequency: UrineFrequency
    
    var body: some View {
        Section("소변 상태") {
            Picker("배뇨 타입", selection: $urineType) {
                ForEach(UrineType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        if type.severity > 2 {
                            Text("🚨")
                        } else if type.severity > 0 {
                            Text("⚠️")
                        }
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.menu)
            
            Picker("소변 색깔", selection: $urineColor) {
                ForEach(UrineColor.allCases, id: \.self) { color in
                    HStack {
                        Text(color.rawValue)
                        Spacer()
                        if color.severity > 2 {
                            Text("🚨")
                        } else if color.severity > 0 {
                            Text("⚠️")
                        }
                    }
                    .tag(color)
                }
            }
            .pickerStyle(.menu)
            
            Picker("배뇨 빈도", selection: $urineFrequency) {
                ForEach(UrineFrequency.allCases, id: \.self) { frequency in
                    HStack {
                        Text(frequency.rawValue)
                        Spacer()
                        if frequency.severity > 2 {
                            Text("⚠️")
                        }
                    }
                    .tag(frequency)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct UrineHealthWarningSection: View {
    let urineType: UrineType
    let urineColor: UrineColor
    let urineFrequency: UrineFrequency
    
    private var maxSeverity: Int {
        max(urineType.severity, urineColor.severity, urineFrequency.severity)
    }
    
    private var primaryConcern: String {
        if urineType.severity == maxSeverity {
            return urineType.healthConcern
        } else if urineColor.severity == maxSeverity {
            return urineColor.healthConcern
        } else {
            return urineFrequency.healthConcern
        }
    }
    
    var body: some View {
        if maxSeverity > 0 {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if maxSeverity >= 4 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("응급 상황")
                                .font(.headline)
                                .foregroundColor(.red)
                        } else if maxSeverity >= 2 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("주의 필요")
                                .font(.headline)
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("관찰 필요")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    
                    Text(primaryConcern)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if maxSeverity >= 4 {
                        Text("즉시 동물병원에 방문하시기 바랍니다.")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    } else if maxSeverity >= 2 {
                        Text("지속될 경우 동물병원 상담을 권장합니다.")
                            .font(.body)
                            .foregroundColor(.orange)
                    }
                    
                    // 상세 건강 정보
                    VStack(alignment: .leading, spacing: 8) {
                        if urineType.severity > 0 {
                            HStack(alignment: .top) {
                                Text("배뇨 상태:")
                                    .fontWeight(.medium)
                                Text(urineType.healthConcern)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if urineColor.severity > 0 {
                            HStack(alignment: .top) {
                                Text("소변 색깔:")
                                    .fontWeight(.medium)
                                Text(urineColor.healthConcern)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if urineFrequency.severity > 0 {
                            HStack(alignment: .top) {
                                Text("배뇨 빈도:")
                                    .fontWeight(.medium)
                                Text(urineFrequency.healthConcern)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
            } header: {
                Text("건강 상태 분석")
            }
        }
    }
}

#Preview {
    AddUrineRecordView()
        .modelContainer(for: [Cat.self, HealthRecord.self])
} 