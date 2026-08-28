# KLReadingOrder

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

OCR の認識結果が順不同でも、座標情報を使って人が読む順番に並べ直します。

KLReadingOrder は、文字列、信頼度、正規化した矩形、ページ番号、元の並び順を受け取り、読み順にまとめた行を返す Swift パッケージです。OCR 自体や文章の意味解析は行わず、認識結果を読みやすい順番へ並べる処理だけを担当します。

## 概要

- 横書きは上から下、同じ行では左から右
- 縦書きは右の列から左へ、同じ列では上から下
- ページごとに横書きか縦書きかを自動判定
- 文字の大きさに合わせて行と列の判定幅を調整
- 複数ページ、結合後の矩形、平均信頼度、元の候補 ID に対応

## 要件

- Swift 6.0 以降
- iOS 17 以降
- macOS 14 以降
- サードパーティの実行時依存なし
- Foundation · Core Graphics

## 導入

Xcode の「Add Package Dependencies」からリポジトリを追加するか、`Package.swift` に次のように記述します。

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

## はじめに

1. 同じページの矩形を、x は右方向、y は上方向へ増える共通の正規化座標へそろえます。
2. OCR の認識結果から、安定した ID と元の並び順を持つ候補を作成します。
3. 横書きまたは縦書きを指定するか、`.unknown` を使ってページごとに自動判定します。
4. `candidateIDs` を使ってアプリ側の元データを参照します。文字間に空白を入れない場合は、空の `memberSeparator` を指定します。

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

## 動作保証

- `ReadingDirection`：横書きの `.horizontal`、縦書きの `.vertical`、ページごとに自動判定する `.unknown` を指定できます。
- `ReadingOrderCandidate`：アプリ側の ID、文字列、信頼度、矩形、ページ番号、元の並び順を保持します。
- `ReadingOrderLine`：読み順に並べた候補 ID、結合した矩形と文字列、平均信頼度、ページ番号、確定した書字方向を返します。
- `ReadingOrderPolicy`：行と列の判定に使うしきい値を公開しており、用途に合わせて調整できます。
- `ReadingOrderEngine.reconstruct`：空の候補の除外、ページ分割、方向判定、行または列への分類、並べ替え、結果の集約を同期的に行います。通信やファイル操作は行いません。

## 責務の境界

このパッケージは、OCR、傾きや回転の補正、遠近補正、信頼度による除外、言語判定、表の抽出、文章の意味解析を行いません。同じページに含まれる矩形は、必ず同じ正規化座標系で渡してください。

## ドキュメント

- [はじめに](GettingStarted.md)
- [API リファレンス](API.md)
- [アーキテクチャ](Architecture.md)
- [移行](Migration.md)
- [デモアプリ](../../Examples/Documentation/ja/README.md)
- [コントリビューション](CONTRIBUTING.md)
- [セキュリティポリシー](SECURITY.md)
- [行動規範](CODE_OF_CONDUCT.md)
- [変更履歴](CHANGELOG.md)

## ステータス

現在の API は 1.0 未満です。wondays で実際に使用していますが、安定版にするまでは、マイナーアップデートで名前や設定方法を見直すことがあります。

## ライセンス

MIT. [LICENSE](../../LICENSE)
