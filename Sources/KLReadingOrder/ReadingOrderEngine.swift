import CoreGraphics
import Foundation

/// A layout mode used to group and order OCR candidates.
///
/// A direction describes geometry, not language. The engine assumes every
/// candidate on a page uses one coordinate space in which `x` increases to the
/// right and `y` increases upward.
public enum ReadingDirection: String, Codable, Equatable, Sendable {
    /// Groups candidates into rows, orders rows from top to bottom, and orders
    /// members in each row from left to right.
    case horizontal

    /// Groups candidates into columns, orders columns from right to left, and
    /// orders members in each column from top to bottom.
    case vertical

    /// Asks the engine to infer horizontal or vertical layout independently
    /// for each nonempty page.
    ///
    /// The engine never emits this value in a reconstructed line. Pages that
    /// do not reach the policy's vertical ratio resolve to ``horizontal``.
    case unknown
}

/// One recognized text fragment and the geometry used to order it.
///
/// The type stores values without validation. Use a common normalized
/// coordinate system for all candidates on a page. Empty or whitespace-only
/// text is ignored by ``ReadingOrderEngine/reconstruct(candidates:preferredDirection:memberSeparator:)``.
public struct ReadingOrderCandidate: Equatable, Sendable {
    /// A caller-owned identifier copied into the containing output line.
    ///
    /// Identifiers are not required to be unique. Duplicate values remain
    /// duplicated and cannot identify one source candidate unambiguously.
    public let id: Int

    /// Recognized text that is trimmed before filtering and joining.
    public let text: String

    /// A caller-supplied confidence value included in an arithmetic mean.
    ///
    /// The engine does not clamp or validate this value. Nonfinite values and
    /// overflow while summing propagate according to `Double` arithmetic.
    public let confidence: Double

    /// The candidate rectangle in the page's shared coordinate space.
    ///
    /// The intended input is a normalized rectangle with rightward `x` and
    /// upward `y`. The engine does not normalize, standardize, clamp, or
    /// validate rectangles. Negative dimensions and nonfinite coordinates can
    /// therefore make sorting, clustering, and unions unreliable.
    public let boundingBox: CGRect

    /// The page key used for grouping and ascending page output order.
    ///
    /// Values may be negative or noncontiguous.
    public let pageIndex: Int

    /// A caller-supplied tie breaker for members with exactly equal primary
    /// coordinates inside one reconstructed row or column.
    ///
    /// Horizontal members use this value only when `minX` is equal. Vertical
    /// members use it only when `minY` is equal. Equal `sourceOrder` values do
    /// not receive an additional stable ordering guarantee.
    public let sourceOrder: Int

    /// Creates a reading-order candidate without validating its content or geometry.
    ///
    /// - Parameters:
    ///   - id: A caller-owned identifier. Uniqueness is recommended when the
    ///     integrating app uses output IDs to recover source metadata.
    ///   - text: Recognized text. Leading and trailing whitespace is removed
    ///     during reconstruction.
    ///   - confidence: A value to include unchanged in the output mean.
    ///   - boundingBox: A rectangle in the page's shared coordinate space.
    ///   - pageIndex: The page grouping key. The default is `0`.
    ///   - sourceOrder: The exact-coordinate tie breaker. The default is `0`.
    public init(
        id: Int,
        text: String,
        confidence: Double,
        boundingBox: CGRect,
        pageIndex: Int = 0,
        sourceOrder: Int = 0
    ) {
        self.id = id
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.pageIndex = pageIndex
        self.sourceOrder = sourceOrder
    }
}

/// One reconstructed horizontal row or vertical column.
///
/// The public initializer stores values as supplied. Only lines returned by
/// ``ReadingOrderEngine`` carry the aggregation behavior described by the
/// individual properties.
public struct ReadingOrderLine: Equatable, Sendable {
    /// Member identifiers in the reconstructed reading order.
    public let candidateIDs: [Int]

    /// The sequential `CGRect.union(_:)` of all member rectangles.
    ///
    /// Invalid or nonfinite input geometry is not repaired before the union.
    public let boundingBox: CGRect

    /// Trimmed member strings joined with the requested separator.
    public let text: String

    /// The arithmetic mean of member confidence values.
    public let confidence: Double

    /// The page key shared by the line's members.
    public let pageIndex: Int

    /// The resolved layout direction, either ``ReadingDirection/horizontal``
    /// or ``ReadingDirection/vertical`` for engine-produced lines.
    public let direction: ReadingDirection

