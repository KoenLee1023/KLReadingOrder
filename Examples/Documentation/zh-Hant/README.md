# KLReadingOrder 示範 App

> <span lang="zh-TW">[English](../en/README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLReadingOrder 接收文字、信心值、正規化邊界框、頁面識別與來源順序，回傳有序行，同時保留呼叫方候選 ID。它不執行 OCR，也不解讀文件語意，只處理辨識與語意擷取之間的幾何步驟。

## Reading Flow

在以左下角為原點的正規化畫布上顯示六個合成候選項目，並列出預設引擎重建的橫排行。這個 Demo 呈現亂序輸入、行分群、行內由左至右、自訂分隔字串，以及正規化座標到 SwiftUI 左上角原點畫布的轉換。它只使用一頁，也不顯示候選 ID。

## Layout Comparator

對同一組四個候選項目分別強制採用橫排與直排。兩個結果區域都會顯示合成文字與成員 ID。這個 Demo 不執行自動方向判斷，也不提供策略參數控制。

兩個示範 App 都有獨立的 `Package.swift` 與 App 進入點，只依賴儲存庫根目錄中的套件，不會匯入 wondays 的程式碼或資源。

不執行 OCR、校正傾斜、旋轉、透視修正、信心值篩選、語言辨識、表格擷取或文件語意。每頁所有框必須使用同一正規化座標系。
