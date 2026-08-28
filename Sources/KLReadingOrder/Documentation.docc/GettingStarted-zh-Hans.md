# 快速开始

把 OCR 结果转换为候选项，按页重建阅读顺序，再通过候选 ID 找回应用中的原始数据。

## 统一坐标系

同一页的矩形必须使用同一个归一化坐标系。引擎按 x 向右增大、y 向上增大来计算。像素坐标或左上角原点坐标需要先由应用转换。

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

这个包不会检查或修复矩形。如果应用要通过 ID 找回单个来源，候选 ID 应保持唯一。

## 重建阅读顺序

没有可靠的页面方向信息时使用自动判断。有可信元数据时可以明确指定横排或竖排。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自动判断会逐页统计纵向外形的矩形，不读取文字，也不识别语言。未达到 ``ReadingOrderPolicy/automaticVerticalRatio`` 的页面按横排处理。

## 使用结果

页面按 `pageIndex` 升序输出。横排行从上到下，行内从左到右。竖排列从右到左，列内从上到下。每条结果还包含成员矩形的并集和置信度算术平均值。

纯空白候选会被丢弃。`memberSeparator` 会原样插入修剪后的成员文字之间。无需空格时传入空字符串。

## 明确能力边界

KLReadingOrder 同步执行，不进行 I/O。它不负责纠偏、方向检测、坐标归一化、低置信度过滤、表格解析或文档语义理解。无效矩形、重复 ID、非有限置信度和无效策略值不会被拒绝，可能造成顺序不确定或结果出现非有限数值。
