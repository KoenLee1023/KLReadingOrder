# ``KLReadingOrder``

Reconstruct deterministic reading order from normalized OCR observations.

KLReadingOrder is a synchronous geometry layer. It groups observations by
page, resolves a horizontal or vertical layout, reconstructs rows or columns,
and preserves caller-owned candidate identifiers. It does not run OCR,
standardize rectangles, or interpret document semantics.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ReadingOrderEngine``
- ``ReadingOrderCandidate``
- ``ReadingOrderLine``

### Direction

- ``ReadingDirection``
- ``ReadingDirection/horizontal``
- ``ReadingDirection/vertical``
- ``ReadingDirection/unknown``
- ``ReadingDirection/init(rawValue:)``

### Candidate Fields

- ``ReadingOrderCandidate/id``
- ``ReadingOrderCandidate/text``
- ``ReadingOrderCandidate/confidence``
- ``ReadingOrderCandidate/boundingBox``
- ``ReadingOrderCandidate/pageIndex``
- ``ReadingOrderCandidate/sourceOrder``
- ``ReadingOrderCandidate/init(id:text:confidence:boundingBox:pageIndex:sourceOrder:)``

### Line Fields

- ``ReadingOrderLine/candidateIDs``
- ``ReadingOrderLine/boundingBox``
- ``ReadingOrderLine/text``
- ``ReadingOrderLine/confidence``
- ``ReadingOrderLine/pageIndex``
- ``ReadingOrderLine/direction``
- ``ReadingOrderLine/init(candidateIDs:boundingBox:text:confidence:pageIndex:direction:)``

### Reconstruction

- ``ReadingOrderEngine/policy``
- ``ReadingOrderEngine/init(policy:)``
- ``ReadingOrderEngine/reconstruct(candidates:preferredDirection:memberSeparator:)``

### Policy

- ``ReadingOrderPolicy``
- ``ReadingOrderPolicy/verticalAspectRatio``
- ``ReadingOrderPolicy/automaticVerticalRatio``
- ``ReadingOrderPolicy/defaultHorizontalHeight``
- ``ReadingOrderPolicy/minimumHorizontalTolerance``
- ``ReadingOrderPolicy/maximumHorizontalTolerance``
- ``ReadingOrderPolicy/horizontalToleranceScale``
- ``ReadingOrderPolicy/minimumPairTolerance``
- ``ReadingOrderPolicy/pairToleranceScale``
- ``ReadingOrderPolicy/minimumBaselineOverlap``
- ``ReadingOrderPolicy/defaultVerticalWidth``
- ``ReadingOrderPolicy/minimumVerticalTolerance``
- ``ReadingOrderPolicy/maximumVerticalTolerance``
- ``ReadingOrderPolicy/verticalToleranceScale``
- ``ReadingOrderPolicy/minimumOverlapReference``
- ``ReadingOrderPolicy/init(verticalAspectRatio:automaticVerticalRatio:defaultHorizontalHeight:minimumHorizontalTolerance:maximumHorizontalTolerance:horizontalToleranceScale:minimumPairTolerance:pairToleranceScale:minimumBaselineOverlap:defaultVerticalWidth:minimumVerticalTolerance:maximumVerticalTolerance:verticalToleranceScale:minimumOverlapReference:)``

### Localized Guides

- <doc:GettingStarted-zh-Hans>
- <doc:GettingStarted-zh-Hant>
- <doc:GettingStarted-ja>
- <doc:GettingStarted-ko>
