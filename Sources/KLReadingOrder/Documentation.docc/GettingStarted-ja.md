# はじめに

OCR の結果を候補へ変換し、ページごとに読み順を再構成します。返された候補 ID から、アプリ側の元データも参照できます。

## 座標系を統一する

同じページの矩形は、共通の正規化座標系にそろえてください。エンジンは x が右向き、y が上向きに増えるものとして計算します。ピクセル座標や左上原点の座標は、候補を作る前にアプリ側で変換します。

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

パッケージは矩形を検証、補正しません。ID から個々の認識結果を引き直す場合は、候補ごとに一意の ID を割り当ててください。

## 読み順を再構成する

ページの書字方向が分からない場合は自動判定を使います。信頼できるメタデータがある場合は、横書きまたは縦書きを明示できます。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自動判定は、縦長の矩形が占める割合をページごとに調べます。文字列や言語は判定に使いません。``ReadingOrderPolicy/automaticVerticalRatio`` に達しないページは横書きとして処理します。

## 結果を利用する

ページは `pageIndex` の昇順です。横書きは上から下、行内は左から右に並びます。縦書きは右の列から左へ進み、列内は上から下に並びます。各結果には、メンバー矩形の結合範囲と信頼度の算術平均も含まれます。

空白だけの候補は除外されます。`memberSeparator` は、前後の空白を除いた各文字列の間にそのまま挿入されます。空白が不要なら空文字列を指定します。

## 処理範囲を理解する

KLReadingOrder は同期的に動作し、I/O は行いません。傾き補正、向きの検出、座標の正規化、低信頼度候補の除外、表の解析、文章の意味理解は対象外です。不正な矩形、重複 ID、非有限の信頼度、不正なポリシー値も拒否しないため、順序が不定になったり非有限値が出力されたりする場合があります。
