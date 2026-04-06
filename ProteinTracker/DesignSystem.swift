//
//  DesignSystem.swift
//  ProteinTracker
//
//  Centralized design tokens: spacing, typography, shadows,
//  spring animations, and haptic-feedback policy.
//
//  Reference these tokens instead of hard-coding values in views.
//  Colors remain in Color+Extensions.swift (asset catalog based).
//
//  Created by drx on 2026/04/06.
//

import SwiftUI

// MARK: - Namespace

/// Top-level design system namespace.
/// Access tokens via `DS.Spacing`, `DS.Typography`, etc.
enum DS {

    // MARK: - Spacing (4pt base grid)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let s:   CGFloat = 12
        static let m:   CGFloat = 16
        static let l:   CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }


    // MARK: - Corner Radius

    enum Radius {
        static let card: CGFloat = 28
        static let row: CGFloat = 12
        static let pill: CGFloat = .infinity   // Capsule
    }

    // MARK: - Shadows

    enum Shadow {
        static let cardAmbient = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let cardKey     = ShadowStyle(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }

    // MARK: - Animations

    enum Animation {
        /// Light / crisp — small buttons, state toggles, quick feedback
        static let snappy = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)

        /// Smooth / fluid — page transitions, list insertions
        static let fluid = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.9)

        /// Heavy / physical — large panels, celebration
        static let heavy = SwiftUI.Animation.spring(response: 0.45, dampingFraction: 0.75)
    }

    // MARK: - Haptics
    //
    // Semantic mapping:
    //
    // ┌──────────────────────────────────┬──────────────────────────────────────────┐
    // │ Semantic context                 │ Haptic call                              │
    // ├──────────────────────────────────┼──────────────────────────────────────────┤
    // │ Entry saved / plan completed      │ .success  (notification)                 │
    // │ Favorite added                    │ .success  (notification)                 │
    // │ UI expand / collapse toggle       │ .medium   (impact)                       │
    // │ FAB / primary action tap          │ .medium   (impact)                       │
    // │ Revert / undo action              │ .medium   (impact)                       │
    // │ Typing digit in big input         │ .light    (impact, intensity 0.5)        │
    // │ Chart bar selection               │ .light    (impact)                       │
    // │ Chart bar goal reached            │ .success  (notification)                 │
    // │ Easter-egg triple tap             │ .success  (notification)                 │
    // └──────────────────────────────────┴──────────────────────────────────────────┘
    //
    // Principles:
    // - Same semantic → same haptic everywhere.
    // - Stay restrained — fire only on explicit user actions.

    enum Haptics {
        /// Data saved / entry added / plan completed / favorite added
        static func success() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        /// UI toggle, FAB tap, revert action — medium weight feedback
        static func medium() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        /// Subtle keystroke / chart selection — light feedback
        static func light(intensity: CGFloat = 1.0) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: intensity)
        }
    }
}

// MARK: - Shadow Value Type

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View + Shadow helpers

extension View {
    func shadow(style s: ShadowStyle) -> some View {
        self.shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
    }

    /// Dual-layer card shadow (ambient + key).
    func cardShadow() -> some View {
        self
            .shadow(style: DS.Shadow.cardAmbient)
            .shadow(style: DS.Shadow.cardKey)
    }
}
