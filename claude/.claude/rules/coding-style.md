# Coding Style

## Immutability

Always create new objects/copies, never mutate in place. Prevents hidden side effects, easier debugging, safe concurrency.

## File Size

Prefer many small files over few large ones. 200-400 lines typical, 800 max — extract utilities past that.
