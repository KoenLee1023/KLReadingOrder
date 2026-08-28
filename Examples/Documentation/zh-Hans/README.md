# KLReadingOrder 演示应用

> <span lang="zh-CN">[English](../en/README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder 接收文本、置信度、归一化边界框、页面身份和来源顺序，返回有序行，同时保留调用方候选 ID。它不执行 OCR，也不解释文档语义，只解决识别与语义提取之间的几何步骤。

## Reading Flow

在左下角原点的归一化画布上展示六个合成候选，并列出默认引擎重建的横排行。这个 Demo 展示乱序输入、行聚类、行内从左到右、自定义分隔符，以及归一化坐标到 SwiftUI 左上角原点画布的转换。它只使用一页，也不显示候选 ID。

## Layout Comparator

对同一组四个候选分别强制使用横排和竖排。两个结果区域都会显示合成文字和成员 ID。这个 Demo 不运行自动方向判断，也不提供策略参数控制。

两个演示 App 都有独立的 `Package.swift` 和应用入口，仅依赖仓库根目录中的软件包，不会导入 wondays 的代码或资源。

不执行 OCR、纠偏、旋转、透视校正、置信度过滤、语言识别、表格提取或文档语义。每页所有框必须使用同一归一化坐标系。
