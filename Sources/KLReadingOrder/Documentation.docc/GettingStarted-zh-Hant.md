# 快速開始

將 OCR 結果轉為候選項目，依頁面重建閱讀順序，再透過候選 ID 取回 App 內的原始資料。

## 統一座標系統

同一頁面的矩形必須使用相同的正規化座標系統。引擎按照 x 向右增加、y 向上增加的方向計算。像素座標或以左上角為原點的座標，必須先由 App 轉換。

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

套件不會檢查或修正矩形。若 App 需要透過 ID 取回單一來源，候選 ID 應保持唯一。

## 重建閱讀順序

沒有可靠的頁面方向資訊時可使用自動判斷。有可信的中繼資料時，可明確指定橫排或直排。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自動判斷會逐頁計算縱向外形矩形的比例，不會讀取文字或辨識語言。未達 ``ReadingOrderPolicy/automaticVerticalRatio`` 的頁面會按橫排處理。

## 使用結果

頁面依 `pageIndex` 遞增輸出。橫排行由上而下，行內由左至右。直排列由右至左，列內由上而下。每筆結果也包含成員矩形的聯集與信心值的算術平均。

只有空白的候選項目會被捨棄。`memberSeparator` 會原樣插入修剪後的成員文字之間。不需要空格時請傳入空字串。

## 明確能力邊界

KLReadingOrder 會同步執行，不進行 I/O。它不負責校正傾斜、偵測方向、正規化座標、排除低信心結果、解析表格或理解文件語意。無效矩形、重複 ID、非有限信心值與無效策略值不會被拒絕，可能造成順序不明確或輸出非有限數值。
