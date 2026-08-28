# KLReadingOrder 迁移

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

先固定多字体、多尺寸、多语言、横排、竖排和多页测试数据，不要只拟合一张票据。统一坐标系后用适配层构造候选，比较旧结果的行文本、候选 ID、框和方向。保持 OCR 与语义解析不变。通过包测试和接入应用的回归测试后再移除旧排序规则。

## 检查清单

- [ ] 确保同页边界框使用一致的归一化坐标：x 向右、y 向上。
- [ ] 从 OCR 识别结果构造候选并保留稳定 ID 与来源顺序。
- [ ] 明确传入横排/竖排，或用 `.unknown` 逐页自动判断。
- [ ] 用 `candidateIDs` 找回接入应用元数据。对无空格文字可传空 `memberSeparator`。
- [ ] 运行 KLReadingOrder 包测试
- [ ] 运行接入应用的回归测试
- [ ] 更新 API 参考与变更记录
