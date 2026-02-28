# /test - Generate Tests

Generate tests for the specified file or function.

## Arguments

- `$ARGUMENTS` — the file path, function name, or description of what to test

## Instructions

1. Read the target code specified by `$ARGUMENTS`
2. Detect the project's test framework and patterns by looking for:
   - Existing test files (look for `*.test.*`, `*.spec.*`, `__tests__/`, `tests/`)
   - Test config files (`jest.config`, `vitest.config`, `pytest.ini`, `phpunit.xml`, etc.)
   - Package manager files for test dependencies
3. Match the existing conventions:
   - Same test framework and assertion style
   - Same file naming pattern and directory structure
   - Same setup/teardown patterns
4. Generate tests covering:
   - Happy path for each public function/method
   - Edge cases (empty input, null, boundary values)
   - Error cases (invalid input, failures)
5. Place the test file in the correct location following project conventions
6. Run the tests to verify they pass

If no existing test patterns are found, ask the user which framework to use.
