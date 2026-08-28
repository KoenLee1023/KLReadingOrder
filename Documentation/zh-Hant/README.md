# KLReadingOrder

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

以可預期且可檢查的幾何規則，從亂序 OCR 辨識結果重建人類閱讀順序。

KLReadingOrder 接收文字、信心值、正規化邊界框、頁面識別與來源順序，回傳有序行，同時保留呼叫方候選 ID。它不執行 OCR，也不解讀文件語意，只處理辨識與語意擷取之間的幾何步驟。

## 概覽

- 橫排由上至下、行內由左至右
- 直排按欄由右至左、欄內由上至下
- 每頁獨立自動判斷方向
- 依字形中位幾何調整容差
- 多頁排序、合併邊界、平均信心值與來源 ID

## 需求

- Swift 6.0 或更新版本
- iOS 17 或更新版本
- macOS 14 或更新版本
- 不含第三方執行階段相依套件
- Foundation · Core Graphics

## 安裝

透過 Xcode 的 Add Package Dependencies 加入儲存庫，或在 `Package.swift` 中宣告：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

```swift
import KLReadingOrder
```

## 快速開始

1. 確認同頁邊界框使用一致正規化座標：x 向右、y 向上。
2. 由 OCR 辨識結果建立候選並保留穩定 ID 與來源順序。
3. 明確指定橫排／直排，或使用 `.unknown` 逐頁自動判斷。
4. 以 `candidateIDs` 找回整合端 App 的中繼資料。文字之間不需要空格時，可傳入空的 `memberSeparator`。

```swift
let candidates = observations.enumerated().map { index, observation in
    ReadingOrderCandidate(
        id: index,
        text: observation.topCandidates(1).first?.string ?? "",
        confidence: Double(observation.confidence),
        boundingBox: observation.boundingBox,
        pageIndex: 0,
        sourceOrder: index
    )
}

let lines = ReadingOrderEngine().reconstruct(candidates: candidates)

for line in lines {
    print(line.text)
}
```

## 行為保證

- `ReadingDirection`：`.horizontal`、`.vertical` 或逐頁推斷的 `.unknown`。
- `ReadingOrderCandidate`：呼叫方 ID、文字、信心值、邊界框、頁碼與來源順序。
- `ReadingOrderLine`：有序候選 ID、合併框、串接文字、平均信心值、頁碼與已解析方向。
- `ReadingOrderPolicy`：公開所有幾何閾值及產品預設值。
- `ReadingOrderEngine.reconstruct`：同步執行過濾、分頁、方向判斷、分群、排序與彙總，不進行 I/O。

## 職責邊界

不執行 OCR、校正傾斜、旋轉、透視修正、信心值篩選、語言辨識、表格擷取或文件語意。每頁所有框必須使用同一正規化座標系。

## 文件

- [快速開始](GettingStarted.md)
- [API 參考](API.md)
- [架構](Architecture.md)
- [遷移](Migration.md)
- [示範 App](../../Examples/Documentation/zh-Hant/README.md)
- [參與貢獻](CONTRIBUTING.md)
- [安全政策](SECURITY.md)
- [行為準則](CODE_OF_CONDUCT.md)
- [變更記錄](CHANGELOG.md)

## 狀態

此 API 目前仍在 1.0 之前。功能已用於 wondays 的真實產品情境，但在宣告穩定前，小版本仍可能調整命名或策略介面。

## 授權

MIT. [LICENSE](../../LICENSE)
