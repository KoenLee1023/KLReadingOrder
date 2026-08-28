# KLReadingOrder Demo Apps

The repository contains two standalone SwiftUI applications with synthetic normalized boxes.

## Reading Flow

Reading Flow displays six synthetic observations in a normalized, lower-left-origin canvas and shows the horizontal lines returned by the default engine. It demonstrates shuffled input, row grouping, left-to-right member order, custom separators, and the conversion from normalized geometry to a top-left-origin SwiftUI canvas. It uses one page and does not display candidate IDs.

## Layout Comparator

Layout Comparator applies forced horizontal and forced vertical reconstruction to the same four candidates. Both result cards show line text and member IDs. It does not run automatic inference or expose policy controls.

Build either standalone package with Swift Package Manager:

```bash
swift build --package-path Examples/ReadingFlow

swift build --package-path Examples/LayoutComparator
```

The examples do not run Vision or interpret document semantics; they isolate the package's geometric contract.
