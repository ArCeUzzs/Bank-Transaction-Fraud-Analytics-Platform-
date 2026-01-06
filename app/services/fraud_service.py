from app.database import get_db

def get_top_fraud_accounts(limit: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    query = """
    SELECT account, raw_score, normalized_fraud_score, risk_level
    FROM fraud_risk_summary
    ORDER BY normalized_fraud_score DESC
    LIMIT %s;
    """

    cursor.execute(query, (limit,))
    result = cursor.fetchall()

    cursor.close()
    db.close()
    return result

def get_account_risk(account: str):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    query = """
    SELECT account, raw_score, normalized_fraud_score, risk_level
    FROM fraud_risk_summary
    WHERE account = %s;
    """

    cursor.execute(query, (account,))
    result = cursor.fetchone()

    cursor.close()
    db.close()
    return result

def get_fraud_chain(account: str):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    query = """
    SELECT initial_account, next_account, step, chain_depth
    FROM fraud_chain
    WHERE initial_account = %s
    ORDER BY chain_depth;
    """

    cursor.execute(query, (account,))
    result = cursor.fetchall()

    cursor.close()
    db.close()
    return result

def get_rolling_score(account: str):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    query = """
    SELECT rolling_risk, last_step
    FROM rolling_fraud_score
    WHERE account = %s;
    """

    cursor.execute(query, (account,))
    result = cursor.fetchone()

    cursor.close()
    db.close()
    return result
