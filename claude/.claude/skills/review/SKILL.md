# /review - Code Review

Review the current changes for issues before committing.

## Instructions

1. Run `git diff` and `git diff --staged` to see all current changes
2. Analyze every changed file for:
   - **Bugs**: Logic errors, off-by-one, null/undefined access, race conditions
   - **Security**: Injection, XSS, hardcoded secrets, insecure defaults
   - **Performance**: N+1 queries, unnecessary re-renders, missing indexes, large allocations in loops
   - **Error handling**: Unhandled exceptions, swallowed errors, missing edge cases
   - **Naming & clarity**: Misleading names, unclear intent, dead code
3. For each issue found, report:
   - File and line number
   - Severity: **critical** / **warning** / **nit**
   - What the issue is and why it matters
   - A suggested fix
4. If no issues are found, confirm the changes look good
5. End with a short summary: total issues by severity

Keep feedback actionable and concise. Do not comment on unchanged code.
