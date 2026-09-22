# Contributing

Create a branch from `main` with a descriptive prefix such as `fix/`,
`feat/`, or `docs/`. Open a pull request before merging; the repository accepts
squash merges only.

Use Conventional Commits for commit and pull-request titles:

```text
type(scope): concise English description
```

Allowed types are `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, and `revert`. Do not add AI attribution trailers.

Before opening a pull request, run the relevant checks:

```bash
cd examples
pnpm install --frozen-lockfile
pnpm run verify:presets
pnpm run build --recursive --if-present
```

For native changes, configure and build the relevant CMake target. Major
initiatives use a versioned plan in `docs/plans/` and linked GitHub issues for
their current execution evidence.
