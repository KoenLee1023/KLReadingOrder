import CoreGraphics
import Testing
@testable import KLReadingOrder

@Suite
struct ReadingOrderEngineTests {
    @Test
    func `reconstructs shuffled horizontal columns with mixed heights`() {
        let candidates = [
            candidate("238", x: 0.82, y: 0.82, width: 0.08, height: 0.03, id: 1),
            candidate("total", x: 0.10, y: 0.62, width: 0.16, height: 0.04, id: 4),
            candidate("milk", x: 0.10, y: 0.81, width: 0.18, height: 0.05, id: 0),
            candidate("395", x: 0.82, y: 0.63, width: 0.08, height: 0.03, id: 5),
            candidate("note", x: 0.45, y: 0.62, width: 0.05, height: 0.05, id: 3),
            candidate("coffee", x: 0.10, y: 0.72, width: 0.28, height: 0.04, id: 2),
            candidate("158", x: 0.82, y: 0.72, width: 0.08, height: 0.03, id: 6),
        ]

        let lines = ReadingOrderEngine().reconstruct(
            candidates: candidates,
            memberSeparator: "    "
        )

        #expect(lines.map(\.text) == [
            "milk    238",
            "coffee    158",
            "total    note    395",
        ])
    }

    @Test
    func `keeps pages independent and orders top to bottom`() {
        let candidates = [
            candidate("page two", x: 0.1, y: 0.8, page: 1, id: 0),
            candidate("lower", x: 0.1, y: 0.2, page: 0, id: 1),
            candidate("upper", x: 0.1, y: 0.8, page: 0, id: 2),
        ]

        let lines = ReadingOrderEngine().reconstruct(candidates: candidates)

        #expect(lines.map(\.text) == ["upper", "lower", "page two"])
        #expect(lines.map(\.pageIndex) == [0, 0, 1])
    }

    @Test
    func `vertical columns read right to left and top to bottom`() {
        let candidates = [
            candidate("down", x: 0.72, y: 0.55, width: 0.04, height: 0.09, id: 1),
            candidate("left", x: 0.52, y: 0.78, width: 0.04, height: 0.09, id: 2),
            candidate("up", x: 0.72, y: 0.78, width: 0.04, height: 0.09, id: 0),
        ]

        let lines = ReadingOrderEngine().reconstruct(
            candidates: candidates,
            preferredDirection: .vertical,
            memberSeparator: "-"
        )

        #expect(lines.map(\.text) == ["up-down", "left"])
        #expect(lines.map(\.direction) == [.vertical, .vertical])
    }

    @Test
    func `ignores candidates containing only whitespace`() {
        let lines = ReadingOrderEngine().reconstruct(candidates: [
            candidate("  \n", x: 0.1, y: 0.8, id: 0),
            candidate("kept", x: 0.1, y: 0.6, id: 1),
        ])

        #expect(lines.map(\.text) == ["kept"])
        #expect(lines.flatMap(\.candidateIDs) == [1])
    }

    private func candidate(
        _ text: String,
        x: Double,
        y: Double,
        width: Double = 0.2,
        height: Double = 0.04,
        page: Int = 0,
        id: Int
    ) -> ReadingOrderCandidate {
        ReadingOrderCandidate(
            id: id,
            text: text,
            confidence: 0.9,
            boundingBox: CGRect(x: x, y: y, width: width, height: height),
            pageIndex: page,
            sourceOrder: id
        )
    }
}
