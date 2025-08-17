import SwiftUI
import SwiftData

struct CatProfileDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let cat: Cat
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 프로필 헤더
                VStack(spacing: 12) {
                    if let imageData = cat.profileImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "cat.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 2) {
                        Text(cat.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Text(cat.gender.icon)
                            Text(cat.gender.rawValue)
                            if cat.isNeutered {
                                Text("(중성화됨)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                // 기본 정보
                InfoSection(title: "기본 정보") {
                    if !cat.breed.isEmpty {
                        ProfileInfoRow(label: "품종", value: cat.breed)
                    }
                    
                    if cat.age > 0 {
                        ProfileInfoRow(label: "나이", value: "\(cat.age)살")
                    }
                    
                    if let weight = cat.weight {
                        ProfileInfoRow(label: "체중", value: String(format: "%.1f kg", weight))
                    }
                }
                
                // 날짜 정보
                InfoSection(title: "날짜 정보") {
                    if let birthDate = cat.birthDate {
                        ProfileInfoRow(label: "생일", value: DateFormatter.dateFormatter.string(from: birthDate))
                    }
                    
                    if let adoptionDate = cat.adoptionDate {
                        ProfileInfoRow(label: "입양일", value: DateFormatter.dateFormatter.string(from: adoptionDate))
                        ProfileInfoRow(label: "함께한 기간", value: "\(cat.daysSinceAdoption)일")
                    }
                }
                
                // 건강 기록 요약
                InfoSection(title: "건강 기록") {
                    ProfileInfoRow(label: "총 기록 수", value: "\(cat.healthRecords.count)개")
                    
                    if let lastRecord = cat.healthRecords.sorted(by: { $0.date > $1.date }).first {
                        ProfileInfoRow(label: "최근 기록", value: DateFormatter.dateFormatter.string(from: lastRecord.date))
                    }
                }
                
                // 메모
                if !cat.notes.isEmpty {
                    InfoSection(title: "메모") {
                        Text(cat.notes)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("프로필")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("편집") {
                    showingEditView = true
                }
                .foregroundColor(.orange)
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditCatView(cat: cat)
        }
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                content
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

#Preview {
    NavigationStack {
        CatProfileDetailView(cat: Cat(name: "미미", breed: "코리안 숏헤어", gender: .female))
    }
    .modelContainer(for: Cat.self, inMemory: true)
}