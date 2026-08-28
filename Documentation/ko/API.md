# KLReadingOrder API 레퍼런스

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder는 문자열, 신뢰도, 정규화된 사각형, 페이지 번호, 원래 입력 순서를 받아 읽기 순서로 묶은 행을 반환하는 Swift 패키지입니다. OCR 자체나 문서의 의미를 분석하지 않고 인식 결과를 읽기 좋은 순서로 정리하는 작업만 담당합니다.

## 공개 API

- `ReadingDirection`: 가로쓰기 `.horizontal`, 세로쓰기 `.vertical`, 페이지별 자동 판정 `.unknown`을 지정합니다.
- `ReadingOrderCandidate`: 앱의 ID, 문자열, 신뢰도, 사각형, 페이지 번호, 원래 입력 순서를 담습니다.
- `ReadingOrderLine`: 읽기 순서로 정렬한 후보 ID, 병합한 사각형과 문자열, 평균 신뢰도, 페이지 번호, 확정된 쓰기 방향을 반환합니다.
- `ReadingOrderPolicy`: 행과 열 판정에 사용하는 임계값을 공개하며 용도에 맞게 조정할 수 있습니다.
- `ReadingOrderEngine.reconstruct`: 빈 후보 제거, 페이지 분리, 방향 판정, 행 또는 열 분류, 정렬, 결과 병합을 동기 방식으로 수행합니다. 네트워크나 파일 작업은 하지 않습니다.

## 전체 시그니처

```swift
public enum ReadingDirection: String, Codable, Equatable, Sendable {
    case horizontal
    case vertical
    case unknown
}
```

```swift
public struct ReadingOrderCandidate: Equatable, Sendable {
    public let id: Int
    public let text: String
    public let confidence: Double
    public let boundingBox: CGRect
    public let pageIndex: Int
    public let sourceOrder: Int

    public init(
        id: Int,
        text: String,
        confidence: Double,
        boundingBox: CGRect,
        pageIndex: Int = 0,
        sourceOrder: Int = 0
    )
}
```

```swift
public struct ReadingOrderLine: Equatable, Sendable {
    public let candidateIDs: [Int]
    public let boundingBox: CGRect
    public let text: String
    public let confidence: Double
    public let pageIndex: Int
    public let direction: ReadingDirection

    public init(
        candidateIDs: [Int],
        boundingBox: CGRect,
        text: String,
        confidence: Double,
        pageIndex: Int,
        direction: ReadingDirection
    )
}
```

```swift
public struct ReadingOrderPolicy: Equatable, Sendable
```

```swift
public init(
    verticalAspectRatio: CGFloat = 1.65,
    automaticVerticalRatio: Double = 2.0 / 3.0,
    defaultHorizontalHeight: CGFloat = 0.02,
    minimumHorizontalTolerance: CGFloat = 0.003,
    maximumHorizontalTolerance: CGFloat = 0.018,
    horizontalToleranceScale: CGFloat = 0.48,
    minimumPairTolerance: CGFloat = 0.0025,
    pairToleranceScale: CGFloat = 0.48,
    minimumBaselineOverlap: CGFloat = 0.56,
    defaultVerticalWidth: CGFloat = 0.02,
    minimumVerticalTolerance: CGFloat = 0.004,
    maximumVerticalTolerance: CGFloat = 0.025,
    verticalToleranceScale: CGFloat = 0.72,
    minimumOverlapReference: CGFloat = 0.0001
)
```

```swift
public struct ReadingOrderEngine: Sendable {
    public let policy: ReadingOrderPolicy
    public init(policy: ReadingOrderPolicy = ReadingOrderPolicy())

    public func reconstruct(
        candidates: [ReadingOrderCandidate],
        preferredDirection: ReadingDirection = .unknown,
        memberSeparator: String = " "
    ) -> [ReadingOrderLine]
}
```

```swift
let engine = ReadingOrderEngine()
let lines = engine.reconstruct(
    candidates: pageZero + pageOne,
    preferredDirection: .unknown,
    memberSeparator: " "
)

let byPage = Dictionary(grouping: lines, by: \.pageIndex)
```

## 동작 보장

- 가로쓰기는 위에서 아래, 같은 행에서는 왼쪽에서 오른쪽
- 세로쓰기는 오른쪽 열에서 왼쪽으로, 같은 열에서는 위에서 아래
- 페이지마다 가로쓰기와 세로쓰기를 자동 판정
- 글자 크기에 맞춰 행과 열 판정 범위를 조절
- 여러 페이지, 병합된 사각형, 평균 신뢰도, 원본 후보 ID 지원

## 책임 경계

이 패키지는 OCR, 기울기 및 회전 보정, 원근 보정, 신뢰도 필터링, 언어 감지, 표 추출, 문서 의미 분석을 수행하지 않습니다. 같은 페이지에 있는 모든 사각형은 반드시 동일한 정규화 좌표계를 사용해야 합니다.

