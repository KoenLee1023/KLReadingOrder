# KLReadingOrder: 快速開始

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

透過 Xcode 的 Add Package Dependencies 加入儲存庫，或在 `Package.swift` 中宣告：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

## 整合

### 1. 確認同頁邊界框使用一致正規化座標：x 向右、y 向上。

KLReadingOrder 接收文字、信心值、正規化邊界框、頁面識別與來源順序，回傳有序行，同時保留呼叫方候選 ID。它不執行 OCR，也不解讀文件語意，只處理辨識與語意擷取之間的幾何步驟。

### 2. 由 OCR 辨識結果建立候選並保留穩定 ID 與來源順序。

```swift
let candidates = observations.enumerated().map { index, observation in
    ReadingOrderCandidate(
        id: index,
        text: observation.text,
        confidence: observation.confidence,
        boundingBox: observation.normalizedBoundingBox,
        pageIndex: observation.pageIndex,
        sourceOrder: index
    )
}
```

套件不檢查矩形，也不要求 ID 唯一。若 App 要透過 ID 取回單一來源，應自行確保唯一性。

### 3. 明確指定橫排／直排，或使用 `.unknown` 逐頁自動判斷。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自動判斷只計算縱向外形矩形的比例，不會讀取文字或辨識語言。

### 4. 以 `candidateIDs` 找回 App 的原始資料。文字之間不需要空格時，可傳入空的 `memberSeparator`。

只有空白的候選項目會被移除。結果依頁碼遞增排列。矩形聯集與信心值平均不會進行有效性修正。

## 檢查清單

- [ ] 橫排由上至下、行內由左至右
- [ ] 直排按欄由右至左、欄內由上至下
- [ ] 每頁獨立自動判斷方向
- [ ] 依字形中位幾何調整容差
- [ ] 多頁排序、合併邊界、平均信心值與來源 ID

不執行 OCR、校正傾斜、旋轉、透視修正、信心值篩選、語言辨識、表格擷取或文件語意。每頁所有框必須使用同一正規化座標系。

無效矩形、重複 ID、非有限信心值與無效策略值不會被拒絕，可能造成順序不明確或輸出非有限數值。
