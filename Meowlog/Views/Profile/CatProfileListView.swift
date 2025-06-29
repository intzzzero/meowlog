import SwiftUI
import SwiftData

struct CatProfileListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [Cat]
    @State private var showingAddCat = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cats) { cat in
                    HStack {
                        // 프로필 사진
                        if let imageData = cat.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "cat.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cat.name)
                                .font(.headline)
                            
                            HStack {
                                Text(cat.gender.icon)
                                Text(cat.gender.rawValue)
                                
                                if cat.age > 0 {
                                    Text("• \(cat.age)살")
                                }
                                
                                if !cat.breed.isEmpty {
                                    Text("• \(cat.breed)")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteCats)
            }
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCat = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCat) {
                AddCatView()
            }
        }
    }
    
    private func deleteCats(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cats[index])
            }
        }
    }
}

#Preview {
    CatProfileListView()
        .modelContainer(for: Cat.self, inMemory: true)
} 