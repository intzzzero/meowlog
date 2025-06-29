# MeowLog 개발 명령어 모음

## 1. 빌드만 하기

xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates build | xcbeautify

## 2. iPhone 16 Pro 시뮬레이터에서 빌드 & 실행 (한 번에)

xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' | xcbeautify

## 3. 시뮬레이터 열기

open -a Simulator

## 4. 앱 직접 실행 (이미 설치된 경우)

xcrun simctl launch booted com.meowlog.app.Meowlog

## 5. 테스트 실행

xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates test -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' | xcbeautify

## 6. 문제해결 및 디버깅 커맨드

### 6.1 부팅된 시뮬레이터 확인

xcrun simctl list devices | grep "iPhone 16 Pro" | grep "Booted"

### 6.2 특정 시뮬레이터에서 앱 실행 (시뮬레이터 ID 직접 지정)

xcrun simctl launch AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 com.meowlog.app.Meowlog

### 6.3 앱 완전 제거 후 재설치 (캐시 문제 해결)

```bash
# 1. 앱 제거
xcrun simctl uninstall AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 com.meowlog.app.Meowlog

# 2. 최신 빌드 앱 설치
xcrun simctl install AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 ~/Library/Developer/Xcode/DerivedData/Meowlog-*/Build/Products/Debug-iphonesimulator/Meowlog.app

# 3. 앱 실행
xcrun simctl launch AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 com.meowlog.app.Meowlog
```

### 6.4 시뮬레이터 디바이스 ID 확인

xcrun simctl list devices | grep "iPhone 16 Pro"

### 6.5 설치된 앱 목록 확인

xcrun simctl listapps booted | grep meowlog

## 7. 유용한 팁

- 앱이 시뮬레이터에서 업데이트되지 않을 때: 6.3의 완전 제거 후 재설치 사용
- 시뮬레이터 ID는 `xcrun simctl list devices`로 확인 가능
- `booted` 대신 특정 시뮬레이터 ID 사용 시 더 정확한 제어 가능