    /// Creates a line value without recalculating or validating its fields.
    ///
    /// - Parameters:
    ///   - candidateIDs: Member identifiers in caller-defined order.
    ///   - boundingBox: A caller-supplied aggregate rectangle.
    ///   - text: A caller-supplied aggregate string.
    ///   - confidence: A caller-supplied aggregate confidence.
    ///   - pageIndex: The associated page key.
    ///   - direction: The associated direction. The initializer permits
    ///     ``ReadingDirection/unknown`` even though engine output does not use it.
    public init(
        candidateIDs: [Int],
        boundingBox: CGRect,
        text: String,
        confidence: Double,
        pageIndex: Int,
        direction: ReadingDirection
    ) {
        self.candidateIDs = candidateIDs
        self.boundingBox = boundingBox
        self.text = text
        self.confidence = confidence
        self.pageIndex = pageIndex
        self.direction = direction
    }
}

/// Thresholds used by horizontal, vertical, and automatic reconstruction.
///
/// Defaults are designed for normalized OCR rectangles. Properties remain
/// mutable so an integrating app can tune a named dimension before creating an
/// engine. No relationship, range, finiteness, or sign validation is applied.
/// Negative, inverted, NaN, or infinite values are accepted and flow through
/// the implementation's `min`, `max`, multiplication, and comparison operations.
public struct ReadingOrderPolicy: Equatable, Sendable {
    /// The height-to-width multiplier used to count a candidate as vertically shaped.
    public var verticalAspectRatio: CGFloat
    /// The inclusive proportion required to infer vertical layout for a page.
    public var automaticVerticalRatio: Double
    /// The horizontal median-height fallback when no candidate has positive height.
    public var defaultHorizontalHeight: CGFloat
    /// The lower clamp used for page-level horizontal tolerance.
    public var minimumHorizontalTolerance: CGFloat
    /// The upper clamp used for page-level horizontal tolerance.
    public var maximumHorizontalTolerance: CGFloat
    /// The multiplier applied to the median positive candidate height.
    public var horizontalToleranceScale: CGFloat
    /// The lower bound used for a row-to-candidate center comparison.
    public var minimumPairTolerance: CGFloat
    /// The multiplier applied to the smaller anchor or candidate height.
    public var pairToleranceScale: CGFloat
    /// The inclusive vertical-overlap ratio that can join a horizontal row
    /// when center proximity does not.
    public var minimumBaselineOverlap: CGFloat
    /// The vertical median-width fallback when no candidate has positive width.
    public var defaultVerticalWidth: CGFloat
    /// The lower clamp used for vertical column tolerance.
    public var minimumVerticalTolerance: CGFloat
    /// The upper clamp used for vertical column tolerance.
    public var maximumVerticalTolerance: CGFloat
    /// The multiplier applied to the median positive candidate width.
    public var verticalToleranceScale: CGFloat
    /// The denominator floor used when calculating horizontal box overlap.
    public var minimumOverlapReference: CGFloat

    /// Creates a geometry policy.
    ///
    /// Values are stored without validation. The defaults are expressed in the
    /// normalized coordinate scale expected by the package.
    ///
    /// - Parameters:
    ///   - verticalAspectRatio: Vertical-shape height-to-width multiplier.
    ///   - automaticVerticalRatio: Inclusive page ratio for vertical inference.
    ///   - defaultHorizontalHeight: Fallback horizontal height.
    ///   - minimumHorizontalTolerance: Horizontal page-tolerance lower clamp.
    ///   - maximumHorizontalTolerance: Horizontal page-tolerance upper clamp.
    ///   - horizontalToleranceScale: Median-height multiplier.
    ///   - minimumPairTolerance: Row-pair tolerance lower bound.
    ///   - pairToleranceScale: Smaller-height multiplier for row matching.
    ///   - minimumBaselineOverlap: Inclusive overlap ratio for row matching.
    ///   - defaultVerticalWidth: Fallback vertical width.
    ///   - minimumVerticalTolerance: Vertical tolerance lower clamp.
    ///   - maximumVerticalTolerance: Vertical tolerance upper clamp.
    ///   - verticalToleranceScale: Median-width multiplier.
    ///   - minimumOverlapReference: Overlap denominator floor.
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
    ) {
        self.verticalAspectRatio = verticalAspectRatio
        self.automaticVerticalRatio = automaticVerticalRatio
        self.defaultHorizontalHeight = defaultHorizontalHeight
        self.minimumHorizontalTolerance = minimumHorizontalTolerance
        self.maximumHorizontalTolerance = maximumHorizontalTolerance
        self.horizontalToleranceScale = horizontalToleranceScale
        self.minimumPairTolerance = minimumPairTolerance
        self.pairToleranceScale = pairToleranceScale
        self.minimumBaselineOverlap = minimumBaselineOverlap
        self.defaultVerticalWidth = defaultVerticalWidth
        self.minimumVerticalTolerance = minimumVerticalTolerance
        self.maximumVerticalTolerance = maximumVerticalTolerance
        self.verticalToleranceScale = verticalToleranceScale
        self.minimumOverlapReference = minimumOverlapReference
    }
}

