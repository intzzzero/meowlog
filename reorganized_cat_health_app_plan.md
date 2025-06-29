# 🐾 고양이 건강관리 iOS 앱 기획안 (재구성)

## 0. 📝 개발 환경 설정

본 프로젝트는 AI 코드 에디터 **Cursor**를 적극적으로 활용하여 개발 생산성을 높이는 것을 목표로 합니다. 코드 작성 및 수정은 Cursor의 AI 지원 기능을 최대한 활용하고, 프로젝트 빌드, 실행, 디버깅은 **Sweetpad 확장 프로그램**을 통해 Cursor 내에서 통합 관리합니다.

이를 위해 `xcode-build-server`, `xcbeautify` 등의 도구를 설치하고 `buildServer.json` 파일을 설정하여 Cursor를 완전한 Swift IDE처럼 사용합니다. 이를 통해 Xcode와 Cursor를 오가는 번거로움을 줄이고 개발 워크플로우를 단순화합니다.

---

## 1. 📌 프로젝트 개요

| 항목             | 내용 |
|------------------|------|
| **프로젝트명(가칭)** | MeowLog / NekoCare / PawPal |
| **타겟 사용자**     | 반려묘 1마리 이상을 키우는 iOS 사용자 (특히 건강관리에 관심 있는 보호자) |
| **주요 목적**       | 고양이의 일상 건강 상태를 기록하고, 투약·증상·호흡 등을 관리함으로써 질병 조기 대응 |
| **플랫폼**         | iOS 전용 (iPhone, iOS 17 이상 / 일부 기능 iOS 18 이상 필요) |
| **개발 방식**       | Native iOS 앱 (Swift + SwiftUI) |

---

## 2. 🧩 핵심 기능

### 2.1. 주요 기능

| 기능명             | 상세 설명 | 핵심 기술/API |
|------------------|------------|----------------|
| **1. 배변 기록**       | 날짜/시간/사진/메모, 이상 여부 선택, 캘린더 보기 | SwiftUI, SwiftData, Photo Picker |
| **2. 투약 스케줄 관리** | 약 종류별 주기 설정 (예: 구충제 매달), 푸시 알림, 복약 여부 체크 | `UserNotifications`, SwiftData |
| **3. 프로필 등록**     | 이름, 생일, 입양일, 품종, 사진 등록 / 생일 알림 | SwiftUI Forms, `UserNotifications` |
| **4. 호흡수 측정**     | **1. 자동 측정:** 잠자거나 쉬고 있는 고양이의 가슴/등 위에 아이폰을 올려두면, 가속도계 센서가 미세한 움직임을 감지하여 1분간의 호흡수를 자동으로 측정. 측정 가이드(올려두는 위치, 측정 조건 등) 제공.<br>**2. 수동 측정:** 화면을 보며 스톱워치와 함께 보호자가 직접 호흡수를 세고 기록하는 기능 병행 제공. | `CoreMotion` (Accelerometer), `SwiftUI`, `CoreML` (향후 패턴 분석) |
| **5. 증상 기반 AI 상담** | 증상 입력 → Apple Intelligence API 기반 대화형 상담, 병원 방문 필요 여부 판단. ⚠️ **주의: 본 기능은 수의사의 진단을 대체할 수 없으며, 의료적 조언이 아닙니다. 항상 전문가와 상담하세요.** | Apple Intelligence API (iOS18+), SwiftData |
| **6. 주간/월간 건강 리포트** | 배변/투약/호흡 등의 통계를 PDF로 생성, 보호자 공유 가능 | Swift Charts, PDFKit |
| **7. 체중 관리 (옵션)** | 체중 기록, 표준체중과 비교, 경고 메시지 | Charts, SwiftData |
| **8. 다묘 등록 기능** | 고양이 여러 마리 관리, 각 프로필 분리 | SwiftData |

### 2.2. 사용자 경험(UX) 개선

| 기능명             | 상세 설명 | 핵심 기술/API |
|------------------|------------|----------------|
| **홈 화면 위젯**      | 오늘의 건강 상태 요약, 다음 투약 일정, 주간 배변 횟수 등 | `WidgetKit`, `SwiftUI` |
| **다크모드 최적화**   | 야간 사용 시 고양이에게 스트레스 최소화하는 어두운 테마 | SwiftUI Environment, Custom Colors |
| **접근성 기능**       | VoiceOver, Dynamic Type, 고대비 모드 지원 | `Accessibility`, `UIAccessibility` |
| **햅틱 피드백**       | 기록 완료, 알림 등에 적절한 촉각 피드백 제공 | `UIKit Haptics`, `Core Haptics` |

---

## 3. 🩺 혁신 및 고급 기능

### 3.1. 심장 건강 모니터링 (혁신 기능)

