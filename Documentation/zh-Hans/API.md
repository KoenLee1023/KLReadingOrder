# KLReadingOrder API 参考

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder 接收文本、置信度、归一化边界框、页面身份和来源顺序，返回有序行，同时保留调用方候选 ID。它不执行 OCR，也不解释文档语义，只解决识别与语义提取之间的几何步骤。

## 公开 API

- `ReadingDirection`：`.horizontal`、`.vertical` 或逐页推断的 `.unknown`。
- `ReadingOrderCandidate`：调用方 ID、文本、置信度、边界框、页码和来源顺序。
- `ReadingOrderLine`：有序候选 ID、合并框、连接文本、平均置信度、页码和已解析方向。
- `ReadingOrderPolicy`：公开所有几何阈值及生产默认值。
- `ReadingOrderEngine.reconstruct`：过滤、分页、判断方向、聚类、排序并聚合。同步、无 I/O。

## 完整签名

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

## 行为保证

- 横排从上到下、行内从左到右
- 竖排按列从右到左、列内从上到下
- 每页独立自动判断方向
- 基于中位字符几何的自适应容差
- 多页排序、合并边界、平均置信度和来源 ID

## 职责边界

不执行 OCR、纠偏、旋转、透视校正、置信度过滤、语言识别、表格提取或文档语义。每页所有框必须使用同一归一化坐标系。

## 完整行为约定

- `ReadingDirection.horizontal` 按行从上到下，行内从左到右。`vertical` 按列从右到左，列内从上到下。`unknown` 会逐页判断，结果行不会保留 `unknown`。
- `ReadingOrderCandidate` 的六个属性均原样保存。初始化器不检查 ID、文本、置信度、矩形、页码或来源顺序。纯空白文本会在重建前被删除。
- `ReadingOrderLine` 的公开初始化器只保存传入值，不计算矩形并集或置信度。引擎生成的行会按成员顺序保留 `candidateIDs`，连接修剪后的文本，顺序合并矩形，并计算置信度算术平均值。
- `ReadingOrderPolicy` 的十三个属性分别控制纵向外形判断、自动竖排比例、横排行容差、成对匹配、基线重叠、竖排列容差和重叠分母下限。初始化器使用签名中的默认值，但不会检查范围、大小关系、正负或有限性。
- `verticalAspectRatio` 是纵向外形判断的高宽乘数。`automaticVerticalRatio` 是自动采用竖排所需的最低比例，边界值计入竖排。
- `defaultHorizontalHeight` 在没有严格正高度时作为回退值。`minimumHorizontalTolerance` 和 `maximumHorizontalTolerance` 限制页面级横排容差，`horizontalToleranceScale` 乘以严格正高度的中位数。
- `minimumPairTolerance` 是行锚点与候选比较的下限，但最终仍受页面级容差限制。`pairToleranceScale` 乘以锚点高度和候选高度中的较小值。`minimumBaselineOverlap` 是可替代中心距离判断的最小纵向重叠比例，边界值有效。
- `defaultVerticalWidth` 在没有严格正宽度时作为回退值。`minimumVerticalTolerance` 和 `maximumVerticalTolerance` 限制列容差，`verticalToleranceScale` 乘以严格正宽度的中位数。
- `minimumOverlapReference` 是计算基线重叠比例时的分母下限。
- `ReadingOrderEngine.policy` 是初始化时保存的不可变策略。`reconstruct` 同步、无 I/O、不抛错。空输入和全空白输入返回空数组。
- 坐标应归一化，x 向右增大，y 向上增大。代码不会验证范围、转换原点、修正旋转或标准化 `CGRect`。
- 页码可以为负数或不连续。页面始终按数值升序处理。
- 自动判断使用 `height > width * verticalAspectRatio` 统计纵向外形候选。比例大于等于 `automaticVerticalRatio` 时按竖排处理，否则按横排处理。
- 横排容差取严格正高度的中位数并按策略限制。候选可通过中心距离或达到下限的基线重叠加入行。竖排容差以严格正宽度的中位数计算，并选择距离最近且在容差内的已有列。
- `sourceOrder` 只在横排成员 `minX` 完全相等，或竖排成员 `minY` 完全相等时参与比较。所有排序键都相等时没有额外的稳定顺序保证。
- 重复 ID 不会去重。`memberSeparator` 会原样插入成员文字之间。置信度不限制范围，矩形按 `CGRect.union(_:)` 依次合并。
- 无效或非有限矩形、置信度和策略值不会被拒绝，可能导致顺序不可靠或输出非有限数值。所有公开值类型均为 `Sendable`。
