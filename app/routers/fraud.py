from fastapi import APIRouter, HTTPException
from typing import List
from app.models import FraudRiskSummary, FraudChain, RollingFraudScore
from app.services.fraud_service import (
    get_top_fraud_accounts,
    get_account_risk,
    get_fraud_chain,
    get_rolling_score
)

router = APIRouter(prefix="/fraud", tags=["Fraud Analytics"])

@router.get("/top", response_model=List[FraudRiskSummary])
def top_fraud_accounts(limit: int = 20):
    return get_top_fraud_accounts(limit)

@router.get("/account/{account}", response_model=FraudRiskSummary)
def account_risk(account: str):
    result = get_account_risk(account)
    if not result:
        raise HTTPException(status_code=404, detail="Account not found")
    return result

@router.get("/chain/{account}", response_model=List[FraudChain])
def fraud_chain(account: str):
    return get_fraud_chain(account)

@router.get("/rolling/{account}", response_model=RollingFraudScore)
def rolling_score(account: str):
    result = get_rolling_score(account)
    if not result:
        raise HTTPException(status_code=404, detail="No rolling score found")
    return result
