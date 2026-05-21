# Nskog Notes Plus

A lightweight native macOS notes app foundation inspired by Apple Notes.

The current goal is a clean starting point: fast to open in Xcode, easy to understand, and structured so features can be added incrementally without introducing unnecessary complexity early.

## Current Scope

- Swift and SwiftUI macOS-only app
- Three-column Notes-style shell:
  - Sidebar
  - Notes list
  - Editor/detail area
- Simple local in-memory note and folder models
- Clear separation between app entry, models, views, view models, and services
- Minimal Xcode project with no third-party dependencies

## Intentionally Not Implemented Yet

- Note creation, editing, deletion, or search
- Persistence beyond local placeholder seed data
- Sync, accounts, login, networking, or cloud storage
- Rich text editing
- Markdown rendering
- Tags, settings, import/export, or attachments
- AI features

## Suggested Next Steps

1. Add real local persistence using a small file-backed store.
2. Add note creation and selection behavior.
3. Add basic plain-text editing with save-on-change.
4. Add search across note titles and body text.
5. Add folder filtering and folder management.
6. Introduce focused tests around models and storage once persistence exists.

## Running

Open `NskogNotesPlus.xcodeproj` in Xcode, select the `NskogNotesPlus` scheme, and run the app on macOS.
