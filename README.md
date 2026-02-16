# HWHL

```
                  .
                 .o.
                .oOo.
               .oOOOo.
              .oOOOOOo.
             .oOOOOOOOo.
            .oOOOOOOOOOo.
           .oOOOOOOOOOOOo.
          .oOOOOOOOOOOOOOo.
         .oOOOOOOOOOOOOOOOo.
        .oOOOOOOOOOOOOOOOOOo.
       .oOOOOOOOOOOOOOOOOOOOo.
      .oOOOOOOOOOOOOOOOOOOOOOo.
       'oOOOOOOOOOOOOOOOOOOOo'
        'oOOOOOOOOOOOOOOOOOo'
          'oOOOOOOOOOOOOOo'
            'oOOOOOOOOOo'
              'oOOOOOo'
                'oOo'
                 'o'
                  '
```

**Health & Wellness Hormone Lifecycle**

A cycle-aware iOS companion that reads your body's rhythm and meets you where you are — with predictions, gentle alerts, and phase-specific wellness tips.

---

## What It Does

- **Reads HealthKit** menstrual flow data to learn your cycle
- **Predicts** your next period, ovulation window, and PMS onset
- **Notifies** you before PMS and period start so you're never caught off guard
- **Serves daily tips** tailored to your current phase — nutrition, movement, mindset, comfort

## Screens

| Dashboard | Calendar | Tips | Settings |
|-----------|----------|------|----------|
| Current phase, countdowns, tip of the day | Visual cycle timeline with phase context | Browse all tips by phase | HealthKit, notifications, manual entry |

## Architecture

```
HWHL/
├── App/            Entry point + tab navigation
├── Models/         CycleRecord · CyclePhase · CyclePrediction · TipEntry
├── Services/       HealthKitService · PredictionEngine · NotificationService · TipsService
├── ViewModels/     DashboardViewModel
├── Views/          Dashboard · Calendar · Tips · Settings
└── Resources/      Assets
```

## Tech

- SwiftUI + SwiftData
- HealthKit (read-only)
- UserNotifications (local)
- iOS 17+

## Data Strategy

1. **Apple HealthKit** — primary source, syncs from Clue or native Health app
2. **Manual entry** — fallback for cycle length + last period date
3. **CSV import** — planned for Clue data export

## Getting Started

1. Clone the repo
2. Open `HWHL.xcodeproj` in Xcode
3. Set your Development Team in Signing & Capabilities
4. Build & run on a device (HealthKit requires a real device)

---

*Take care of yourself. You deserve it.*
