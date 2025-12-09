# Repository Guidelines

## Project Structure & Module Organization
- `src/`: Vue 3 frontend. Routes are defined in `src/main.js`, pages live in `src/views`, shared state in `src/stores`, and the API client in `src/services/api.js`.
- `backend/`: FastAPI backend. HTTP entrypoint is `backend/app_main.py`, with routes under `backend/app/api/v1`, core config in `backend/app/core`, and domain logic in `backend/app/services`.
- SQL schemas and migrations live in `backend/init.sql` and `backend/database_migration.sql`.
- Docker, Vite, and package configuration are in `Dockerfile`, `vite.config.js`, `package.json`, and `pnpm-lock.yaml`.

## Build, Test, and Development Commands
- Frontend: from repo root run `pnpm install`, then `pnpm dev` for local development, `pnpm build` for a production bundle, and `pnpm preview` to serve the built assets.
- Backend: run `cd backend && pip install -r requirements.txt`, then `uvicorn app_main:app --host 0.0.0.0 --port 8000 --reload` for development.
- Backend tests (when present): `cd backend && pytest`.

## Coding Style & Naming Conventions
- Frontend: use Vue 3 Composition API (`<script setup>`), 2-space indentation, single quotes in JS, and avoid unnecessary semicolons. Components use PascalCase filenames (e.g. `Leaderboard.vue`), functions and variables use `camelCase`.
- Backend: Python 3 with 4-space indentation, `snake_case` for functions and variables, `PascalCase` for classes. Follow PEP 8; format with `black` and lint with `ruff` (`cd backend && black app_main.py app && ruff check app_main.py app`).
- Keep modules focused: API endpoints in `app/api/v1`, shared business rules in `app/services`, schemas in `app/schemas`.

## Testing Guidelines
- Prefer backend tests using `pytest`/`pytest-asyncio`. Place files in `backend/tests/` named `test_*.py` and cover new API routes, services, and bug fixes.
- Frontend automated tests are not yet configured; for significant UI changes, add component tests in a colocated `__tests__/` folder or similar and document how to run them in `package.json`.
- Before opening a PR, run backend tests (if present) and manually smoke test the main flow: login via linux.do, submit a benchmark, and verify the leaderboard.

## Commit & Pull Request Guidelines
- Write clear, descriptive commit messages in imperative mood, e.g. `feat(frontend): add benchmark detail view` or `fix(backend): handle missing device type`.
- Keep pull requests focused and small when possible. Include a summary, motivation, key changes, and any schema or config impacts.
- Link related issues (e.g. `Closes #123`) and attach screenshots or GIFs for UI-visible changes.

## Security & Configuration Tips
- Never commit secrets or real `.env` files. Use `.env.example` or documentation to describe required variables (`DATABASE_URL`, `OAUTH_CLIENT_ID`, `OAUTH_CLIENT_SECRET`, `OAUTH_CALLBACK_URL`, `ALLOWED_ORIGINS`).
- When changing authentication, CORS, or database code, verify that the configuration still matches the expectations documented in `backend/README.md` and `CLAUDE.md`.

