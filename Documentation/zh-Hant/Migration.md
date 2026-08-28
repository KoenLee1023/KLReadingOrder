# KLReadingOrder 遷移

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

先準備涵蓋多種字型、尺寸、語言、橫排、直排與多頁內容的測試資料，不要只配合單一樣本調整。統一座標系統後，在轉接層建立候選項目，並比較舊實作與新實作的文字、候選 ID、矩形和方向。OCR 與語意解析應維持不變。套件測試及整合端 App 的回歸測試都通過後，再移除舊排序規則。

## 檢查清單

- [ ] 確認同頁邊界框使用一致正規化座標：x 向右、y 向上。
- [ ] 由 OCR 辨識結果建立候選並保留穩定 ID 與來源順序。
- [ ] 明確指定橫排／直排，或使用 `.unknown` 逐頁自動判斷。
- [ ] 以 `candidateIDs` 找回整合端 App 的中繼資料。文字之間不需要空格時，可傳入空的 `memberSeparator`。
- [ ] 執行 KLReadingOrder 套件測試
- [ ] 執行整合端 App 的回歸測試
- [ ] 更新 API 參考與變更記錄
