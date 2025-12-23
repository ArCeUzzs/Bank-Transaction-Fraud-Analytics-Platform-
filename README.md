# Bank Transaction Fraud Analytics Platform

## Overview
A real-world backend analytics system for detecting fraudulent banking transactions using advanced SQL and REST APIs.

## Features
- Recursive SQL to trace multi-hop fraud chains
- Rolling window fraud detection
- Fraud risk scoring for accounts
- Balance anomaly detection
- RESTful APIs using FastAPI

## Tech Stack
- Backend: FastAPI (Python)
- Database: MySQL
- SQL: Recursive CTEs, Window Functions, Views

## API Endpoints
- GET /fraud/high-risk
- GET /fraud/chain/{account}

## Use Cases
- Fraud investigation
- Risk-based account blocking
- Compliance and auditing dashboards

## How to Run
1. Load SQL schema
2. Install dependencies
3. Run FastAPI server
