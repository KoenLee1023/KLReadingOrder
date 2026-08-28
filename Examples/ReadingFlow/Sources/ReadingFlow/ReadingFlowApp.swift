import KLReadingOrder
import SwiftUI

@main
struct ReadingFlowApp: App {
    var body: some Scene {
        WindowGroup("Reading Flow") {
            ReadingFlowView()
                .frame(minWidth: 760, minHeight: 520)
        }
    }
}

private struct ReadingFlowView: View {
    private let candidates = FlowSamples.candidates

    var body: some View {
        let lines = ReadingOrderEngine().reconstruct(
            candidates: candidates,
            memberSeparator: "  ·  "
        )
        HStack(spacing: 28) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Reading Flow").font(.largeTitle.bold())
                Text("Input geometry")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                GeometryCanvas(candidates: candidates)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 12) {
                Text("Resolved order").font(.title2.bold())
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Text(line.text).font(.headline)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
            }
            .frame(width: 300)
        }
        .padding(32)
    }
}

private struct GeometryCanvas: View {
    let candidates: [ReadingOrderCandidate]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.quaternary.opacity(0.35))
                ForEach(candidates, id: \.id) { candidate in
                    Text(candidate.text)
                        .font(.caption.bold())
                        .padding(6)
                        .frame(
                            width: candidate.boundingBox.width * proxy.size.width,
                            height: candidate.boundingBox.height * proxy.size.height
                        )
                        .background(.teal.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.teal))
                        .position(
                            x: candidate.boundingBox.midX * proxy.size.width,
                            y: (1 - candidate.boundingBox.midY) * proxy.size.height
                        )
                }
            }
        }
    }
}

private enum FlowSamples {
    static let candidates: [ReadingOrderCandidate] = [
        item(0, "Orchid", 0.08, 0.78, 0.22), item(1, "24", 0.72, 0.79, 0.12),
        item(2, "Moss", 0.08, 0.57, 0.18), item(3, "18", 0.72, 0.58, 0.12),
        item(4, "Total", 0.08, 0.35, 0.20), item(5, "42", 0.72, 0.36, 0.12),
    ]

    private static func item(
        _ id: Int,
        _ text: String,
        _ x: CGFloat,
        _ y: CGFloat,
        _ width: CGFloat
    ) -> ReadingOrderCandidate {
        ReadingOrderCandidate(
            id: id,
            text: text,
            confidence: 0.96,
            boundingBox: CGRect(x: x, y: y, width: width, height: 0.09),
            sourceOrder: id
        )
    }
}
