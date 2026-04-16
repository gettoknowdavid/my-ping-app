# ADR-009: Realtime Infrastructure

**Status**: Accepted
**Date**: 2026-04-16

## Context

Need a scalable chat infrastructure supporting one-on-one and group conversations with image, voice,
and document messages, plus delivered/read receipts.

## Decision

Schema:

- conversations: supports both one-on-one and group via is_group flag
- conversation_members: uniform membership model for both types
- messages: single table with type enum (text/image/voice/document)
- message_receipts: per-member receipt tracking, scales to groups
- Triggers: auto-update last_message, auto-create receipts on insert

Realtime:

- Per-conversation channels, not global subscription
- Subscribed on chat screen open, unsubscribed on close
- Separate channels for messages and receipts

Services:

- ConversationService: CRUD + membership + markAsRead
- MessageService: fetch (cursor-based) + send + delete + receipts + Realtime

## Consequences

+ Schema handles one-on-one and groups uniformly
+ message_receipts scales to any group size
+ Cursor-based pagination handles large message history
+ Per-conversation channels prevent unnecessary traffic

- Realtime channels must be managed carefully — caller
  owns subscribe/unsubscribe lifecycle
- chat-media bucket policies deferred to v0.9