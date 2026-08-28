# KLReadingOrder: 시작하기

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

Xcode의 Add Package Dependencies에서 저장소를 추가하거나 `Package.swift`에 다음을 선언합니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

## 통합

### 1. 같은 페이지의 사각형을 x는 오른쪽, y는 위쪽으로 증가하는 공통 정규화 좌표에 맞춥니다.

KLReadingOrder는 문자열, 신뢰도, 정규화된 사각형, 페이지 번호, 원래 입력 순서를 받아 읽기 순서로 묶은 행을 반환하는 Swift 패키지입니다. OCR 자체나 문서의 의미를 분석하지 않고 인식 결과를 읽기 좋은 순서로 정리하는 작업만 담당합니다.

### 2. OCR 인식 결과에서 안정적인 ID와 원래 입력 순서를 가진 후보를 만듭니다.

```swift
let candidates = observations.enumerated().map { index, observation in
    ReadingOrderCandidate(
        id: index,
        text: observation.text,
        confidence: observation.confidence,
        boundingBox: observation.normalizedBoundingBox,
        pageIndex: observation.pageIndex,
        sourceOrder: index
    )
}
```

패키지는 사각형을 검사하지 않으며 ID의 고유성도 요구하지 않습니다. ID로 개별 원본을 찾으려면 앱에서 고유성을 보장하세요.

### 3. 가로쓰기 또는 세로쓰기를 지정하거나 `.unknown`으로 페이지마다 자동 판정합니다.

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

자동 판정은 세로로 긴 사각형의 비율만 계산합니다. 문자열이나 언어는 판정에 사용하지 않습니다.

### 4. `candidateIDs`로 앱의 원본 데이터를 찾습니다. 글자 사이에 공백이 필요하지 않으면 빈 `memberSeparator`를 전달합니다.

공백만 있는 후보는 제거됩니다. 결과는 페이지 번호 오름차순입니다. 사각형 합집합이나 신뢰도 평균의 유효성을 보정하지 않습니다.

## 체크리스트

- [ ] 가로쓰기는 위에서 아래, 같은 행에서는 왼쪽에서 오른쪽
- [ ] 세로쓰기는 오른쪽 열에서 왼쪽으로, 같은 열에서는 위에서 아래
- [ ] 페이지마다 가로쓰기와 세로쓰기를 자동 판정
- [ ] 글자 크기에 맞춰 행과 열 판정 범위를 조절
- [ ] 여러 페이지, 병합된 사각형, 평균 신뢰도, 원본 후보 ID 지원

이 패키지는 OCR, 기울기 및 회전 보정, 원근 보정, 신뢰도 필터링, 언어 감지, 표 추출, 문서 의미 분석을 수행하지 않습니다. 같은 페이지에 있는 모든 사각형은 반드시 동일한 정규화 좌표계를 사용해야 합니다.

잘못된 사각형, 중복 ID, 유한하지 않은 신뢰도, 잘못된 정책 값도 거부하지 않으므로 순서가 불명확해지거나 유한하지 않은 값이 출력될 수 있습니다.
