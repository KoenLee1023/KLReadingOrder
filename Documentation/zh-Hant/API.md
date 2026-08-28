# KLReadingOrder API 參考

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder 接收文字、信心值、正規化邊界框、頁面識別與來源順序，回傳有序行，同時保留呼叫方候選 ID。它不執行 OCR，也不解讀文件語意，只處理辨識與語意擷取之間的幾何步驟。

## 公開 API

- `ReadingDirection`：`.horizontal`、`.vertical` 或逐頁推斷的 `.unknown`。
- `ReadingOrderCandidate`：呼叫方 ID、文字、信心值、邊界框、頁碼與來源順序。
- `ReadingOrderLine`：有序候選 ID、合併框、串接文字、平均信心值、頁碼與已解析方向。
- `ReadingOrderPolicy`：公開所有幾何閾值及產品預設值。
- `ReadingOrderEngine.reconstruct`：同步執行過濾、分頁、方向判斷、分群、排序與彙總，不進行 I/O。

## 完整簽名

```swift
public enum ReadingDirection: String, Codable, Equatable, Sendable {
    case horizontal
    case vertical
    case unknown
}
```

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

```swift
public struct ReadingOrderPolicy: Equatable, Sendable
```

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

```swift
let engine = ReadingOrderEngine()
let lines = engine.reconstruct(
    candidates: pageZero + pageOne,
    preferredDirection: .unknown,
    memberSeparator: " "
)

let byPage = Dictionary(grouping: lines, by: \.pageIndex)
```

## 行為保證

- 橫排由上至下、行內由左至右
- 直排按欄由右至左、欄內由上至下
- 每頁獨立自動判斷方向
- 依字形中位幾何調整容差
- 多頁排序、合併邊界、平均信心值與來源 ID

## 職責邊界

不執行 OCR、校正傾斜、旋轉、透視修正、信心值篩選、語言辨識、表格擷取或文件語意。每頁所有框必須使用同一正規化座標系。

## 完整行為約定

- `ReadingDirection.horizontal` 依行由上而下，行內由左至右。`vertical` 依列由右至左，列內由上而下。`unknown` 會逐頁判斷，輸出不會保留 `unknown`。
- `ReadingOrderCandidate` 的六個屬性都會原樣保存。初始化器不檢查 ID、文字、信心值、矩形、頁碼或來源順序。只有空白的文字會在重建前移除。
- `ReadingOrderLine` 的公開初始化器只保存傳入值，不會計算矩形聯集或信心值。由引擎建立的結果會按成員順序保留 `candidateIDs`、串接修剪後的文字、依序合併矩形，並計算信心值的算術平均。
- `ReadingOrderPolicy` 的十三個屬性分別控制縱向外形判斷、自動直排比例、橫排行容差、成對比對、基線重疊、直排列容差與重疊分母下限。初始化器使用簽名中的預設值，但不檢查範圍、大小關係、正負或有限性。
- `verticalAspectRatio` 是縱向外形判斷的高寬乘數。`automaticVerticalRatio` 是自動採用直排所需的最低比例，邊界值會計入直排。
- `defaultHorizontalHeight` 在沒有嚴格正高度時作為替代值。`minimumHorizontalTolerance` 與 `maximumHorizontalTolerance` 限制頁面層級的橫排容差，`horizontalToleranceScale` 會乘上嚴格正高度的中位數。
- `minimumPairTolerance` 是行錨點與候選項目比較的下限，但最後仍受頁面層級容差限制。`pairToleranceScale` 會乘上錨點高度與候選高度的較小值。`minimumBaselineOverlap` 是可取代中心距離判斷的最小縱向重疊比例，邊界值有效。
- `defaultVerticalWidth` 在沒有嚴格正寬度時作為替代值。`minimumVerticalTolerance` 與 `maximumVerticalTolerance` 限制列容差，`verticalToleranceScale` 會乘上嚴格正寬度的中位數。
- `minimumOverlapReference` 是計算基線重疊比例時的分母下限。
- `ReadingOrderEngine.policy` 是初始化時保存的不可變策略。`reconstruct` 同步執行、不進行 I/O，也不會拋出錯誤。空輸入與全部為空白的輸入都會回傳空陣列。
- 座標應正規化，x 向右增加，y 向上增加。程式不會檢查範圍、轉換原點、修正旋轉或標準化 `CGRect`。
- 頁碼可以是負數或不連續。頁面一律依數值遞增處理。
- 自動判斷以 `height > width * verticalAspectRatio` 計算縱向外形候選。比例大於或等於 `automaticVerticalRatio` 時採用直排，否則採用橫排。
- 橫排容差取嚴格正高度的中位數，再按策略限制。候選可透過中心距離或達到下限的基線重疊加入行。直排容差以嚴格正寬度的中位數計算，並選擇距離最近且位於容差內的既有列。
- `sourceOrder` 只在橫排成員的 `minX` 完全相等，或直排成員的 `minY` 完全相等時參與比較。所有排序值都相等時，不保證額外的穩定順序。
- 重複 ID 不會去除。`memberSeparator` 會原樣插入成員文字之間。信心值不限制範圍，矩形依序使用 `CGRect.union(_:)` 合併。
- 無效或非有限的矩形、信心值與策略值不會被拒絕，可能造成排序不可靠或輸出非有限數值。所有公開值型別均符合 `Sendable`。
