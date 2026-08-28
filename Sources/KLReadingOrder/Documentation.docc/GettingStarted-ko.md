# 시작하기

OCR 결과를 후보로 변환하고 페이지별 읽기 순서를 재구성합니다. 반환된 후보 ID로 앱의 원본 데이터도 다시 찾을 수 있습니다.

## 좌표계 통일하기

같은 페이지의 사각형은 하나의 정규화 좌표계를 사용해야 합니다. 엔진은 x가 오른쪽으로, y가 위쪽으로 증가한다고 가정합니다. 픽셀 좌표나 왼쪽 위가 원점인 좌표는 후보를 만들기 전에 앱에서 변환하세요.

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

패키지는 사각형을 검사하거나 보정하지 않습니다. ID로 개별 원본을 찾으려면 후보마다 고유한 ID를 사용하세요.

## 읽기 순서 재구성하기

페이지 방향을 알 수 없을 때는 자동 판정을 사용합니다. 신뢰할 수 있는 메타데이터가 있다면 가로쓰기 또는 세로쓰기를 명시할 수 있습니다.

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

자동 판정은 페이지마다 세로로 긴 사각형의 비율을 계산합니다. 문자열이나 언어는 판정에 사용하지 않습니다. ``ReadingOrderPolicy/automaticVerticalRatio``에 도달하지 않은 페이지는 가로쓰기로 처리합니다.

## 결과 사용하기

페이지는 `pageIndex` 오름차순으로 나옵니다. 가로쓰기 행은 위에서 아래로, 행 안에서는 왼쪽에서 오른쪽으로 정렬됩니다. 세로쓰기 열은 오른쪽에서 왼쪽으로, 열 안에서는 위에서 아래로 정렬됩니다. 각 결과에는 구성원 사각형의 합집합과 신뢰도의 산술 평균도 포함됩니다.

공백만 있는 후보는 제거됩니다. `memberSeparator`는 앞뒤 공백을 제거한 구성원 문자열 사이에 그대로 삽입됩니다. 공백이 필요 없다면 빈 문자열을 전달하세요.

## 알고리즘의 범위 이해하기

KLReadingOrder는 동기 방식으로 실행되며 I/O를 수행하지 않습니다. 기울기 보정, 방향 감지, 좌표 정규화, 낮은 신뢰도 결과 제거, 표 분석, 문서 의미 해석은 처리하지 않습니다. 잘못된 사각형, 중복 ID, 유한하지 않은 신뢰도, 잘못된 정책 값도 거부하지 않으므로 순서가 불명확해지거나 유한하지 않은 값이 출력될 수 있습니다.
