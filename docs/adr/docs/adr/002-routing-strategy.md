# ADR-002: Routing Strategy

**Status**: Accepted
**Date**: 2026-03-23

## Context
Building a WhatsApp clone, targetting mobile and web platforms.
Need deep linking, route guards, URL sync on web, and nested tab navigation (chats, settings, calls).

## Decision
- Use `go_router` with `go_router_builder` for type-safe, code-generated routes.
- `StatefulShellRoute` for persistent tab states and routing.
- Redirects with `RedirectRoute`s for route gaurding at different levels.

## Consequences
+ Type-safe navigation — compile-time errors, not runtime crashes
+ Web URL sync out of the box
+ Auth guards centralized in one place
- Requires build_runner step when adding/changing routes