# KLReadingOrder

> Language: [English](README.md) · [简体中文](Documentation/zh-Hans/README.md) · [繁體中文](Documentation/zh-Hant/README.md) · [日本語](Documentation/ja/README.md) · [한국어](Documentation/ko/README.md)

API Documentation: [DocC](https://labs.wondays.space/documentation/en/klreadingorder)

Reconstruct human reading order from shuffled OCR observations with deterministic, inspectable geometry instead of document-specific guesses.

KLReadingOrder is a Swift package from Nuancery Labs, extracted from the layout reconstruction used by wondays. It accepts text, confidence, normalized boxes, page identity, and source order; it returns ordered lines while preserving caller-owned candidate IDs.

The package does not run OCR and does not interpret document meaning. It solves the geometric step between recognition and semantic extraction.

## Capabilities

- Horizontal row reconstruction from left to right
- Vertical column reconstruction from right to left
- Automatic direction selection per page
- Stable page ordering for multipage input
- Adaptive line and column tolerances based on median glyph geometry
- Baseline-overlap recovery for mixed-size horizontal observations
- Merged line bounds, average confidence, and source candidate IDs
- A fully named, configurable geometry policy
- Synchronous, deterministic, `Sendable` value types

## Requirements

- Swift 6.0 or newer
- iOS 17 or newer
- macOS 14 or newer
- Foundation and Core Graphics
- No OCR framework dependency and no third-party runtime dependencies

## Installation

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

## Quick start

Vision observations use normalized lower-left-origin rectangles, which can be passed directly when every candidate follows the same coordinate convention:

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

## Coordinate contract

All boxes on a page must use the same normalized coordinate space. The engine assumes increasing `x` moves right and increasing `y` moves up. Horizontal output orders rows from higher `midY` to lower `midY`, then members left to right. Vertical output orders columns from higher `midX` to lower `midX`, then members from higher `minY` to lower `minY`.

The package does not normalize pixels, rotate boxes, correct camera perspective, or reconcile mixed coordinate systems. Perform those transformations before constructing candidates.

## Direction behavior

Pass `.horizontal` or `.vertical` to force a mode. With `.unknown`, each page is classified independently. A candidate is considered vertically shaped when its height exceeds width times `verticalAspectRatio`; the page becomes vertical when their proportion reaches `automaticVerticalRatio`.

Empty pages produce no lines. Unknown mode on a nonvertical page resolves to horizontal.

## Output semantics

Each `ReadingOrderLine` contains:

- ordered `candidateIDs` for recovering richer host metadata
- the union of member bounding boxes
- trimmed member text joined by `memberSeparator`
- arithmetic mean confidence
- page index and resolved direction

Candidates whose text is empty after trimming are removed before page grouping. Their IDs do not appear in output.

## Policy tuning

`ReadingOrderPolicy` exposes every threshold used by the algorithm. Start with defaults and tune only against a varied fixture set. Avoid fitting one receipt, page, font, or language; tolerances interact with normalized box size and should remain domain-independent.

## Documentation

- [Getting Started](Documentation/en/GettingStarted.md)
- [API Reference](Documentation/en/API.md)
- [Architecture](Documentation/en/Architecture.md)
- [Migration](Documentation/en/Migration.md)
- [Demo Apps](Examples/Documentation/en/README.md)

## Scope and status

Excluded: OCR execution, confidence rejection, deskewing, orientation detection, language identification, paragraph semantics, table extraction, and document-specific vocabulary. The first implementation is integrated into wondays and remains pre-1.0.

## License

MIT. See [LICENSE](LICENSE).
