# Migrating to KLReadingOrder

## 1. Preserve raw OCR observations

Before migration, retain text, confidence, boxes, page identity, and original order in fixtures. Expected output should assert candidate IDs as well as final strings.

## 2. Add an adapter at the pipeline boundary

Convert host observations to `ReadingOrderCandidate` and keep a dictionary keyed by the integer ID. Do not move recognition framework types into the package.

## 3. Confirm coordinate conventions

Many layout regressions are coordinate mismatches rather than grouping errors. Verify origin, axis direction, rotation, and normalization for every input source.

## 4. Compare forced and automatic modes

Run representative pages through the prior algorithm and through `.horizontal`, `.vertical`, and `.unknown`. Automatic mode is per-page and may expose previous hidden assumptions.

## 5. Tune with a corpus

If defaults differ from established output, adjust `ReadingOrderPolicy` against varied fixtures. Keep thresholds generic and named; document why a change improves the corpus rather than one screenshot.

## 6. Remove the duplicate engine

Once package tests and wondays OCR regressions pass, delete local clustering helpers while keeping confidence filtering and semantic extraction in their original owners.
