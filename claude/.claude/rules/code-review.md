# Code Review Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Security vulnerability or data loss risk | **BLOCK** - must fix before merge |
| HIGH | Bug or significant quality issue | **WARN** - should fix before merge |
| MEDIUM | Maintainability concern | **INFO** - consider fixing |
| LOW | Style or minor suggestion | **NOTE** - optional |

Approve: no CRITICAL/HIGH issues. Block: any CRITICAL. Warn: HIGH only, merge with caution.
