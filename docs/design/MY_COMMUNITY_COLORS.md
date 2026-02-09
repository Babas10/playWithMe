# My Community Page — Color Reference

This document lists every visual segment of the My Community page and the colors assigned to each element.

---

## 1. AppBar (from `play_with_me_app.dart`)

| Element | Color |
|---------|-------|
| Background | `Theme.colorScheme.surface` (white) |
| Title text ("My Community") | `#004E64` (dark blue) |
| Bottom divider | `#E2E8F0` (light gray) |

## 2. TabBar (Friends / Requests tabs)

| Element | Color |
|---------|-------|
| Container background | `#F4F6F8` (light gray, same as homepage) |
| Tab label (selected) | `#004E64` (dark blue) |
| Tab label (unselected) | `#004E64` (dark blue) |
| Indicator bar (selected) | `#EACE6A` (golden yellow) |
| Request badge background | `Colors.red` |
| Request badge text | `Colors.white` |

## 3. Friends List (`friend_tile.dart`)

| Element | Color |
|---------|-------|
| Avatar background (no photo) | `#EACE6A` at 25% opacity (light golden) |
| Avatar initials text | `#004E64` (dark blue) |
| Friend name | Default (black), `FontWeight.w500` |
| Email subtitle | Default theme `bodyMedium` |
| Delete icon | Default (theme) |

## 4. Received Requests (`received_request_tile.dart`)

| Element | Color |
|---------|-------|
| Avatar background | `#EACE6A` (golden yellow) |
| Avatar initials text | `Colors.white` |
| Name text | Default, `FontWeight.w500` |
| Date subtitle | Theme `bodySmall` |
| Accept button background | `Colors.green` |
| Decline button foreground/border | `Colors.red` |

## 5. Sent Requests (`sent_request_tile.dart`)

| Element | Color |
|---------|-------|
| Avatar background | `#EACE6A` (golden yellow) |
| Avatar initials text | `Colors.white` |
| Name text | Default, `FontWeight.w500` |
| Date subtitle | Theme `bodySmall` |
| Pending chip background | `Theme.colorScheme.secondaryContainer` |
| Pending chip text | `Theme.colorScheme.onSecondaryContainer` |
| Cancel button | Default theme `TextButton` |

## 6. Add Friend Page (`add_friend_page.dart`)

| Element | Color |
|---------|-------|
| Search button background | `#EACE6A` at 25% opacity (light golden) |
| Search button text/icon | `#004E64` (dark blue) |
| Error snackbar | `Colors.red` |
| Success snackbar | `Colors.green` |
| Empty state icon | `Theme.colorScheme.onSurfaceVariant` |

## 7. Search Result (`search_result_tile.dart`)

| Element | Color |
|---------|-------|
| Avatar background (no photo) | `#EACE6A` at 25% opacity (light golden) |
| Avatar initials text | `#004E64` (dark blue) |
| "Already friends" chip bg | `Theme.colorScheme.surfaceContainerHighest` |
| "Pending" chip bg | `Theme.colorScheme.secondaryContainer` |
| Send request button bg | `#EACE6A` at 25% opacity (light golden) |
| Send request button text | `#004E64` (dark blue) |
| Accept request button | Default theme `FilledButton` |

## 8. FAB ("Add Friend" button on Community page)

| Element | Color |
|---------|-------|
| Background | `#EACE6A` at 25% opacity (light golden) |
| Icon/text | `#004E64` (dark blue) |
