# ADR-008: Profile Settings Architecture

**Status**: Accepted  
**Date**: 2026-04-06

## Context

Users need to update display name, avatar, about text, and phone number after initial onboarding. Updates should feel
instant.

## Decision

- ProfileService: extracted from `AuthService`, owns all profile Supabase operations
- ProfileProxy: `ChangeNotifier` wrapping Profile DTO with nullable override fields per updatable property.
  `UndoableCommand` for automatic rollback on failure.
- ProfileManager: user-scope singleton, owns ProfileProxy
- Phone change: two-OTP flow via Supabase `updateUser` + `verifyOTP(type: phoneChange)`
- Navigation: `ProfileSettingsRoute` pushed from web rail avatar and mobile `ChatsPage` popup menu

## Consequences

+ Optimistic updates feel instant — no loading spinners for edits
+ `UndoableCommand` guarantees rollback on network failure
+ ProfileService is now the single place for all profile mutations

- Phone change is a 3-page flow — complex but secure
- `image_picker` added as new dependency