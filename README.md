# 🏦 Bank Transaction Fraud Analytics Platform

## 📌 Overview

This project implements a **production-style backend system** for detecting and analyzing fraudulent banking transactions.  
It combines advanced SQL analytics with a **FastAPI REST layer**, enabling financial systems to trace complex fraud patterns, score account-level risk, and expose actionable insights.

The platform simulates how modern banks analyze high-volume transaction data to identify suspicious behavior and maintain financial integrity.

---

## 🎯 Problem Statement

Banks process **millions of transactions daily**, making manual fraud detection impractical.  
This platform addresses key fraud analytics challenges:

- Trace multi-hop fraudulent money transfers  
- Detect repeated suspicious behavior over time  
- Prioritize accounts for investigation using risk scoring  
- Validate transaction balance consistency  
- Expose fraud insights via APIs instead of raw SQL  

---

## 🧠 Key Features

### 🔁 Fraud Chain Detection
- Recursive CTEs trace how fraudulent funds move across multiple accounts  
- Identifies money-laundering-style transaction chains  

### 📊 Rolling Fraud Pattern Analysis
- Window functions detect repeated fraud behavior over rolling transaction windows  
- Captures near real-time fraud signals  

### ⚠️ Account-Level Fraud Risk Scoring
- Risk score derived from:
  - Fraud frequency
  - Chain depth involvement
  - Large transfer behavior
  - Balance mismatch detection
- Accounts classified as **High / Medium / Low Risk**

### 🔍 Balance Integrity Validation
- Detects inconsistencies between expected and actual balances  
- Flags possible manipulation or system errors  

### 🌐 RESTful API Layer
- FastAPI-powered endpoints expose fraud analytics:
  - `/fraud/top`
  - `/fraud/account/{account}`
  - `/fraud/chain/{account}`
  - `/fraud/rolling/{account}`
  - `/health`
- Enables dashboards, monitoring systems, and investigation tools  

---

## 🛠️ Tech Stack

- **Backend:** Python, FastAPI  
- **Database:** MySQL (connection pooling)  
- **SQL:** Recursive CTEs, Window Functions, Multi-CTE Pipelines  
- **API Docs:** Swagger (auto-generated)  
- **Tools:** Git, Postman, dotenv  

---

## 💼 Business Use Cases

- Fraud investigation and monitoring  
- Risk-based account blocking  
- Compliance and audit reporting  
- Backend data source for fraud dashboards  

---

## 🏗️ System Architecture

```text
Client / Dashboard / Analyst Tool
            ↓
      FastAPI REST API Layer
            ↓
 Advanced SQL Analytics Pipeline
            ↓
      MySQL Transaction Database
