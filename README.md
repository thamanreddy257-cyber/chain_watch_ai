# ChainWatch AI

ChainWatch AI includes a Flutter client, a Next.js dashboard, and a local FastAPI backend. The backend seeds a synthetic transaction dataset on first startup, then builds the wallet graph and risk alerts for both dashboards.

## Run the backend

From the repository root in PowerShell:

```powershell
py -m venv backend/.venv
backend/.venv/Scripts/python.exe -m pip install -r backend/requirements.txt
backend/.venv/Scripts/python.exe -m uvicorn main:app --app-dir backend --reload --host 0.0.0.0 --port 8000
```

The API is available at `http://127.0.0.1:8000`; interactive API docs are at `http://127.0.0.1:8000/docs`. On its first run, it generates and analyzes local synthetic data. No external data service is required.

## Run the Flutter app

Start the backend first. Desktop builds use `http://127.0.0.1:8000` by default. For an Android emulator, use its host-machine alias:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The Flutter dashboard reads transaction statistics and recent wallet alerts from the API. Other investigation views remain demo-backed.

## Run the Next.js dashboard

In a second terminal:

```powershell
cd frontend
npm install
npm run dev
```

The development server proxies `/api/*` to the local FastAPI service.

## API routes

- `GET /api/health`: service health
- `GET /api/stats`: transaction totals, risk distribution, and volume timeline
- `GET /api/alerts`: filterable risk alerts
- `GET /api/graph`: wallet/IP transaction graph
- `GET /api/entity/{entity_id}` and `GET /api/entity-search`: entity investigation
- `POST /api/ingest`, `POST /api/graph`, `POST /api/detect`: run pipeline stages
