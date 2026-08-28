# KLReadingOrder: 快速开始

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

通过 Xcode 的 Add Package Dependencies 添加仓库，或在 `Package.swift` 中声明：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLReadingOrder.git",
        from: "0.1.0"
    )
]
```

## 集成

### 1. 确保同页边界框使用一致的归一化坐标：x 向右、y 向上。

KLReadingOrder 接收文本、置信度、归一化边界框、页面身份和来源顺序，返回有序行，同时保留调用方候选 ID。它不执行 OCR，也不解释文档语义，只解决识别与语义提取之间的几何步骤。

### 2. 从 OCR 识别结果构造候选并保留稳定 ID 与来源顺序。

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

这个包不检查矩形，也不要求 ID 唯一。如果接入应用要通过 ID 找回单个来源，应自行保证唯一性。

### 3. 明确传入横排/竖排，或用 `.unknown` 逐页自动判断。

```swift
let lines = ReadingOrderEngine().reconstruct(
    candidates: candidates,
    preferredDirection: .unknown,
    memberSeparator: " "
)
```

自动判断只统计纵向外形矩形的比例，不读取文本，也不识别语言。

### 4. 用 `candidateIDs` 找回接入应用元数据。对无空格文字可传空 `memberSeparator`。

纯空白候选会被删除。结果按页码升序排列。矩形并集与置信度平均值不会进行有效性修复。

## 检查清单

- [ ] 横排从上到下、行内从左到右
- [ ] 竖排按列从右到左、列内从上到下
- [ ] 每页独立自动判断方向
- [ ] 基于中位字符几何的自适应容差
- [ ] 多页排序、合并边界、平均置信度和来源 ID

不执行 OCR、纠偏、旋转、透视校正、置信度过滤、语言识别、表格提取或文档语义。每页所有框必须使用同一归一化坐标系。

无效矩形、重复 ID、非有限置信度和无效策略值不会被拒绝，可能产生不确定顺序或非有限输出。
