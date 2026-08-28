# KLReadingOrder Architecture

KLReadingOrder is a pure geometric reconstruction layer between OCR observations and semantic document interpretation.

## Page isolation

Usable candidates are grouped by page before direction inference or clustering. This prevents geometry from one page influencing another and guarantees ascending page-index output.

## Horizontal reconstruction

The engine derives page tolerance from median positive box height, clamped by policy. Candidates are sorted top to bottom and left to right. A row accepts a candidate through center proximity or sufficient baseline overlap, then members are sorted left to right with source order as a tie breaker.

## Vertical reconstruction

Column tolerance derives from median positive width. Candidates and final columns are ordered right to left. Members inside a column are ordered by descending `minY`, again using source order for ties.

## Adaptive but deterministic

Median geometry adapts to OCR scale while named minimum and maximum values prevent a single page from producing unbounded tolerance. No model, randomness, locale service, or global cache participates.

## Ownership boundary

The package owns ordering geometry and line aggregation. OCR execution, confidence thresholds, orientation correction, table parsing, domain vocabulary, and semantic field extraction remain outside.
