# ProteinTracker

A native iOS app for tracking daily protein intake — built with SwiftUI, SwiftData, and modern Swift concurrency.

<!-- TODO: Replace with your own screenshots -->
<!-- <p align="center">
  <img src="docs/screenshot_today.png" width="200" />
  <img src="docs/screenshot_stats.png" width="200" />
  <img src="docs/screenshot_search.png" width="200" />
</p> -->

## Tech Stack

Swift / SwiftUI / MVVM / SwiftData / Swift Testing / Charts / Async-Await / Localization (ja/en)

## Architecture

```
SwiftData Store
  ↕ @Query (read)  ·  ProteinDataStore (write / aggregate)
View layer
  ↕ @State · @Observable
TodayViewModel ── FoodSearchService protocol ── NetworkService
                                               └─ MockFoodSearchService (test)
```

- **ProteinDataStore** — `enum` with static methods. Pure functions for aggregation, progress calculation, and filtering take plain arrays, keeping them testable without a live SwiftData stack.
- **TodayViewModel** — `@Observable` + `@MainActor`. Depends on `FoodSearchService` protocol, injected via initializer with a default argument.
- **Views** — Driven by `@Query`; no business logic in View bodies.

## Testing

15 unit tests built with **Swift Testing** (`@Suite` / `@Test` / `#expect`).

| Target | Coverage |
|--------|----------|
| `ProteinDataStore` (10) | Day-scoped aggregation, progress ratio & capping, nil-profile edge case, overflow, entry filtering/sorting, weekly data structure |
| `TodayViewModel` (5) | Search success / failure / blank input / rapid-fire calls / alert dismiss — all via `MockFoodSearchService` |

## Key Implementation Details

- **SwiftData migration** — Replaced JSON/FileManager persistence with `@Model` + `ModelContainer`. Views use `@Query` for declarative reads; all writes go through `ProteinDataStore`.
- **Protocol-based DI** — `FoodSearchService` protocol (`Sendable`) lets production and test targets swap implementations. ViewModel tests run with zero network dependency.
- **Networking** — `URLComponents`-based request building against Open Food Facts API. `async`-`await` with typed error handling (`NetworkError` enum covering HTTP status, decoding failure, connectivity).
- **Interactive chart** — Weekly `BarMark` chart with `ChartProxy` + `SpatialTapGesture` for day selection. Goal line overlay, haptic feedback on tap.
- **Accessibility** — VoiceOver support across all screens: `accessibilityLabel` / `accessibilityValue` on progress bars, chart, and input forms; `.accessibilityElement(children: .combine)` on composite cards; decorative elements hidden.
- **Localization** — Full Japanese / English translation via `.xcstrings`.

---

# ProteinTracker（日本語）

日々のタンパク質摂取量を記録・可視化する iOS アプリ。

## 技術スタック

Swift / SwiftUI / MVVM / SwiftData / Swift Testing / Charts / Async-Await / Localization (ja/en)

## アーキテクチャ

- **ProteinDataStore** — `enum` + `static func` による純粋関数設計。日別集計・進捗計算・フィルタリング等のビジネスロジックを集約し、View とデータ操作の責務を分離。
- **TodayViewModel** — `@Observable` + `@MainActor`。`FoodSearchService` プロトコル経由で API 層に依存し、Mock 差し替えによるネットワーク非依存テストを実現。
- **View 層** — `@Query` による宣言的データ取得。View body にビジネスロジックを持たない。

## テスト

Swift Testing で 15 件のユニットテストを構築。

- **ProteinDataStore（10 件）**：日別集計・進捗計算・カテゴリ別フィルタリング等の純粋関数テスト。境界値（目標ゼロ・目標超過）、エッジケース（未設定・空配列）をカバー。
- **TodayViewModel（5 件）**：Mock 注入による検索成功 / 失敗 / 空入力 / 連続実行 / アラート解除のテスト。

## 主な実装

- **SwiftData 移行** — JSON ファイルベースの永続化から SwiftData（`@Model` / `ModelContainer`）へ移行。View 層は `@Query` で宣言的にデータ取得し、書き込みは `ProteinDataStore` に集約。
- **プロトコルベース DI** — `FoodSearchService` プロトコル（`Sendable`）で本番 / Mock を切替可能に設計。ViewModel テストをネットワーク非依存で実現。
- **ネットワーク層** — `URLComponents` による安全なリクエスト構築（Open Food Facts API）。`async`-`await` による非同期通信、HTTP ステータス / デコード失敗を含む型付きエラーハンドリング。
- **インタラクティブチャート** — SwiftUI Charts の `BarMark` + `ChartProxy` + `SpatialTapGesture` で特定日タップ時に当日の記録を展開表示。目標ラインと触覚フィードバック付き。
- **VoiceOver 対応** — 進捗バー・チャート・入力フォーム等に `accessibilityLabel` / `accessibilityValue` を付与。複合カードは `.accessibilityElement(children: .combine)` で統合、装飾要素は非表示化。
- **ローカライズ** — `.xcstrings` で日英完全翻訳。
