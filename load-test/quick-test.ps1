# Quick Test Script - Test individual endpoints
param(
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "🧪 Quick Test Script" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Test basic functionality
Write-Host "1. Testing basic health check..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/health" -UseBasicParsing
    Write-Host "✅ Health check: $($response.StatusCode)" -ForegroundColor Green
    $healthData = $response.Content | ConvertFrom-Json
    Write-Host "   Status: $($healthData.status), Uptime: $($healthData.uptime)s" -ForegroundColor Gray
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test basic math
Write-Host "2. Testing basic math operations..." -ForegroundColor Blue
$mathTests = @(
    @{ op = "add"; a = 10; b = 5; expected = 15 },
    @{ op = "subtract"; a = 10; b = 3; expected = 7 },
    @{ op = "multiply"; a = 4; b = 6; expected = 24 },
    @{ op = "divide"; a = 20; b = 4; expected = 5 }
)

foreach ($test in $mathTests) {
    try {
        $body = @{ a = $test.a; b = $test.b } | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "$BaseUrl/v1/calculator/$($test.op)" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
        $result = $response.Content | ConvertFrom-Json
        if ($result.result -eq $test.expected) {
            Write-Host "✅ $($test.op)($($test.a), $($test.b)) = $($result.result)" -ForegroundColor Green
        } else {
            Write-Host "❌ $($test.op)($($test.a), $($test.b)) = $($result.result), expected $($test.expected)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ $($test.op) failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test CPU-intensive operations
Write-Host "3. Testing CPU-intensive operations..." -ForegroundColor Blue

# Fibonacci test
try {
    $body = @{ n = 30 } | ConvertTo-Json
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$BaseUrl/v1/calculator/fibonacci" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✅ Fibonacci(30) = $($result.result) in ${duration}ms (iterations: $($result.iterations))" -ForegroundColor Green
} catch {
    Write-Host "❌ Fibonacci test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Prime test
try {
    $body = @{ n = 1000 } | ConvertTo-Json
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$BaseUrl/v1/calculator/prime-check" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    $result = $response.Content | ConvertFrom-Json
    $primeCount = $result.primes.Count
    Write-Host "✅ Primes up to 1000: $primeCount primes found in ${duration}ms" -ForegroundColor Green
} catch {
    Write-Host "❌ Prime test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Matrix test
try {
    $body = @{ size = 20 } | ConvertTo-Json
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$BaseUrl/v1/calculator/matrix-multiply" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✅ Matrix multiplication (20x20) completed in ${duration}ms" -ForegroundColor Green
} catch {
    Write-Host "❌ Matrix test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test memory operations
Write-Host "4. Testing memory-intensive operations..." -ForegroundColor Blue

try {
    $body = @{ size = 200 } | ConvertTo-Json
    $response = Invoke-WebRequest -Uri "$BaseUrl/v1/calculator/memory-test" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✅ Memory test: $($result.result)" -ForegroundColor Green
    Write-Host "   Memory used: $($result.memoryUsed)MB" -ForegroundColor Gray
} catch {
    Write-Host "❌ Memory test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Quick test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 To run load tests:" -ForegroundColor Blue
Write-Host "   .\load-test\cpu-load-test.ps1 -ConcurrentUsers 10 -DurationMinutes 5" -ForegroundColor Gray
Write-Host "   .\load-test\memory-load-test.ps1 -ConcurrentUsers 5 -DurationMinutes 3" -ForegroundColor Gray