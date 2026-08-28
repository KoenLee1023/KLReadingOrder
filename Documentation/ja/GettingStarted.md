# KLReadingOrder: はじめに

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

Xcode の「Add Package Dependencies」からリポジトリを追加するか、`Package.swift` に次のように記述します。

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

## 組み込み

### 1. 同じページの矩形を、x は右方向、y は上方向へ増える共通の正規化座標へそろえます。

KLReadingOrder は、文字列、信頼度、正規化した矩形、ページ番号、元の並び順を受け取り、読み順にまとめた行を返す Swift パッケージです。OCR 自体や文章の意味解析は行わず、認識結果を読みやすい順番へ並べる処理だけを担当します。

### 2. OCR の認識結果から、安定した ID と元の並び順を持つ候補を作成します。

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

パッケージは矩形を検証せず、ID の一意性も要求しません。ID から個々の元データを引き直す場合は、アプリ側で一意性を保証してください。

### 3. 横書きまたは縦書きを指定するか、`.unknown` を使ってページごとに自動判定します。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自動判定は縦長の矩形が占める割合だけを調べます。文字列や言語は判定に使いません。

### 4. `candidateIDs` を使ってアプリ側の元データを参照します。文字間に空白を入れない場合は、空の `memberSeparator` を指定します。

空白だけの候補は除外されます。結果はページ番号の昇順です。矩形の結合範囲や信頼度の平均に対する妥当性補正は行いません。

## チェックリスト

- [ ] 横書きは上から下、同じ行では左から右
- [ ] 縦書きは右の列から左へ、同じ列では上から下
- [ ] ページごとに横書きか縦書きかを自動判定
- [ ] 文字の大きさに合わせて行と列の判定幅を調整
- [ ] 複数ページ、結合後の矩形、平均信頼度、元の候補 ID に対応

このパッケージは、OCR、傾きや回転の補正、遠近補正、信頼度による除外、言語判定、表の抽出、文章の意味解析を行いません。同じページに含まれる矩形は、必ず同じ正規化座標系で渡してください。

不正な矩形、重複 ID、非有限の信頼度、不正なポリシー値も拒否しないため、順序が不定になったり非有限値が出力されたりする場合があります。
