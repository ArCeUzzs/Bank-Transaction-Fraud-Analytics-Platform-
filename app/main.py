from fastapi import FastAPI
from app.routers import fraud, health

app = FastAPI(
    title="Bank Fraud Analytics API",
    description="Exposes SQL-driven fraud detection insights",
    version="1.0.0"
)

app.include_router(health.router)
app.include_router(fraud.router)

## To run the app, use the command:
# uvicorn app.main:app --reload
# and access the docs at http://127.0.0.1:8000/docs