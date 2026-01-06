from pydantic import BaseModel

class FraudRiskSummary(BaseModel):
    account: str
    raw_score: int
    normalized_fraud_score: float
    risk_level: str

class FraudChain(BaseModel):
    initial_account: str
    next_account: str
    step: int
    chain_depth: int

class RollingFraudScore(BaseModel):
    rolling_risk: int
    last_step: int
