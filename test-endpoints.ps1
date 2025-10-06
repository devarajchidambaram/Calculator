# Simple endpoint test script
Write-Host "🧪 Testing Calculator API Endpoints" -ForegroundColor Green
Write-Host ""

# Test health endpoint
Write-Host "1. Testing health endpoint..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing
    Write-Host "✅ Health check: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Fibonacci endpoint
Write-Host "2. Testing Fibonacci endpoint..." -ForegroundColor Blue
try {
    $body = @{ n = 30 } | ConvertTo-Json
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/calculator/fibonacci" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✅ Fibonacci(30) = $($result.result) (iterations: $($result.iterations))" -ForegroundColor Green
} catch {
    Write-Host "❌ Fibonacci test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test memory endpoint
Write-Host "3. Testing memory endpoint..." -ForegroundColor Blue
try {
    $body = @{ size = 200 } | ConvertTo-Json
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/calculator/memory-test" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✅ Memory test: $($result.memoryUsed)MB used" -ForegroundColor Green
} catch {
    Write-Host "❌ Memory test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 All tests completed!" -ForegroundColor Green

