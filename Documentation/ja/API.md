# KLReadingOrder API リファレンス

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder は、文字列、信頼度、正規化した矩形、ページ番号、元の並び順を受け取り、読み順にまとめた行を返す Swift パッケージです。OCR 自体や文章の意味解析は行わず、認識結果を読みやすい順番へ並べる処理だけを担当します。

## 公開 API

- `ReadingDirection`：横書きの `.horizontal`、縦書きの `.vertical`、ページごとに自動判定する `.unknown` を指定できます。
- `ReadingOrderCandidate`：アプリ側の ID、文字列、信頼度、矩形、ページ番号、元の並び順を保持します。
- `ReadingOrderLine`：読み順に並べた候補 ID、結合した矩形と文字列、平均信頼度、ページ番号、確定した書字方向を返します。
- `ReadingOrderPolicy`：行と列の判定に使うしきい値を公開しており、用途に合わせて調整できます。
- `ReadingOrderEngine.reconstruct`：空の候補の除外、ページ分割、方向判定、行または列への分類、並べ替え、結果の集約を同期的に行います。通信やファイル操作は行いません。

## 完全なシグネチャ

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

## 動作保証

- 横書きは上から下、同じ行では左から右
- 縦書きは右の列から左へ、同じ列では上から下
- ページごとに横書きか縦書きかを自動判定
- 文字の大きさに合わせて行と列の判定幅を調整
- 複数ページ、結合後の矩形、平均信頼度、元の候補 ID に対応

## 責務の境界

このパッケージは、OCR、傾きや回転の補正、遠近補正、信頼度による除外、言語判定、表の抽出、文章の意味解析を行いません。同じページに含まれる矩形は、必ず同じ正規化座標系で渡してください。

## 詳細な動作仕様

- `ReadingDirection.horizontal` は行を上から下、行内を左から右に並べます。`vertical` は列を右から左、列内を上から下に並べます。`unknown` はページごとに判定され、出力には残りません。
- `ReadingOrderCandidate` の 6 つのプロパティはそのまま保存されます。イニシャライザは ID、文字列、信頼度、矩形、ページ番号、元の順序を検証しません。空白だけの文字列は再構成前に除外されます。
- `ReadingOrderLine` の公開イニシャライザは値を保存するだけで、矩形や信頼度を集約しません。エンジンが作る結果では、メンバー順の `candidateIDs`、前後の空白を除いて連結した文字列、矩形の逐次結合、信頼度の算術平均が設定されます。
- `ReadingOrderPolicy` の 13 プロパティは、縦長判定、自動縦書き比率、横書きの行許容差、候補間比較、ベースライン重複、縦書きの列許容差、重複率の分母下限を制御します。値の範囲、大小関係、符号、有限性は検証しません。
- `verticalAspectRatio` は縦長判定に使う高さ対幅の倍率です。`automaticVerticalRatio` は自動的に縦書きを選ぶ最小比率で、境界値を含みます。
- `defaultHorizontalHeight` は正の高さがない場合の代替値です。`minimumHorizontalTolerance` と `maximumHorizontalTolerance` はページ単位の行許容差を制限し、`horizontalToleranceScale` は正の高さの中央値へ掛けます。
- `minimumPairTolerance` は行の基準位置と候補を比べる際の下限ですが、最終値はページ単位の許容差でも制限されます。`pairToleranceScale` は基準の高さと候補の高さのうち小さい方へ掛けます。`minimumBaselineOverlap` は中心距離の代わりに行へ追加できる最小の縦方向重複率で、境界値を含みます。
- `defaultVerticalWidth` は正の幅がない場合の代替値です。`minimumVerticalTolerance` と `maximumVerticalTolerance` は列許容差を制限し、`verticalToleranceScale` は正の幅の中央値へ掛けます。
- `minimumOverlapReference` はベースライン重複率を計算するときの分母の下限です。
- `ReadingOrderEngine.policy` は初期化時に保存される不変のポリシーです。`reconstruct` は同期的に動作し、I/O を行わず、エラーを投げません。空配列と空白だけの入力は空配列を返します。
- 座標は正規化し、x を右向き、y を上向きに増加させる必要があります。範囲の検証、原点の変換、回転補正、`CGRect` の標準化は行いません。
- ページ番号は負数でも非連続でも構いません。出力は数値の昇順です。
- 自動判定では `height > width * verticalAspectRatio` を満たす候補を数えます。その割合が `automaticVerticalRatio` 以上なら縦書き、それ以外は横書きです。
- 横書きの許容差は、正の高さだけを使った中央値から求めます。中心距離または基準値以上のベースライン重複によって行へ追加されます。縦書きは正の幅の中央値から許容差を求め、最も近い既存列が範囲内なら追加します。
- `sourceOrder` は、横書きで `minX` が完全に等しい場合、または縦書きで `minY` が完全に等しい場合にだけ使います。すべての比較値が同じ場合、それ以上の安定順序は保証しません。
- 重複 ID は除去しません。`memberSeparator` は文字列間へそのまま挿入します。信頼度は制限せず、矩形は `CGRect.union(_:)` で順番に結合します。
- 不正または非有限の矩形、信頼度、ポリシー値は拒否しません。順序が不定になったり、非有限値が出力されたりする場合があります。公開されている値型はすべて `Sendable` です。