/// A synchronous value-type engine that reconstructs reading order from geometry.
///
/// The engine performs no OCR, I/O, shared-state mutation, or asynchronous
/// work. It is `Sendable`; separate tasks may use copied or shared immutable
/// engine values as long as the caller also coordinates its own input and output.
public struct ReadingOrderEngine: Sendable {
    /// The immutable policy captured by this engine.
    public let policy: ReadingOrderPolicy

    /// Creates an engine with a captured policy.
    ///
    /// - Parameter policy: Thresholds used by every reconstruction call. The
    ///   default is ``ReadingOrderPolicy/init(verticalAspectRatio:automaticVerticalRatio:defaultHorizontalHeight:minimumHorizontalTolerance:maximumHorizontalTolerance:horizontalToleranceScale:minimumPairTolerance:pairToleranceScale:minimumBaselineOverlap:defaultVerticalWidth:minimumVerticalTolerance:maximumVerticalTolerance:verticalToleranceScale:minimumOverlapReference:)``.
    public init(policy: ReadingOrderPolicy = ReadingOrderPolicy()) {
        self.policy = policy
    }

    /// Groups candidates into ordered horizontal rows or vertical columns.
    ///
    /// The method trims text and drops whitespace-only candidates before page
    /// grouping. Pages are processed by ascending `pageIndex`. Forced directions
    /// apply to every page; ``ReadingDirection/unknown`` runs geometric inference
    /// independently per page. Horizontal rows run top to bottom with members
    /// left to right. Vertical columns run right to left with members top to bottom.
    ///
    /// The algorithm is heuristic. It does not detect rotation, deskew pages,
    /// normalize rectangles, understand language, separate tables, or validate
    /// identifiers, confidence values, geometry, or policy values.
    ///
    /// - Parameters:
    ///   - candidates: OCR fragments to reconstruct. An empty array or an array
    ///     containing only whitespace text returns an empty array.
    ///   - preferredDirection: A forced direction or per-page inference. The
    ///     default is ``ReadingDirection/unknown``.
    ///   - memberSeparator: Text inserted exactly once between trimmed member
    ///     strings. It is not trimmed or interpreted. The default is one space.
    /// - Returns: Lines ordered first by ascending page key and then by the
    ///   resolved geometry. The method does not throw.
    public func reconstruct(
        candidates: [ReadingOrderCandidate],
        preferredDirection: ReadingDirection = .unknown,
        memberSeparator: String = " "
    ) -> [ReadingOrderLine] {
        let usable = candidates.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let pages = Dictionary(grouping: usable, by: \.pageIndex)

        return pages.keys.sorted().flatMap { pageIndex in
            let pageCandidates = pages[pageIndex] ?? []
            switch resolvedDirection(preferredDirection, candidates: pageCandidates) {
            case .vertical:
                return reconstructVertical(
                    pageCandidates,
                    pageIndex: pageIndex,
                    memberSeparator: memberSeparator
                )
            case .horizontal, .unknown:
                return reconstructHorizontal(
                    pageCandidates,
                    pageIndex: pageIndex,
                    memberSeparator: memberSeparator
                )
            }
        }
    }

    private func resolvedDirection(
        _ preferredDirection: ReadingDirection,
        candidates: [ReadingOrderCandidate]
    ) -> ReadingDirection {
        guard preferredDirection == .unknown else { return preferredDirection }
        guard !candidates.isEmpty else { return .horizontal }
        let verticalCount = candidates.filter {
            $0.boundingBox.height > $0.boundingBox.width * policy.verticalAspectRatio
        }.count
        return Double(verticalCount) / Double(candidates.count)
            >= policy.automaticVerticalRatio ? .vertical : .horizontal
    }

    private struct HorizontalRow {
        let anchorMidY: CGFloat
        let anchorHeight: CGFloat
        var members: [ReadingOrderCandidate]

        var midY: CGFloat {
            members.map { $0.boundingBox.midY }.reduce(0, +)
                / CGFloat(members.count)
        }
    }