| 기능명             | 상세 설명 | 핵심 기술/API |
|------------------|------------|----------------|
| **심박수 측정**       | Apple Watch 센서를 활용한 고양이 심박수 측정 (접촉/비접촉 방식) | `HealthKit`, `WatchKit`, 심박수 센서 API |
| **심장병 케어 모드**  | 심장병 진단받은 고양이 전용 모니터링 모드, 연속 측정 | 심박수 변동성(HRV) 분석, 패턴 인식 |
| **응급 상황 감지**    | 위험 수준의 심박수 변화 시 즉시 알림 (빈맥>200bpm, 서맥<100bpm) | 실시간 알고리즘, 푸시 알림 |
| **약물 효과 추적**    | 심장약 복용 전후 심박수 변화 모니터링 | 시계열 데이터 분석, 상관관계 분석 |
| **수의사 리포트**     | 심박수 데이터를 의료진이 활용할 수 있는 형태로 생성 | 의료 데이터 표준화, PDF 생성 |

### 3.2. 기술적 개선 사항

| 기능명             | 상세 설명 | 핵심 기술/API |
|------------------|------------|----------------|
| **HealthKit 연동**    | 보호자의 스트레스 지수, 수면 패턴과 반려묘 건강 상태 상관관계 분석 (초기 시각화, 유의미한 인사이트 도출을 위해 전문가 자문 및 추가 분석 필요) | `HealthKit`, 상관관계 분석 알고리즘 |
| **Apple Watch 앱**   | 간단한 기록 입력 (배변, 투약 체크), 투약 알림 확인, 호흡수/심박수 측정 | `WatchKit`, `WatchConnectivity`, `HealthKit` |
| **Shortcuts 연동**   | "오늘 배변 기록해줘", "투약 완료" 등 음성 명령 지원 | `Intents Framework`, `SiriKit` |

### 3.3. 데이터 기반 인사이트

| 기능명             | 상세 설명 | 구현 방식 |
|------------------|------------|-----------|
| **계절별 건강 패턴**  | 환절기 건강 변화 추이, 계절별 주의사항 알림 | 시계열 분석, Weather API 연동 |
| **품종별 데이터 비교** | 동일 품종 평균 데이터와 비교 차트 제공 | 익명화된 통계 데이터, Swift Charts |
| **행동 패턴 학습**    | 배변 시간, 투약 후 반응 등의 패턴을 학습하여 이상 징후 조기 발견 | `CoreML`, 패턴 분석 알고리즘 |
| **건강 점수 시스템**  | 종합적인 건강 상태를 점수화하여 직관적 표시 | 가중치 기반 점수 계산 |

---

## 4. 🛠️ 기술 및 개발

### 4.1. 기술 스택

| 분류           | 기술명 / 도구 |
|----------------|----------------|
| **언어**         | Swift (최신 버전) |
| **UI 프레임워크** | SwiftUI (iOS 17 기준), UIKit 병행 가능 |
| **로컬 데이터**   | SwiftData |
| **백엔드**       | Supabase (PostgreSQL, 인증, 스토리지, Edge Functions) |
| **알림 기능**     | UserNotifications Framework |
| **AI 연동**       | Apple Intelligence API *(iOS 18 이상)* 또는 GPT API (백업용) |
| **건강/센서**    | HealthKit, CoreMotion, WatchKit |
| **플랫폼 연동**   | WidgetKit, Intents Framework, SiriKit |
| **기타**         | PDFKit, Swift Charts, PHPicker, Accessibility APIs |
| **도구**         | Git, GitHub, Figma |

### 4.2. 백엔드 기획 (Supabase)

#### 도입 목표
- **개발 효율성 증대**: BaaS를 활용하여 서버 구축 및 관리에 드는 시간과 비용 절감
- **확장성 확보**: 사용자 증가 및 기능 확장에 유연하게 대응
- **실시간 데이터 처리**: 심박수 모니터링, 알림 등 실시간 기능 지원
- **안정적인 데이터 관리**: PostgreSQL 기반의 안정적인 데이터베이스 활용

#### 주요 활용 방안
| 기능 영역        | Supabase 활용 상세 |
|------------------|--------------------|
| **인증**         | Apple ID, 이메일/비밀번호 등 다양한 인증 방식 지원 |
| **데이터베이스**   | 고양이 프로필, 건강 기록(배변, 투약 등) 저장 및 관리 |
| **스토리지**       | 배변 사진, 프로필 사진 등 사용자 미디어 파일 저장 |
| **Edge Functions** | 서버리스 함수를 이용한 푸시 알림, 데이터 분석, AI 연동 로직 처리 |
| **실시간**       | 실시간 데이터베이스 기능을 활용한 Apple Watch 데이터 동기화 |

### 4.3. 심박수 모니터링 상세 구현 계획

