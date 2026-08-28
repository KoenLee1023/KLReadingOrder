# KLReadingOrder API Reference

This reference covers every public declaration in KLReadingOrder 0.1.0.

## `ReadingDirection`

```swift
public enum ReadingDirection: String, Codable, Equatable, Sendable {
    case horizontal
    case vertical
    case unknown
}
```

- `.horizontal`: cluster rows and order members left to right.
- `.vertical`: cluster columns from right to left and order members top to bottom.
- `.unknown`: infer direction independently for each page.

## `ReadingOrderCandidate`

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

| Field | Contract |
| --- | --- |
| `id` | Caller-owned identity returned in output lines. IDs should be unique within one reconstruction call. |
| `text` | Recognized text. Whitespace is trimmed; empty results are discarded. |
| `confidence` | Passed through aggregation without clamping. Supply a consistent scale. |
| `boundingBox` | Normalized, common-coordinate rectangle for geometric clustering. |
| `pageIndex` | Page grouping and ascending output order. It need not be contiguous. |
| `sourceOrder` | Tie breaker when two members share the same primary coordinate. |

## `ReadingOrderLine`

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

`candidateIDs` follows member reading order. `boundingBox` is the union of member rectangles. `text` joins trimmed member strings. `confidence` is their arithmetic mean. Output directions are resolved `.horizontal` or `.vertical`, not `.unknown`.

## `ReadingOrderPolicy`

```swift
public struct ReadingOrderPolicy: Equatable, Sendable
```

The initializer exposes all policy properties with defaults:

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

| Property | Role |
| --- | --- |
| `verticalAspectRatio` | Height-to-width threshold for classifying one candidate as vertically shaped. |
| `automaticVerticalRatio` | Required proportion of vertically shaped candidates for automatic vertical mode. |
| `defaultHorizontalHeight` | Fallback normalized height when no positive candidate heights exist. |
| `minimumHorizontalTolerance` | Lower clamp for page-level horizontal row tolerance. |
| `maximumHorizontalTolerance` | Upper clamp for page-level horizontal row tolerance. |
| `horizontalToleranceScale` | Multiplier applied to median positive candidate height. |
| `minimumPairTolerance` | Lower clamp for row-to-candidate center comparison. |
| `pairToleranceScale` | Multiplier applied to the smaller row-anchor/candidate height. |
| `minimumBaselineOverlap` | Required vertical overlap ratio that can join candidates despite center distance. |
| `defaultVerticalWidth` | Fallback normalized width when no positive widths exist. |
| `minimumVerticalTolerance` | Lower clamp for column-center tolerance. |
| `maximumVerticalTolerance` | Upper clamp for column-center tolerance. |
| `verticalToleranceScale` | Multiplier applied to median positive candidate width. |
| `minimumOverlapReference` | Positive denominator floor for baseline overlap. |

Properties are mutable so a host can begin with defaults and adjust named dimensions. The package does not validate policy relationships; nonsensical negative or inverted values can produce nonsensical grouping.

## `ReadingOrderEngine`

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

### `init(policy:)`

Captures an immutable policy for later calls. The default initializer uses the documented values above.

### `reconstruct(candidates:preferredDirection:memberSeparator:)`

1. Remove candidates whose trimmed text is empty.
2. Group remaining candidates by `pageIndex`.
3. Process page keys in ascending order.
4. Resolve direction for each page unless the caller forced one.
5. Cluster rows or columns with adaptive tolerances.
6. Sort members, merge bounds, join text, and average confidence.

`memberSeparator` is inserted exactly between trimmed member strings. Use `""` for scripts that should not receive spaces or a custom token when preserving downstream boundaries.

The method is synchronous, performs no OCR or I/O, and returns an empty array for empty or all-whitespace input.

## Multipage example

```swift
let engine = ReadingOrderEngine()
let lines = engine.reconstruct(
    candidates: pageZero + pageOne,
    preferredDirection: .unknown,
    memberSeparator: " "
)

let byPage = Dictionary(grouping: lines, by: \.pageIndex)
```

## Exact edge behavior

- Candidate and line initializers only store their arguments. They perform no validation or aggregation.
- Coordinates are expected to be normalized with rightward `x` and upward `y`, but the engine does not enforce that range or orientation.
- Empty input and all-whitespace input return `[]`. Filtering happens before page grouping and automatic inference.
- Page keys may be negative or sparse. Output pages use numeric ascending order.
- Automatic inference counts `height > width * verticalAspectRatio`. A page is vertical when `Double(verticalCount) / Double(candidateCount) >= automaticVerticalRatio`; otherwise it is horizontal.
- Horizontal clustering derives page tolerance from the median of strictly positive heights. Row matching uses anchor-center proximity or the inclusive baseline-overlap threshold. Final rows use their members' mean `midY`.
- Vertical clustering derives tolerance from the median of strictly positive widths and compares each candidate with the nearest existing column anchor. Final columns use their members' mean `midX`.
- `sourceOrder` is consulted only when horizontal members have exactly equal `minX` or vertical members have exactly equal `minY`. Fully equal sort keys have no additional stable-order promise.
- Duplicate IDs are retained in `candidateIDs`. The engine does not deduplicate candidates.
- Line bounds are a sequential `CGRect.union(_:)`. Confidence is an unclamped arithmetic mean. `memberSeparator` is inserted verbatim between trimmed strings.
- Policy properties, rectangles, confidence, and IDs are never validated. Negative, inverted, NaN, or infinite policy and geometry values can produce unreliable ordering or nonfinite output.
- Reconstruction is synchronous, nonthrowing, and has no I/O or shared mutable state. The value types conform to `Sendable`.
