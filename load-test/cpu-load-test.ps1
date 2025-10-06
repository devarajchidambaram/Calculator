# CPU Load Test Script for Auto-scaling
# This script will generate CPU load to trigger HPA scaling

param(
    [int]$ConcurrentUsers = 10,
    [int]$DurationMinutes = 5,
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "🚀 Starting CPU Load Test..." -ForegroundColor Green
Write-Host "Concurrent Users: $ConcurrentUsers" -ForegroundColor Yellow
Write-Host "Duration: $DurationMinutes minutes" -ForegroundColor Yellow
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Test scenarios that will consume CPU
$testScenarios = @(
    @{
        Name = "Fibonacci (CPU Intensive)"
        Endpoint = "/v1/calculator/fibonacci"
        Body = @{ n = 35 } | ConvertTo-Json
        Weight = 40
    },
    @{
        Name = "Prime Numbers (CPU Intensive)"
        Endpoint = "/v1/calculator/prime-check"
        Body = @{ n = 5000 } | ConvertTo-Json
        Weight = 30
    },
    @{
        Name = "Matrix Multiplication (CPU Intensive)"
        Endpoint = "/v1/calculator/matrix-multiply"
        Body = @{ size = 50 } | ConvertTo-Json
        Weight = 20
    },
    @{
        Name = "Basic Math (Light Load)"
        Endpoint = "/v1/calculator/add"
        Body = @{ a = 100; b = 200 } | ConvertTo-Json
        Weight = 10
    }
)

# Function to run a single test
function Invoke-Test {
    param($scenario, $userId)
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl$($scenario.Endpoint)" -Method POST -Body $scenario.Body -Headers $headers -UseBasicParsing
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq 200) {
            Write-Host "✅ User $userId - $($scenario.Name) - Success" -ForegroundColor Green
        } else {
            Write-Host "❌ User $userId - $($scenario.Name) - Status: $statusCode" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ User $userId - $($scenario.Name) - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to run load test for a user
function Start-UserLoadTest {
    param($userId, $durationSeconds)
    
    $endTime = (Get-Date).AddSeconds($durationSeconds)
    $requestCount = 0
    
    while ((Get-Date) -lt $endTime) {
        # Select scenario based on weight
        $random = Get-Random -Minimum 1 -Maximum 101
        $cumulativeWeight = 0
        $selectedScenario = $null
        
        foreach ($scenario in $testScenarios) {
            $cumulativeWeight += $scenario.Weight
            if ($random -le $cumulativeWeight) {
                $selectedScenario = $scenario
                break
            }
        }
        
        if ($selectedScenario) {
            Invoke-Test -scenario $selectedScenario -userId $userId
            $requestCount++
        }
        
        # Small delay between requests
        Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
    }
    
    Write-Host "👤 User $userId completed $requestCount requests" -ForegroundColor Cyan
}

# Start monitoring in background
Write-Host "📊 Starting monitoring..." -ForegroundColor Blue
$monitorJob = Start-Job -ScriptBlock {
    param($namespace)
    while ($true) {
        $pods = kubectl get pods -n $namespace --no-headers | ForEach-Object { ($_ -split '\s+')[0] }
        $readyPods = kubectl get pods -n $namespace --no-headers | Where-Object { $_ -match '1/1' } | Measure-Object | Select-Object -ExpandProperty Count
        $totalPods = ($pods | Measure-Object).Count
        
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Pods: $readyPods/$totalPods ready" -ForegroundColor Yellow
        
        Start-Sleep -Seconds 10
    }
} -ArgumentList "calculator"

# Start load test
Write-Host "🔥 Starting load test..." -ForegroundColor Red
$durationSeconds = $DurationMinutes * 60
$jobs = @()

for ($i = 1; $i -le $ConcurrentUsers; $i++) {
    $job = Start-Job -ScriptBlock ${function:Start-UserLoadTest} -ArgumentList $i, $durationSeconds
    $jobs += $job
    Write-Host "Started user $i" -ForegroundColor Gray
    Start-Sleep -Milliseconds 200
}

# Wait for all jobs to complete
Write-Host "⏳ Waiting for load test to complete..." -ForegroundColor Yellow
$jobs | Wait-Job | Out-Null

# Get results
$totalRequests = 0
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    $totalRequests += $result
}

# Cleanup
$jobs | Remove-Job
Stop-Job $monitorJob
Remove-Job $monitorJob

Write-Host ""
Write-Host "🎉 Load test completed!" -ForegroundColor Green
Write-Host "Total requests: $totalRequests" -ForegroundColor Cyan
Write-Host "Average requests per user: $([math]::Round($totalRequests / $ConcurrentUsers, 2))" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Check pod scaling with: kubectl get pods -n calculator" -ForegroundColor Blue
Write-Host "📊 Check HPA status with: kubectl get hpa -n calculator" -ForegroundColor Blue

