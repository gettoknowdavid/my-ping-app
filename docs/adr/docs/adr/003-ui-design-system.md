# ADR-003: UI Design System

**Status**: Accepted  
**Date**: 2026-03-23

## Context

Building a WhatsApp clone with a consistent modern, minimalistic design that is easy to scale and maintain.

## Decision

Use [Flutter Shadcn UI](https://mariuti.com/flutter-shadcn-ui/) and its default component settings as the main
Flutter UI theme. `ShadApp.router` as the main root widget since we are using `GoRouter`. No Material widgets are used.

## Consequences

+ Consistent shadcn default aesthetic across all platforms
+ Rich component library (inputs, dialogs, avatars, sheets)
+ Not Material 3 — some Flutter ecosystem widgets may need wrapping