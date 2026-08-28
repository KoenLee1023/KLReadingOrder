# Getting Started

Convert OCR output into candidates, reconstruct each page, and recover source metadata through candidate identifiers.

## Prepare one coordinate space

Use one normalized coordinate system per page. The engine expects `x` to increase to the right and `y` to increase upward. Convert pixel rectangles and top-left-origin rectangles before constructing candidates.

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

The package does not validate or repair rectangles. Keep identifiers unique if the integrating app uses them to recover individual source observations.

## Reconstruct the page

Use automatic inference for unclassified input, or force a direction when page metadata is authoritative.

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

Automatic inference counts vertically shaped boxes independently on each page. It does not inspect text or detect language. A page that does not reach ``ReadingOrderPolicy/automaticVerticalRatio`` resolves to horizontal layout.

## Interpret the result

Pages appear by ascending page index. Horizontal rows appear top to bottom and read left to right. Vertical columns appear right to left and read top to bottom. Each line contains the union of member rectangles and the arithmetic mean of member confidence values.

Whitespace-only candidates are removed. The separator is inserted exactly between trimmed member strings. Use an empty separator when spaces are not wanted.

## Respect the algorithm boundary

KLReadingOrder is synchronous and performs no I/O. It does not deskew pages, detect orientation, normalize coordinates, reject low-confidence observations, parse tables, or understand document meaning. Invalid rectangles, duplicate identifiers, nonfinite confidence values, and invalid policy values are accepted without validation and can produce ambiguous or nonfinite output.

## Localized guides

- <doc:GettingStarted-zh-Hans>
- <doc:GettingStarted-zh-Hant>
- <doc:GettingStarted-ja>
- <doc:GettingStarted-ko>
