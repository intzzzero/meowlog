import SwiftUI
import SwiftData
import PhotosUI

struct AddBowelMovementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [Cat]
    
    @State private var selectedCat: Cat?
    @State private var selectedDate = Date()
    @State private var bowelMovementType = BowelMovementType.normal

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
                
                BowelMovementStatusSection(
                    bowelMovementType: $bowelMovementType
                )
                
                PhotoSection(
                    selectedPhoto: $selectedPhoto,
                    imageData: $imageData
                )
                
                NotesSection(notes: $notes)
                
                BowelHealthWarningSection(
                    bowelMovementType: bowelMovementType
                )
            }
            .navigationTitle("배변 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveBowelMovement()
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
    
    private func saveBowelMovement() {
        guard let selectedCat = selectedCat else {
            alertMessage = "고양이를 선택해주세요."
            showingAlert = true
            return
        }
        
        let record = HealthRecord.bowelMovement(
            date: selectedDate,
            type: bowelMovementType,
            consistency: .normal, // 기본값 사용
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

// MARK: - Section Components

struct CatSelectionSection: View {
    let cats: [Cat]
    @Binding var selectedCat: Cat?
    
    var body: some View {
        Section("고양이 선택") {
            if cats.count == 1 {
                HStack {
                    if let cat = cats.first {
                        Text(cat.name)
                            .font(.headline)
                    }
                }
                .onAppear {
                    selectedCat = cats.first
                }
            } else {
                Picker("고양이", selection: $selectedCat) {
                    Text("고양이를 선택하세요")
                        .tag(nil as Cat?)
                    ForEach(cats, id: \.id) { cat in
                        Text(cat.name)
                            .tag(cat as Cat?)
                    }
                }
            }
        }
    }
}

struct DateTimeSection: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        Section("기록 시간") {
            DatePicker("날짜 및 시간", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
        }
    }
}

struct BowelMovementStatusSection: View {
    @Binding var bowelMovementType: BowelMovementType
    
    var body: some View {
        Section {
            Picker("배변 타입", selection: $bowelMovementType) {
                ForEach(BowelMovementType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        if type.severity >= 4 {
                            Text("🚨")
                        } else if type.severity >= 2 {
                            Text("⚠️")
                        } else if type.severity > 0 {
                            Text("ℹ️")
                        }
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("배변 상태")
        } footer: {
            Text("배변 상태를 정확히 선택해주세요. 이상 증상이 지속될 경우 수의사와 상담하시기 바랍니다.")
                .font(.caption)
        }
    }
}

struct PhotoSection: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var imageData: Data?
    
    var body: some View {
        Section("사진 (선택사항)") {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                PhotoDisplayView(
                    uiImage: uiImage,
                    onDelete: {
                        self.imageData = nil
                        self.selectedPhoto = nil
                    }
                )
            } else {
                PhotoPickerView(selectedPhoto: $selectedPhoto)
            }
        }
    }
}

struct PhotoDisplayView: View {
    let uiImage: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text("사진이 추가되었습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("다른 사진 선택") {
                    // PhotosPicker가 다시 열림
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            Button("삭제") {
                onDelete()
            }
            .font(.caption)
            .foregroundColor(.red)
        }
    }
}

struct PhotoPickerView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.orange)
                Text("사진 추가하기")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        Section("메모") {
            TextField("추가 메모 (선택사항)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}

struct BowelHealthWarningSection: View {
    let bowelMovementType: BowelMovementType
    
    private var maxSeverity: Int {
        bowelMovementType.severity
    }
    
    var body: some View {
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
                    } else if maxSeverity > 0 {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("관찰 필요")
                            .font(.headline)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("정상 상태")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                
                Text(bowelMovementType.healthConcern)
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
                } else if maxSeverity > 0 {
                    Text("계속 관찰하시고 변화가 있으면 기록해주세요.")
                        .font(.body)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("건강 상태 분석")
        }
    }
}


#Preview {
    AddBowelMovementView()
        .modelContainer(for: [Cat.self, HealthRecord.self], inMemory: true)
} 