#### 측정 방법 및 정확도
| 방법 | 설명 | 정확도 | 편의성 | 고양이 스트레스 |
|------|------|--------|--------|-----------------|
| **가슴 접촉법** | 워치 착용 손을 고양이 가슴에 가볍게 올림 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **목 부위법** | 목 동맥 근처에서 측정 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **다리 안쪽법** | 앞다리 안쪽 동맥 부근 측정 | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |

#### 응급 상황 감지 시스템
- **정상 심박수 기준**: 휴식 시 120-140 bpm, 활동 시 140-180 bpm
- **위험 신호**: >200 bpm (빈맥) 또는 <100 bpm (서맥)
- **알림 로직**: 위험 수준의 심박수 변화 시 즉시 보호자에게 알림(진동, 사운드) 및 응급처치 가이드, 주변 병원 정보 제공

#### 구현 코드 예시
```swift
import WatchKit
import HealthKit

class CatCardiacMonitor: ObservableObject {
    @Published var currentHeartRate: Int = 0
    private let healthStore = HKHealthStore()
    
    func startHeartRateMonitoring() {
        // Apple Watch 심박수 센서 활성화 및 실시간 데이터 수신
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { query, samples, _, _, _ in
            self.processHeartRateData(samples: samples)
        }
        healthStore.execute(query)
    }
    
    private func processHeartRateData(samples: [HKSample]?) {
        guard let sample = samples?.last as? HKQuantitySample else { return }
        let heartRate = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        
        // 위험 심박수 감지 및 알림
        if heartRate > 200 || heartRate < 100 {
            triggerEmergencyAlert()
        }
        // 데이터 저장 및 분석
        saveHeartRateReading(heartRate: heartRate)
    }
    
    private func triggerEmergencyAlert() { /* ... */ }
    private func saveHeartRateReading(heartRate: Int) { /* ... */ }
}
```

---

## 5. 🚀 실행 계획 (Roadmap)

### 5.1. 개발 단계

| 단계 | 기간 | 주요 목표 |
|------|------|-----------|
| **1단계: 기획 및 디자인** | 1주 | 기능 우선순위 확정(MVP), 와이어프레임, 기본 디자인 |
| **2단계: MVP 개발** | ~4주 | 핵심 기록 기능, 프로필, 수동 체크, 위젯/다크모드 등 기본 구현 |
| **3단계: 고급 기능 개발** | 3~5주 | AI 상담, PDF 리포트, Apple Watch 앱, HealthKit 연동, 심장병 케어 모드 |
| **4단계: 데이터 분석** | 2~3주 | 계절별/품종별 분석, 행동 패턴 학습, 건강 점수 시스템 |
| **5단계: QA 및 배포** | 1~2주 | TestFlight를 통한 베타 테스트, 피드백 수집 및 버그 수정 |
| **6단계: App Store 제출** | - | 앱스토어 등록 및 심사 |

### 5.2. MVP(최소 기능 제품) 범위 정의

| 포함 여부 | 기능 |
|-----------|------|
| ✅        | 배변 기록 (텍스트 + 사진) |
| ✅        | 고양이 프로필 등록 |
| ✅        | 투약 스케줄 관리 및 알림 |
| ✅        | 수동 호흡수 체크 (타이머 기반) |
| ✅        | 기본 홈 화면 위젯 |
| ✅        | 다크모드 지원 |
| ✅        | 기본 접근성 기능 |
| ✅        | 기본 심박수/호흡수 측정 (Watch 연동) |
| ❌(2단계)  | Apple Watch 앱, HealthKit 연동, 심장병 케어 고급 기능 |
| ❌(3단계)  | AI 상담 기능, 고급 데이터 분석 및 인사이트 |
| ❌(후속)   | PDF 리포트, 체중 관리 등 |

---

## 6. 📈 장기 비전

### 6.1. 향후 발전 방향
- **커뮤니티**: 사용자 정보 공유, 증상 사례 Q&A
- **수의사 연동**: 원격 상담, 데이터 공유 대시보드
- **IoT 연동**: 스마트 화장실, 스마트 급식기 데이터 자동 수집
- **고도화**: 머신러닝 기반 질병 예측, 심장병 전문 케어 플랜, 응급 상황 대응 시스템
- **사업 확장**: 펫 보험사 연동을 통한 건강 할인 혜택 제공

### 6.2. 수익 모델

| 유형             | 상세 설명 |
|------------------|------------|
| **프리미엄 구독**   | 고급 데이터 분석, 심장병 케어 모드, 수의사 리포트 PDF 생성 등 프리미엄 기능 제공 |
| **광고**         | 비침해적인 인앱 광고 (선택 사항) |
| **제휴/연동 수수료** | 동물병원 예약, 펫 보험 연동 시 수수료 모델 (추후) |

---
*마지막 업데이트: 2025년 6월 29일*
