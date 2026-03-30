# ADR-007: App Shell Architecture

**Status**: Accepted  
**Date**: 2026-03-30

## Context

Need persistent navigation chrome across four (4) tabs (Chats, Updates, Communities, Calls) that work on both mobile
and web.

## Decision

- `StatefulShellRoute.indexedStack` preserves tab state across switches
- `AppShell` reads `ShadResponsiveBuilder` breakpoint at md (768 px)
- Below md: `MobileShell` with `NavigationBar` (bottom nav)
- Above md: `WebShell` with `NavigationRail` (icon rail, no labels)
- Each tab is an independent navigator branch

## Consequences

+ Tab state preserved — Chats scroll position survives tab switch
+ Single breakpoint decision point in AppShell
+ Clean separation — `MobileShell` and `WebShell` are independent widgets

- `NavigationBar` is Material — will need ShadCN-styled replacement
  if design system consistency becomes a priority