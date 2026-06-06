# ADR-0001: Record architecture decisions

- **Status:** accepted
- **Date:** <YYYY-MM-DD>

## Context
We need a durable record of significant technical decisions so future contributors
(human and AI) understand *why* the system is the way it is.

## Decision
Use lightweight ADRs in `docs/adr/`. One file per decision, numbered, using `template.md`.
Record a new ADR whenever a choice is hard to reverse or non-obvious.

## Consequences
- Decisions are searchable and reviewable.
- Small per-decision overhead.