    private func reconstructHorizontal(
        _ candidates: [ReadingOrderCandidate],
        pageIndex: Int,
        memberSeparator: String
    ) -> [ReadingOrderLine] {
        let medianHeight = median(candidates.map(\.boundingBox.height).filter { $0 > 0 })
            ?? policy.defaultHorizontalHeight
        let pageTolerance = min(
            policy.maximumHorizontalTolerance,
            max(policy.minimumHorizontalTolerance, medianHeight * policy.horizontalToleranceScale)
        )
        let ordered = candidates.sorted {
            if abs($0.boundingBox.midY - $1.boundingBox.midY) > pageTolerance {
                return $0.boundingBox.midY > $1.boundingBox.midY
            }
            return $0.boundingBox.minX < $1.boundingBox.minX
        }

        var rows: [HorizontalRow] = []
        for candidate in ordered {
            let matchingIndex = rows.indices
                .filter { index in
                    let row = rows[index]
                    let heightTolerance = min(
                        pageTolerance,
                        max(
                            policy.minimumPairTolerance,
                            min(row.anchorHeight, candidate.boundingBox.height)
                                * policy.pairToleranceScale
                        )
                    )
                    return abs(row.anchorMidY - candidate.boundingBox.midY) <= heightTolerance
                        || baselineOverlap(row.members[0].boundingBox, candidate.boundingBox)
                            >= policy.minimumBaselineOverlap
                }
                .min {
                    abs(rows[$0].anchorMidY - candidate.boundingBox.midY)
                        < abs(rows[$1].anchorMidY - candidate.boundingBox.midY)
                }

            if let matchingIndex {
                rows[matchingIndex].members.append(candidate)
            } else {
                rows.append(HorizontalRow(
                    anchorMidY: candidate.boundingBox.midY,
                    anchorHeight: candidate.boundingBox.height,
                    members: [candidate]
                ))
            }
        }

        return rows.sorted { $0.midY > $1.midY }.map { row in
            makeLine(
                members: row.members.sorted {
                    $0.boundingBox.minX == $1.boundingBox.minX
                        ? $0.sourceOrder < $1.sourceOrder
                        : $0.boundingBox.minX < $1.boundingBox.minX
                },
                pageIndex: pageIndex,
                direction: .horizontal,
                separator: memberSeparator
            )
        }
    }

    private struct VerticalColumn {
        let anchorMidX: CGFloat
        var members: [ReadingOrderCandidate]

        var midX: CGFloat {
            members.map { $0.boundingBox.midX }.reduce(0, +)
                / CGFloat(members.count)
        }
    }

    private func reconstructVertical(
        _ candidates: [ReadingOrderCandidate],
        pageIndex: Int,
        memberSeparator: String
    ) -> [ReadingOrderLine] {
        let medianWidth = median(candidates.map(\.boundingBox.width).filter { $0 > 0 })
            ?? policy.defaultVerticalWidth
        let columnTolerance = min(
            policy.maximumVerticalTolerance,
            max(policy.minimumVerticalTolerance, medianWidth * policy.verticalToleranceScale)
        )
        let ordered = candidates.sorted {
            if abs($0.boundingBox.midX - $1.boundingBox.midX) > columnTolerance {
                return $0.boundingBox.midX > $1.boundingBox.midX
            }
            return $0.boundingBox.minY > $1.boundingBox.minY
        }

        var columns: [VerticalColumn] = []
        for candidate in ordered {
            let midX = candidate.boundingBox.midX
            if let matchingIndex = columns.indices.min(by: {
                abs(columns[$0].anchorMidX - midX) < abs(columns[$1].anchorMidX - midX)
            }), abs(columns[matchingIndex].anchorMidX - midX) <= columnTolerance {
                columns[matchingIndex].members.append(candidate)
            } else {
                columns.append(VerticalColumn(anchorMidX: midX, members: [candidate]))
            }
        }

        return columns.sorted { $0.midX > $1.midX }.map { column in
            makeLine(
                members: column.members.sorted {
                    $0.boundingBox.minY == $1.boundingBox.minY
                        ? $0.sourceOrder < $1.sourceOrder
                        : $0.boundingBox.minY > $1.boundingBox.minY
                },
                pageIndex: pageIndex,
                direction: .vertical,
                separator: memberSeparator
            )
        }
    }

    private func makeLine(
        members: [ReadingOrderCandidate],
        pageIndex: Int,
        direction: ReadingDirection,
        separator: String
    ) -> ReadingOrderLine {
        ReadingOrderLine(
            candidateIDs: members.map(\.id),
            boundingBox: union(members.map(\.boundingBox)),
            text: members.map {
                $0.text.trimmingCharacters(in: .whitespacesAndNewlines)
            }.joined(separator: separator),
            confidence: members.map(\.confidence).reduce(0, +)
                / Double(max(members.count, 1)),
            pageIndex: pageIndex,
            direction: direction
        )
    }

    private func union(_ boxes: [CGRect]) -> CGRect {
        guard let first = boxes.first else { return .zero }
        return boxes.dropFirst().reduce(first) { $0.union($1) }
    }

    private func baselineOverlap(_ lhs: CGRect, _ rhs: CGRect) -> CGFloat {
        let overlap = max(0, min(lhs.maxY, rhs.maxY) - max(lhs.minY, rhs.minY))
        let reference = max(
            policy.minimumOverlapReference,
            min(lhs.height, rhs.height)
        )
        return overlap / reference
    }

    private func median(_ values: [CGFloat]) -> CGFloat? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        return sorted.count.isMultiple(of: 2)
            ? (sorted[middle - 1] + sorted[middle]) / 2
            : sorted[middle]
    }
}
