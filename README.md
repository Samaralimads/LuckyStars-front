# Lucky Stars

An iOS app that helps couples find and plan activities to do together: browsing and filtering
activities, proposing dates (accept / decline / reschedule), pairing with a partner via an invitation
code, and a shared profile with couple statistics.

This repo contains only the iOS client. The backend API lives in the **LuckyStars-back** repo
(Vapor + MySQL).

## Tech stack

- **SwiftUI**, Swift 5, **MVVM** architecture
- `@Observable` for ViewModels (no Combine)
- **EventKit** for adding activities to the device calendar
- No external dependencies (no SPM packages, no CocoaPods) — everything is built with Apple
  frameworks

## Architecture

Each feature under `Features/` follows the same split:

```
Feature/
├── Model/         Codable structs representing the API data
├── View Model/    @Observable class: screen state + calls into Services
└── View/          declarative SwiftUI views, no business logic
```

A root-level `Services/` layer encapsulates networking (`APIClient`, then one service per resource:
`ProfileService`, `PlannedActivityService`, `ActivityService`, `CoupleService`, …) — ViewModels never
know the URL or JSON shape of a request.

## Project structure

```
LuckyStars/
├── App/                     entry point, AppState (global session/navigation)
├── Features/
│   ├── Auth/                sign up, sign in, forgot password
│   ├── Onboarding/          post-signup flow (birth date, relationship start date…)
│   ├── Pairing/             connecting with a partner (invitation code)
│   ├── Dashboard/           main screen: next date, pending proposals, invite partner
│   ├── Activities/          discovery, search, filters, activity detail
│   ├── Dates/                "My Dates" page (booked activities + favorites)
│   └── Profile/             profile, statistics, settings
├── Services/                networking layer (APIClient + one service per resource)
├── Tab Bar/                 main tab navigation
└── UI/                      shared components, modifiers, assets, custom fonts
```


## Main features

- Sign up / sign in (email + password), forgot password
- Onboarding: birth date, relationship start date, optional partner pairing
- Pairing with a partner via an invitation code
- Activity discovery with search and filters (theme, budget, duration, indoor/outdoor)
- Proposing an activity together, with accept / decline / reschedule
- Adding to the device calendar, reminders
- Favorites and activity history ("My Dates")
- Profile: relationship counter, important dates, couple statistics, settings
