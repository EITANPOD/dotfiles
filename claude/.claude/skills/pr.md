# /pr - Create Pull Request

Create a well-structured pull request from the current branch.

## Arguments

- `$ARGUMENTS` — optional: base branch (defaults to main/master)

## Instructions

1. Determine the base branch:
   - Use `$ARGUMENTS` if provided
   - Otherwise detect the default branch (`main` or `master`)
2. Gather context:
   - Run `git log <base>..HEAD --oneline` to see all commits
   - Run `git diff <base>...HEAD` to see the full diff
   - Read any related issue if referenced in commit messages
3. Draft the PR:
   - **Title**: Short, imperative, under 70 characters (e.g., "Add user authentication middleware")
   - **Summary**: 2-4 bullet points explaining what changed and why
   - **Test plan**: How to verify the changes work
4. Push the branch if not already pushed
5. Create the PR using `gh pr create` with the drafted title and body
6. Return the PR URL

Use this body format:
```
## Summary
- <bullet points>

## Test plan
- [ ] <verification steps>
```
