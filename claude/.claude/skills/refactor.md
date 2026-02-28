# /refactor - Refactor Code

Analyze and refactor the specified code for better quality.

## Arguments

- `$ARGUMENTS` — the file path, function name, or area to refactor

## Instructions

1. Read the target code specified by `$ARGUMENTS`
2. Analyze for refactoring opportunities:
   - **Duplication**: Repeated logic that can be consolidated
   - **Complexity**: Functions that are too long or deeply nested
   - **Naming**: Variables/functions that don't clearly express intent
   - **Structure**: Code that violates single responsibility or has poor separation of concerns
   - **Simplification**: Overly clever code, unnecessary abstractions, dead code paths
3. Before making changes, briefly explain:
   - What you're changing and why
   - Any trade-offs involved
4. Apply the refactoring:
   - Make focused, incremental changes
   - Preserve all existing behavior — this is a refactor, not a feature change
   - Keep the style consistent with the rest of the codebase
5. After refactoring, run existing tests if available to verify nothing broke

Do NOT add features, change APIs, or modify behavior. Only improve internal code quality.
