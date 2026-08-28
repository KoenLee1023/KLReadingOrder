# Getting Started with KLReadingOrder

## 1. Add the package

Add `https://github.com/KoenLee1023/KLReadingOrder.git` from version `0.1.0`, link the `KLReadingOrder` product, and import it beside the OCR adapter—not inside document-domain extraction.

## 2. Normalize geometry

Convert every observation on a page to one normalized coordinate system. If input uses top-left origin, rotate or flip it before constructing candidates. Never mix pixel and normalized boxes in one call.

## 3. Preserve host metadata by ID

```swift
let indexed = Dictionary(uniqueKeysWithValues: observations.indices.map {
    ($0, observations[$0])
})

let candidates = indexed.map { id, item in
    ReadingOrderCandidate(
        id: id,
        text: item.text,
        confidence: item.confidence,
        boundingBox: item.normalizedBox,
        pageIndex: item.page,
        sourceOrder: item.sourceOrder
    )
}
```

The engine returns IDs so richer OCR metadata does not need to enter package models.

## 4. Select direction deliberately

Use `.unknown` for mixed or unclassified pages. Force `.horizontal` or `.vertical` when document metadata is authoritative. Automatic inference is geometric, not linguistic.

## 5. Rehydrate results

```swift
for line in engine.reconstruct(candidates: candidates) {
    let sourceItems = line.candidateIDs.compactMap { indexed[$0] }
    consume(line.text, sources: sourceItems)
}
```

## Tuning checklist

- maintain fixtures from different fonts, scales, and layouts
- tune normalized thresholds, never pixel constants
- change one named policy dimension at a time
- test row and column near-misses as well as successful joins
- preserve source-order tie breakers
- keep semantic document rules outside geometry policy
