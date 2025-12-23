# Bank Transaction Fraud Analytics Platform

---

## 📌 Overview

This project implements a **real-world fraud analytics backend system** for banking transactions.  
It leverages advanced SQL techniques and a RESTful API layer to detect complex fraud patterns, compute account-level risk, and expose actionable insights for downstream applications such as dashboards or investigation tools.

The system simulates how modern financial institutions analyze large volumes of transaction data to identify suspicious behavior, trace fraud chains, and ensure transaction integrity.

---

## 🎯 Problem Statement

Banks process millions of transactions daily, making **manual fraud detection impractical**.  
This project addresses key fraud analytics challenges:

- Trace multi-hop fraudulent money transfers  
- Detect repeated suspicious behavior over time  
- Prioritize accounts for investigation using risk scoring  
- Validate transaction balance consistency  
- Make fraud insights consumable by applications, not just SQL queries  

---

## 🧠 Key Features

### 🔁 Fraud Chain Detection
- Uses **recursive CTEs** to trace how fraudulent funds move across multiple accounts over time.  
- Helps identify **money-laundering-style transaction chains**.

### 📊 Rolling Fraud Pattern Analysis
- Applies **window functions** to detect repeated fraud activity within rolling time windows.  
- Identifies accounts showing **consistent suspicious behavior**.

### ⚠️ Account Fraud Risk Scoring
- Classifies accounts into **HIGH / MEDIUM / LOW** risk based on:  
  - Frequency of fraudulent transactions  
  - Total fraudulent transaction amount  
- Enables **investigation prioritization**.

### 🔍 Balance Integrity Validation
- Detects inconsistencies between expected and actual account balances.  
- Helps uncover **system errors or fraudulent manipulation**.

### 🌐 RESTful API Layer
- Exposes fraud analytics results via **FastAPI-based REST endpoints**  
- Allows fraud insights to be consumed by:  
  - Dashboards  
  - Case management systems  
  - Monitoring or alerting tools  

---

## 🛠️ Tech Stack

- **Backend:** FastAPI (Python)  
- **Database:** MySQL  
- **SQL Concepts:** Recursive CTEs, Window Functions, Multi-CTE Pipelines, Views  
- **Tools:** Git, Postman  
---

## 💼 Business Use Cases

- Fraud investigation and monitoring  
- Risk-based account blocking  
- Compliance and audit reporting  
- Backend data source for fraud dashboards  

----

## 🏗️ System Architecture

```text
Client / Dashboard / Analyst Tool
            ↓
      FastAPI REST APIs
            ↓
   Advanced SQL Analytics Layer
            ↓
     MySQL Transaction Database
