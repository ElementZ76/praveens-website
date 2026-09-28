# Creates the local databases (portfolio, portfolio_test) and the portfolio_app login.
# Run once from any folder:  .\backend\scripts\create-local-db.ps1
# psql will ask for the password of the "postgres" superuser (the one set when PostgreSQL was installed).
$ErrorActionPreference = 'Stop'

$envFile = Join-Path $PSScriptRoot '..\.env'
if (-not (Test-Path $envFile)) { throw "Missing $envFile. Copy .env.example to .env and fill it in." }

# Load KEY=VALUE lines from .env into this process only.
$loaded = @()
Get-Content $envFile | Where-Object { $_ -match '^\s*[^#\s][^=]*=' } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    Set-Item -Path "env:$($name.Trim())" -Value $value.Trim()
    $loaded += $name.Trim()
}

try {
    psql -U postgres -h localhost -v ON_ERROR_STOP=1 -f (Join-Path $PSScriptRoot 'create-local-db.sql')
    if ($LASTEXITCODE -ne 0) { throw "psql failed with exit code $LASTEXITCODE" }
    Write-Host "Done: databases 'portfolio' and 'portfolio_test' are ready for user 'portfolio_app'."
}
finally {
    # Don't leave the password lying around in the terminal session.
    $loaded | ForEach-Object { Remove-Item -Path "env:$_" -ErrorAction SilentlyContinue }
}
