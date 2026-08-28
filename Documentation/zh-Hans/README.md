# KLReadingOrder

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

用确定且可检查的几何规则，从乱序 OCR 识别结果中重建人类阅读顺序。

KLReadingOrder 接收文本、置信度、归一化边界框、页面身份和来源顺序，返回有序行，同时保留调用方候选 ID。它不执行 OCR，也不解释文档语义，只解决识别与语义提取之间的几何步骤。

## 概览

- 横排从上到下、行内从左到右
- 竖排按列从右到左、列内从上到下
- 每页独立自动判断方向
- 基于中位字符几何的自适应容差
- 多页排序、合并边界、平均置信度和来源 ID

## 要求

- Swift 6.0 或更高版本
- iOS 17 或更高版本
- macOS 14 或更高版本
- 无第三方运行时依赖
- Foundation · Core Graphics

## 安装

通过 Xcode 的 Add Package Dependencies 添加仓库，或在 `Package.swift` 中声明：

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

## 快速开始

1. 确保同页边界框使用一致的归一化坐标：x 向右、y 向上。
2. 从 OCR 识别结果构造候选并保留稳定 ID 与来源顺序。
3. 明确传入横排/竖排，或用 `.unknown` 逐页自动判断。
4. 用 `candidateIDs` 找回接入应用元数据。对无空格文字可传空 `memberSeparator`。

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

## 行为保证

- `ReadingDirection`：`.horizontal`、`.vertical` 或逐页推断的 `.unknown`。
- `ReadingOrderCandidate`：调用方 ID、文本、置信度、边界框、页码和来源顺序。
- `ReadingOrderLine`：有序候选 ID、合并框、连接文本、平均置信度、页码和已解析方向。
- `ReadingOrderPolicy`：公开所有几何阈值及生产默认值。
- `ReadingOrderEngine.reconstruct`：过滤、分页、判断方向、聚类、排序并聚合。同步、无 I/O。

## 职责边界

不执行 OCR、纠偏、旋转、透视校正、置信度过滤、语言识别、表格提取或文档语义。每页所有框必须使用同一归一化坐标系。

## 文档

- [快速开始](GettingStarted.md)
- [API 参考](API.md)
- [架构](Architecture.md)
- [迁移](Migration.md)
- [演示应用](../../Examples/Documentation/zh-Hans/README.md)
- [安全策略](SECURITY.md)
- [行为准则](CODE_OF_CONDUCT.md)
- [变更记录](CHANGELOG.md)

## 状态

该 API 目前处于 1.0 之前。功能已在 wondays 的真实产品场景中使用，但在声明稳定前，小版本仍可能调整命名或策略接口。

## 许可证

MIT. [LICENSE](../../LICENSE)
