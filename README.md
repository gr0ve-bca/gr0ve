<div align="center">
<h1>gr0ve</h1>
</div>

[gr0ve](https://gr0ve.pages.dev) brings the class schedule, bus arrivals, school calendar, teacher absences, and the lunch menu into a single, fast, themeable app, so you don't have to dig through spreadsheets, documents, and emails between classes.

## What's Here

This repository holds the full Flutter app. The code lives in `lib/`, split into `config/` (themes, palette, and user preferences), `services/` (authentication and data loading), and `screens/` (the sign-in flow and the home dashboard with its schedule, teachers, buses, calendar, lunch, and settings widgets). Static files such as the schedule data are in `assets/`, and the standard Flutter platform folders (`android/`, `ios/`, `web/`, `macos/`, `windows/`, and `linux/`) hold the per-platform build configuration. Project dependencies are declared in `pubspec.yaml`, and `flutter_build.sh` is a helper script for building the app.

## Features

- **Live schedule.** A countdown to the end of the current period (or the start of the next one), with a progress bar. It shows your lunch period, and skips ahead to the next school day when classes are over.
- **Teachers out.** Today's absences, searchable, with a per-period grid showing exactly which periods each teacher is out. Star the teachers you care about and they float to the top and show up on your home screen.
- **Buses.** Arrival spots for every bus, refreshed automatically. Search by town or route, and star your own bus to track it.
- **Calendar.** A month view with event dots and a day panel. Tap any event for its time, location, description, and link.
- **Lunch.** Today's menu grouped by station, with full nutrition facts for each item.
- **Quick links.** One tap to Schoology, PowerSchool, cancellations, the bus sheet, and counselor booking.
- **Make it yours.** Seven accent themes (grover, aspen, rowan, sakura, abies, cedite, ash), light and dark mode, and a changelog so you can see what's new.
- **Works everywhere.** A wide dashboard on desktop and a tabbed layout on phones. Install it to your home screen as a PWA, or build it natively.

This repository contains the assets and media used throughout gr0ve. Its primary purpose is to serve as a central collection of the latest gr0ve assets.

## Tech stack

- **[Flutter](https://flutter.dev)** (Dart) for one codebase across web, Android, iOS, macOS, Windows, and Linux.
- **spr0ut** handles authentication, user profiles, the student roster, and per-user data (themes, stars), backed by Supabase.
- **f0rest** provides the school data sources: absences, buses, lunch (Nutrislice), news, schedules, and events.
- **arb0r** ([gr0ve-bca/arb0r](https://github.com/gr0ve-bca/arb0r)) hosts the brand assets (theme logos) and the changelog feed.
- **User Interface**: `google_fonts`, `flutter_svg`, `hugeicons`, `url_launcher`, `shared_preferences`.

## Contributions

Issues and pull requests are welcome. If you're fixing a data-parsing edge case (like an absence status that doesn't display correctly), please include the raw status text in the issue so it can be added as a test.

## Ownership

This repository is maintained by Arjun Yuvaraj, the founder of gr0ve. For questions about asset usage, citations, or anything else, email **[gr0ve.bca@gmail.com](mailto:gr0ve.bca@gmail.com)**.

---

_This is gr0ve, made with 💚 for Bergen County Academies._
