# ADR-001: Architectural Overview

**Status**: Accepted
**Date**: 2023-09-20

## Context
Building a flutter application using the [`flutter_it`](https://flutter-it.dev/) construction set, which includes:
- [`get_it`](https://flutter-it.dev/documentation/get_it/getting_started) for dependency injection
- [`watch-it`](https://flutter-it.dev/documentation/watch_it/getting_started) for automatic rebuilds in the Flutter widgets
- [`command-it`](https://flutter-it.dev/documentation/command_it/getting_started) for state management based on `ValueListenable` and `Command` design pattern
- [`listen-it`](https://flutter-it.dev/documentation/listen_it/getting_started) for reactive collections and operators to be used with `ValueListenable`

Need a consistent architecture that scales and is easy to reason about and maintain.

## Decision
Adopt a Pragmatic Flutter Architecture (PFA) with three layers:
- Services: external API/DB boundaries
- Managers: business logic, state, commands
- View: Self-responsible UI, watch managers

Organize code by features, not by layer.

## Consequences
+ Clear separation of concerns
+ Reactive UI without boilerplate
+ Easy to test with `get_it` scopes
+ Requires discipline to not bypass manager layer