## 세부 동작 규약

- `ReadingDirection.horizontal`은 행을 위에서 아래로, 행 안을 왼쪽에서 오른쪽으로 정렬합니다. `vertical`은 열을 오른쪽에서 왼쪽으로, 열 안을 위에서 아래로 정렬합니다. `unknown`은 페이지별로 판정되며 출력에는 남지 않습니다.
- `ReadingOrderCandidate`의 여섯 속성은 그대로 저장됩니다. 초기화 메서드는 ID, 문자열, 신뢰도, 사각형, 페이지 번호, 원본 순서를 검사하지 않습니다. 공백만 있는 문자열은 재구성 전에 제거됩니다.
- `ReadingOrderLine`의 공개 초기화 메서드는 값을 저장할 뿐 사각형이나 신뢰도를 집계하지 않습니다. 엔진이 만든 결과에는 구성원 순서의 `candidateIDs`, 앞뒤 공백을 제거해 연결한 문자열, 사각형의 순차 합집합, 신뢰도의 산술 평균이 들어갑니다.
- `ReadingOrderPolicy`의 열세 속성은 세로로 긴 형태 판정, 자동 세로쓰기 비율, 가로쓰기 행 허용 오차, 후보 쌍 비교, 기준선 겹침, 세로쓰기 열 허용 오차, 겹침 계산의 분모 하한을 제어합니다. 범위, 대소 관계, 부호, 유한성은 검사하지 않습니다.
- `verticalAspectRatio`는 세로로 긴 형태를 판정할 때 쓰는 높이 대 너비 배율입니다. `automaticVerticalRatio`는 자동으로 세로쓰기를 선택하는 최소 비율이며 경곗값을 포함합니다.
- `defaultHorizontalHeight`는 양수 높이가 없을 때 쓰는 대체값입니다. `minimumHorizontalTolerance`와 `maximumHorizontalTolerance`는 페이지 단위 행 허용 오차를 제한하고, `horizontalToleranceScale`은 양수 높이의 중앙값에 곱합니다.
- `minimumPairTolerance`는 행 기준점과 후보를 비교할 때의 하한이지만 최종값은 페이지 단위 허용 오차의 제한도 받습니다. `pairToleranceScale`은 기준 높이와 후보 높이 중 작은 값에 곱합니다. `minimumBaselineOverlap`은 중심 거리 대신 행에 추가할 수 있는 최소 세로 겹침 비율이며 경곗값을 포함합니다.
- `defaultVerticalWidth`는 양수 너비가 없을 때 쓰는 대체값입니다. `minimumVerticalTolerance`와 `maximumVerticalTolerance`는 열 허용 오차를 제한하고, `verticalToleranceScale`은 양수 너비의 중앙값에 곱합니다.
- `minimumOverlapReference`는 기준선 겹침 비율을 계산할 때 사용하는 분모의 하한입니다.
- `ReadingOrderEngine.policy`는 초기화할 때 저장되는 불변 정책입니다. `reconstruct`는 동기 방식으로 실행되며 I/O를 수행하지 않고 오류를 던지지 않습니다. 빈 배열과 공백만 있는 입력은 빈 배열을 반환합니다.
- 좌표는 정규화하고 x는 오른쪽으로, y는 위쪽으로 증가해야 합니다. 범위 검사, 원점 변환, 회전 보정, `CGRect` 표준화는 수행하지 않습니다.
- 페이지 번호는 음수이거나 연속적이지 않아도 됩니다. 출력은 숫자 오름차순입니다.
- 자동 판정은 `height > width * verticalAspectRatio`를 만족하는 후보를 셉니다. 그 비율이 `automaticVerticalRatio` 이상이면 세로쓰기, 아니면 가로쓰기로 처리합니다.
- 가로쓰기 허용 오차는 양수 높이의 중앙값으로 계산합니다. 중심 거리 또는 기준 이상인 기준선 겹침으로 행에 추가됩니다. 세로쓰기는 양수 너비의 중앙값으로 허용 오차를 구하고 가장 가까운 기존 열이 범위 안에 있으면 추가합니다.
- `sourceOrder`는 가로쓰기 구성원의 `minX`가 정확히 같거나 세로쓰기 구성원의 `minY`가 정확히 같을 때만 사용합니다. 모든 비교 값이 같으면 추가적인 안정 순서를 보장하지 않습니다.
- 중복 ID는 제거하지 않습니다. `memberSeparator`는 문자열 사이에 그대로 삽입됩니다. 신뢰도 범위는 제한하지 않으며 사각형은 `CGRect.union(_:)`으로 순서대로 합칩니다.
- 잘못되었거나 유한하지 않은 사각형, 신뢰도, 정책 값은 거부하지 않습니다. 순서가 불명확해지거나 유한하지 않은 값이 출력될 수 있습니다. 모든 공개 값 타입은 `Sendable`을 준수합니다.
