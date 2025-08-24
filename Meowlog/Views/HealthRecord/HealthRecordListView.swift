import SwiftUI
import SwiftData

struct HealthRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var showingCalendar = false
    @State private var showingAddBowelMovement = false
    @State private var showingAddUrineRecord = false
    @State private var showingAddOtherRecord = false
    
    @Query private var allHealthRecords: [HealthRecord]
    
    private var filteredHealthRecords: [HealthRecord] {
        let calendar = Calendar.current
        return allHealthRecords.filter { record in
            calendar.isDate(record.date, inSameDayAs: selectedDate)
        }
    }
    
    private var recordDates: Set<Date> {
        let calendar = Calendar.current
        return Set(allHealthRecords.map { calendar.startOfDay(for: $0.date) })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 날짜 선택 UI
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    Text(DateFormatter.dateDisplayFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingCalendar = true
                }
                .accessibilityLabel("날짜 선택")
                .accessibilityHint("탭하여 다른 날짜를 선택하세요")
                
                List {
                    if filteredHealthRecords.isEmpty {
                        ContentUnavailableView(
                            "이 날짜에 건강 기록이 없습니다",
                            systemImage: "heart.text.square",
                            description: Text("건강 기록을 추가해보세요")
                        )
                        .listRowBackground(Color(.systemBackground))
                    } else {
                        ForEach(filteredHealthRecords.sorted(by: { $0.date > $1.date })) { record in
                            HealthRecordRow(record: record)
                                .listRowBackground(Color(.systemBackground))
                        }
                        .onDelete(perform: deleteRecords)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .navigationTitle("건강 기록")
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
                    .background(Color(.systemBackground))
                    .ignoresSafeArea(.container, edges: .horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingAddBowelMovement = true
                        }) {
                            Label("배변 기록", systemImage: "toilet")
                        }
                        
                        Button(action: {
                            showingAddUrineRecord = true
                        }) {
                            Label("소변 기록", systemImage: "drop")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showingAddOtherRecord = true
                        }) {
                            Label("기타 기록", systemImage: "heart.text.square")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCalendar) {
                HealthRecordCalendarView(
                    selectedDate: $selectedDate,
                    recordDates: recordDates,
                    isPresented: $showingCalendar
                )
            }
            .sheet(isPresented: $showingAddBowelMovement) {
                AddBowelMovementView()
            }
            .sheet(isPresented: $showingAddUrineRecord) {
                AddUrineRecordView()
            }
            .sheet(isPresented: $showingAddOtherRecord) {
                AddOtherHealthRecordView()
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            let sortedRecords = filteredHealthRecords.sorted(by: { $0.date > $1.date })
            for index in offsets {
                modelContext.delete(sortedRecords[index])
            }
        }
    }
}

extension DateFormatter {
    static let dateDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

struct HealthRecordCalendarView: View {
    @Binding var selectedDate: Date
    let recordDates: Set<Date>
    @Binding var isPresented: Bool
    
    @State private var displayedMonth = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                // 월 네비게이션
                HStack {
                    Button(action: {
                        withAnimation {
                            displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: displayedMonth))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // 요일 헤더
                HStack {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // 캘린더 그리드
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInMonth.indices, id: \.self) { index in
                        let date = daysInMonth[index]
                        if let date = date {
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            let hasRecord = recordDates.contains(date)
                            let isToday = Calendar.current.isDateInToday(date)
                            
                            Button(action: {
                                selectedDate = date
                                isPresented = false
                            }) {
                                VStack(spacing: 2) {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(
                                            isSelected ? .white :
                                            isToday ? .blue :
                                            .primary
                                        )
                                    
                                    if hasRecord {
                                        Circle()
                                            .fill(isSelected ? Color.white : Color.blue)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.blue : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Color.clear
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("오늘") {
                        selectedDate = Calendar.current.startOfDay(for: Date())
                        displayedMonth = Date()
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            displayedMonth = selectedDate
        }
    }
    
    private var daysInMonth: [Date?] {
        guard let monthRange = Calendar.current.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = Calendar.current.dateInterval(of: .month, for: displayedMonth)?.start else {
            return []
        }
        
        let firstWeekday = Calendar.current.component(.weekday, from: firstOfMonth)
        let daysInPreviousMonth = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: daysInPreviousMonth)
        
        for day in monthRange {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(Calendar.current.startOfDay(for: date))
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    HealthRecordListView()
        .modelContainer(for: HealthRecord.self, inMemory: true)
} 