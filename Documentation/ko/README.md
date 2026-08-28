# KLReadingOrder

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

OCR 인식 결과의 순서가 뒤섞여 있어도 좌표 정보를 이용해 사람이 읽는 순서로 다시 정렬합니다.

KLReadingOrder는 문자열, 신뢰도, 정규화된 사각형, 페이지 번호, 원래 입력 순서를 받아 읽기 순서로 묶은 행을 반환하는 Swift 패키지입니다. OCR 자체나 문서의 의미를 분석하지 않고 인식 결과를 읽기 좋은 순서로 정리하는 작업만 담당합니다.

## 개요

- 가로쓰기는 위에서 아래, 같은 행에서는 왼쪽에서 오른쪽
- 세로쓰기는 오른쪽 열에서 왼쪽으로, 같은 열에서는 위에서 아래
- 페이지마다 가로쓰기와 세로쓰기를 자동 판정
- 글자 크기에 맞춰 행과 열 판정 범위를 조절
- 여러 페이지, 병합된 사각형, 평균 신뢰도, 원본 후보 ID 지원

## 요구 사항

- Swift 6.0 이상
- iOS 17 이상
- macOS 14 이상
- 서드파티 런타임 의존성 없음
- Foundation · Core Graphics

## 설치

Xcode의 Add Package Dependencies에서 저장소를 추가하거나 `Package.swift`에 다음을 선언합니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

```swift
import KLReadingOrder
```

## 시작하기

1. 같은 페이지의 사각형을 x는 오른쪽, y는 위쪽으로 증가하는 공통 정규화 좌표에 맞춥니다.
2. OCR 인식 결과에서 안정적인 ID와 원래 입력 순서를 가진 후보를 만듭니다.
3. 가로쓰기 또는 세로쓰기를 지정하거나 `.unknown`으로 페이지마다 자동 판정합니다.
4. `candidateIDs`로 앱의 원본 데이터를 찾습니다. 글자 사이에 공백이 필요하지 않으면 빈 `memberSeparator`를 전달합니다.

```swift
let candidates = observations.enumerated().map { index, observation in
    ReadingOrderCandidate(
        id: index,
        text: observation.topCandidates(1).first?.string ?? "",
        confidence: Double(observation.confidence),
        boundingBox: observation.boundingBox,
        pageIndex: 0,
        sourceOrder: index
    )
}

let lines = ReadingOrderEngine().reconstruct(candidates: candidates)

for line in lines {
    print(line.text)
}
```

## 동작 보장

- `ReadingDirection`: 가로쓰기 `.horizontal`, 세로쓰기 `.vertical`, 페이지별 자동 판정 `.unknown`을 지정합니다.
- `ReadingOrderCandidate`: 앱의 ID, 문자열, 신뢰도, 사각형, 페이지 번호, 원래 입력 순서를 담습니다.
- `ReadingOrderLine`: 읽기 순서로 정렬한 후보 ID, 병합한 사각형과 문자열, 평균 신뢰도, 페이지 번호, 확정된 쓰기 방향을 반환합니다.
- `ReadingOrderPolicy`: 행과 열 판정에 사용하는 임계값을 공개하며 용도에 맞게 조정할 수 있습니다.
- `ReadingOrderEngine.reconstruct`: 빈 후보 제거, 페이지 분리, 방향 판정, 행 또는 열 분류, 정렬, 결과 병합을 동기 방식으로 수행합니다. 네트워크나 파일 작업은 하지 않습니다.

## 책임 경계

이 패키지는 OCR, 기울기 및 회전 보정, 원근 보정, 신뢰도 필터링, 언어 감지, 표 추출, 문서 의미 분석을 수행하지 않습니다. 같은 페이지에 있는 모든 사각형은 반드시 동일한 정규화 좌표계를 사용해야 합니다.

## 문서

- [시작하기](GettingStarted.md)
- [API 레퍼런스](API.md)
- [아키텍처](Architecture.md)
- [마이그레이션](Migration.md)
- [데모 앱](../../Examples/Documentation/ko/README.md)
- [기여](CONTRIBUTING.md)
- [보안 정책](SECURITY.md)
- [행동 강령](CODE_OF_CONDUCT.md)
- [변경 기록](CHANGELOG.md)

## 상태

현재 API 버전은 1.0 미만입니다. wondays에서 실제로 사용하고 있지만 안정 버전을 발표하기 전까지는 마이너 업데이트에서 이름이나 설정 방식을 변경할 수 있습니다.

## 라이선스

MIT. [LICENSE](../../LICENSE)
