
# CarbonTrace | Supply Chain Carbon Management

CarbonTrace is a full-stack project for reviewing product and logistics emissions and managing measurable carbon-reduction initiatives. The UI is a Next.js app, the API is Express, MySQL stores the transactional supply-chain model, and MongoDB stores mirrors of app-created accounts, suppliers, credits, plus audit events. It extends the supplied teammate schema and SQL dump with an interactive workflow.

## Requirements

- Node.js 22 or later and npm
- Docker Desktop with Docker Compose (recommended local database setup)
- About 2 GB free disk space for the database images

## Start a clean demo environment

From this folder, create `.env` from `.env.example`. Set unique local passwords and a random session secret of at least 32 characters. The supplied values are examples only.

```powershell
Copy-Item .env.example .env
# Edit .env and replace all example secrets.
docker compose up -d
```

The MySQL container initializes a **new empty named volume** using `database/supply_chain_carbon_complete.sql`, the routines file, and the CarbonTrace migration. The source dump drops/recreates project tables. Docker's init scripts run only when the MySQL data volume is empty; do not point these scripts at a database containing data you need. Back up and use a disposable database if importing manually. MongoDB starts with its root account; create the restricted app account once:

```powershell
docker compose exec mongodb mongosh -u carbontrace_root -p --authenticationDatabase admin
```

Enter the `MONGO_ROOT_PASSWORD` value from `.env` when prompted. Use a URL-safe password for the app user to avoid URI-encoding mistakes.

At the `mongosh` prompt:

```javascript
use carbontrace
db.createUser({ user: "carbontrace_app", pwd: "<same password as MONGODB_URI>", roles: [{ role: "readWrite", db: "carbontrace" }] })
```

Set the `MONGODB_URI` username/password in `.env` to that app account. Compose does not create Mongo app users automatically. Use a strong unique password.

Install dependencies and start the API and web app in separate terminals:

```powershell
cd backend
npm ci
npm run create-user
npm run dev
```

The CLI prompts for email, display name, role (`admin` or `analyst`) and password. Create an admin for the demo. Then:

```powershell
cd frontend
npm ci
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) and sign in with the admin created above. Visitors can also choose **Create an account** on the sign-in page; website signups receive the least-privileged analyst role. The API health endpoint is [http://localhost:4000/api/health](http://localhost:4000/api/health). It reports dependency status without exposing credentials. To run the frontend against another API host, copy `frontend/.env.example` to `frontend/.env.local`, set `NEXT_PUBLIC_API_BASE_URL`, and restart Next.js. Keep `FRONTEND_ORIGIN` aligned with the browser origin; local development accepts ports 3000 and 3001.

Use an **admin** account to add suppliers and carbon credits from their respective register pages. To verify the MongoDB copies in Compass, open the `carbontrace` database and inspect `app_users`, `suppliers`, `carbon_credits`, and `audit_events`. Signup profiles contain no password hash. Existing app users, suppliers, and credits are synchronized to MongoDB when the API starts; newly created rows are published through the MySQL outbox.

To stop the services, use `docker compose down`. The database volumes persist. `docker compose down -v` permanently removes the demo database volumes; only use it when you intentionally want a fresh import.

## Existing MySQL or manual import

The source dump contains destructive `DROP TABLE` statements and views/routines defined as `root@localhost`. Import only into a fresh/disposable MySQL 8.0 database with an account that can create the objects and matches or adjusts the definers. Then run `database/advanced_features.sql` and `database/migrations/001_carbontrace_app.sql` in that order. The migration's `ALTER TABLE` index statement is intended to run once. Never run the source dump against a database with data you need.

## Roles and core features

- `admin`: dashboard/read access, manage suppliers, carbon credits and initiatives, and view MongoDB audit history.
- `analyst`: dashboard/read access and view registers; cannot change records or view admin audit history. Website signups are analysts by default.
- Product and shipment registers come from the supplied MySQL schema. Admins can add suppliers and available carbon credits in the website.
- Account, supplier, credit, and initiative changes enqueue MongoDB mirror/audit writes in the same MySQL transaction. MongoDB publication is idempotent; pending changes are retried when the audit view is requested. Existing user, supplier, and credit rows are synchronized to MongoDB when the API starts. Password hashes are never mirrored.
- Validation occurs in the UI, API, and MySQL constraints/triggers. Sessions are signed, expiring, HTTP-only cookies; passwords use Node's scrypt; login is rate-limited; database calls use parameters.

## Database features demonstrated

The project demonstrates relational constraints and foreign keys, indexes, views, stored procedures, stored functions, triggers, transactions, and MongoDB aggregation. Examples and the ER model are in [docs/PROJECT_DOCUMENTATION.md](docs/PROJECT_DOCUMENTATION.md); manual verification queries are in [docs/TEST_PLAN.md](docs/TEST_PLAN.md).

## Team

- **Bhakti S Patil** — primary frontend and backend implementation; also contributed to database and advanced-feature work.
- **Arushi Punhani** — primary SQL schema/dump and advanced database work; also contributed to application implementation.
- Both members contributed across the database and application domains, as confirmed by the team. The supplied ZIP has no Git history; add real individual commits from each member's own Git identity if the course evaluator requires contribution history. No commits or pushes were made as part of this packaging work.

## Project files

- `frontend/` — Next.js web application.
- `backend/` — Express API, authentication, validation, audit publisher, and account setup CLI.
- `database/supply_chain_carbon_complete.sql` — teammate's full MySQL schema and sample data dump.
- `database/advanced_features.sql` — project routines.
- `database/migrations/001_carbontrace_app.sql` — CarbonTrace roles, initiative workflow, indexes, view, and triggers.
- `docker-compose.yml` — local MySQL and MongoDB services.
- `docs/` — requirements mapping, architecture, ER/schema, team, and test plan.

## Troubleshooting

- If the UI says the API is unavailable, check `npm run dev` in `backend` and `/api/health`.
- If health reports MySQL unavailable, check the `MYSQL_*` values and `docker compose ps`.
- If Mongo is unavailable, create the `carbontrace_app` user and make its password match `MONGODB_URI`.
- If MySQL init fails, inspect `docker compose logs mysql`. On a fresh demo volume you can correct `.env` and recreate it with `docker compose down -v` then `docker compose up -d`; that removes the local volume data.
- This is an academic demo. Use HTTPS, managed secrets, stronger operational controls, and reviewed authorization policies before any real deployment.
