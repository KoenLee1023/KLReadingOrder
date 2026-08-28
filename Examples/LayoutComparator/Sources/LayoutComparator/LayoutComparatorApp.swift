import KLReadingOrder
import SwiftUI

@main
struct LayoutComparatorApp: App {
    var body: some Scene {
        WindowGroup("Layout Comparator") {
            LayoutComparatorView()
                .frame(minWidth: 720, minHeight: 480)
        }
    }
}

private struct LayoutComparatorView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Layout Comparator").font(.largeTitle.bold())
            Text("Force a direction to inspect how identical boxes form lines or columns.")
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                resultCard(title: "Horizontal", direction: .horizontal)
                resultCard(title: "Vertical", direction: .vertical)
            }
        }
        .padding(32)
    }

    private func resultCard(title: String, direction: ReadingDirection) -> some View {
        let lines = ReadingOrderEngine().reconstruct(
            candidates: ComparatorSamples.candidates,
            preferredDirection: direction,
            memberSeparator: direction == .vertical ? "" : " "
        )
        return VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.title2.bold())
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                VStack(alignment: .leading, spacing: 4) {
                    Text(line.text).font(.headline)
                    Text("IDs · \(line.candidateIDs.map(String.init).joined(separator: ", "))")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

private enum ComparatorSamples {
    static let candidates: [ReadingOrderCandidate] = [
        item(0, "A", 0.68, 0.74), item(1, "B", 0.68, 0.52),
        item(2, "C", 0.42, 0.74), item(3, "D", 0.42, 0.52),
    ]

    private static func item(
        _ id: Int,
        _ text: String,
        _ x: CGFloat,
        _ y: CGFloat
    ) -> ReadingOrderCandidate {
        ReadingOrderCandidate(
            id: id,
            text: text,
            confidence: 1,
            boundingBox: CGRect(x: x, y: y, width: 0.06, height: 0.12),
            sourceOrder: id
        )
    }
}
