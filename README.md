# Protein Tracker

A native iOS application designed to help users track and visualize daily protein intake, built with **SwiftUI** and **MVVM** architecture.

[![Behance](https://img.shields.io/badge/Behance-View%20Design%20System-0056FF?style=for-the-badge&logo=behance&logoColor=white)]([YOUR_BEHANCE_LINK_HERE])

### 📱 App Demo

[![Watch the video](https://img.youtube.com/vi/YOUR_VIDEO_ID/maxresdefault.jpg)](https://www.youtube.com/watch?v=z1TyhV3Tkyc)

> Click the image above to watch the full demo on YouTube.


<p align="center">
  <img src="[YOUR_GIF_LINK_HERE]" width="300" alt="App Demo">
</p>

---

## 🚀 Key Features & Tech Highlights

Based on modern iOS development standards (iOS 17+).

### 📊 Interactive Visualization (SwiftUI Charts)
- Implemented a custom dashboard using **SwiftUI Charts** and `ChartProxy`.
- **Challenge:** Solved complex `Date` type precision issues (nanosecond mismatch) to ensure smooth, interactive touch feedback.
- **Solution:** Utilized `Calendar` for day-based comparison and optimized `@State` updates.

### ⚡️ Modern Concurrency (Async/Await)
- Engineered non-blocking data fetching using **Async/Await** and `Task`.
- Integrated **Open Food Facts API** for seamless product scanning and data retrieval.

### 🎨 Design-to-Code (Figma & ViewBuilder)
- Bridged the gap between design and engineering.
- Created a comprehensive Design System in **Figma** and translated it into pixel-perfect, reusable SwiftUI components using `@ViewBuilder`.

---

## 🛠 Tech Stack

- **Language:** Swift 5
- **UI Framework:** SwiftUI
- **Architecture:** MVVM
- **Data Persistence:** Codable (JSON) / FileManager
- **Networking:** URLSession, Async/Await
- **Design Tool:** Figma

---

## 🇯🇵 日本語 (Japanese)

**概要:**
日々のタンパク質摂取量を記録・可視化し、フィットネス目標の達成を支援するネイティブiOSアプリです。

**主な技術的取り組み:**

* **高度なデータ可視化:**
    `SwiftUI Charts`と`ChartProxy`を活用し、タップ操作で詳細を表示するインタラクティブなグラフを実装。Date型のナノ秒単位の比較問題を解決し、スムーズなUXを実現しました。

* **モダンな非同期処理:**
    `async/await`と`Task`を用い、Open Food Facts APIからのデータ取得を非ブロッキングで実装。

* **デザインと実装の統合:**
    Figmaでデザインシステムを構築し、それを`@ViewBuilder`等を活用してSwiftUIコンポーネントとして忠実に再現しました。

---

## 🇨🇳 中文 (Chinese)

**项目简介:**
一款使用 SwiftUI 和 MVVM 架构构建的 iOS 应用，用于追踪和可视化每日蛋白质摄入量。

**核心亮点:**
* **交互式图表:** 使用 SwiftUI Charts 实现数据可视化，解决了 Date 类型精度问题，实现了流畅的点击交互。
* **现代并发编程:** 使用 Async/Await 实现无阻塞网络请求 (Open Food Facts API)。
* **设计工程化:** 将 Figma 设计系统转化为可复用的 SwiftUI 组件 (`@ViewBuilder`)。
