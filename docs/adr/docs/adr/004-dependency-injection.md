# ADR-004: Dependency Injection

**Status**: Accepted  
**Date**: 2026-03-23

## Context

Dependency injection is need with [`get_it`](https://pub.dev/packages/get_it). However, to avoid mistakes and enhance
automation, speed of development and efficiency, we need to handle the creation and ordering of the dependencies. Need
the ability to separate the dependency configurations by environment/platforms.

## Decision

Use [`injectable`](https://pub.dev/packages/injectable) with its generator - [
`injectable_generator`](https://pub.dev/packages/injectable_generator) to handle generation of the dependency injection
code. Separate the dependency configurations by platform - `mobile` and `web`.

## Consequences

+ Improved development efficiency and testing
+ Consistent ordering of the dependencies based on the dependency graph
+ Reduction in errors
+ Improved maintainability and scalability
+ Ability to separate the dependency configurations by platform and environment