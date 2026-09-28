-- Creates the local development databases and the app's own login.
-- Run it through create-local-db.ps1, which loads DB_PASSWORD from backend/.env.
-- Safe to re-run: existing objects are kept, and the password is re-synced with .env.

\getenv app_password DB_PASSWORD
\if :{?app_password}
\else
    \echo 'DB_PASSWORD is not set. Run create-local-db.ps1 instead of this file.'
    \quit
\endif

-- 1. The app's login. Not a superuser: it can only use the databases it owns.
SELECT 'CREATE ROLE portfolio_app LOGIN'
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'portfolio_app')
\gexec
ALTER ROLE portfolio_app PASSWORD :'app_password';

-- 2. The databases, owned by the app's login.
SELECT 'CREATE DATABASE portfolio OWNER portfolio_app'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'portfolio')
\gexec
SELECT 'CREATE DATABASE portfolio_test OWNER portfolio_app'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'portfolio_test')
\gexec
