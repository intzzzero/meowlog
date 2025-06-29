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

