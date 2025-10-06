# Memory Load Test Script for Auto-scaling
# This script will generate memory load to trigger HPA scaling

param(
    [int]$ConcurrentUsers = 5,
    [int]$DurationMinutes = 3,
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "🧠 Starting Memory Load Test..." -ForegroundColor Green
Write-Host "Concurrent Users: $ConcurrentUsers" -ForegroundColor Yellow
Write-Host "Duration: $DurationMinutes minutes" -ForegroundColor Yellow
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Memory-intensive test scenarios
$memoryScenarios = @(
    @{
        Name = "Small Memory Test"
        Endpoint = "/v1/calculator/memory-test"
        Body = @{ size = 100 } | ConvertTo-Json
        Weight = 20
    },
    @{
        Name = "Medium Memory Test"
        Endpoint = "/v1/calculator/memory-test"
        Body = @{ size = 500 } | ConvertTo-Json
        Weight = 40
    },
    @{
        Name = "Large Memory Test"
        Endpoint = "/v1/calculator/memory-test"
        Body = @{ size = 800 } | ConvertTo-Json
        Weight = 30
    },
    @{
        Name = "Matrix Multiplication (Memory + CPU)"
        Endpoint = "/v1/calculator/matrix-multiply"
        Body = @{ size = 80 } | ConvertTo-Json
        Weight = 10
    }
)

# Function to run a single memory test
function Invoke-MemoryTest {
    param($scenario, $userId)
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl$($scenario.Endpoint)" -Method POST -Body $scenario.Body -Headers $headers -UseBasicParsing
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq 200) {
            $content = $response.Content | ConvertFrom-Json
            $memoryUsed = if ($content.memoryUsed) { $content.memoryUsed } else { "N/A" }
            Write-Host "✅ User $userId - $($scenario.Name) - Memory: ${memoryUsed}MB" -ForegroundColor Green
        } else {
            Write-Host "❌ User $userId - $($scenario.Name) - Status: $statusCode" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ User $userId - $($scenario.Name) - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to run memory load test for a user
function Start-MemoryLoadTest {
    param($userId, $durationSeconds)
    
    $endTime = (Get-Date).AddSeconds($durationSeconds)
    $requestCount = 0
    
    while ((Get-Date) -lt $endTime) {
        # Select scenario based on weight
        $random = Get-Random -Minimum 1 -Maximum 101
        $cumulativeWeight = 0
        $selectedScenario = $null
        
        foreach ($scenario in $memoryScenarios) {
            $cumulativeWeight += $scenario.Weight
            if ($random -le $cumulativeWeight) {
                $selectedScenario = $scenario
                break
            }
        }
        
        if ($selectedScenario) {
            Invoke-MemoryTest -scenario $selectedScenario -userId $userId
            $requestCount++
        }
        
        # Longer delay for memory tests to allow memory to accumulate
        Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 1500)
    }
    
    Write-Host "👤 User $userId completed $requestCount memory requests" -ForegroundColor Cyan
}

# Start monitoring in background
Write-Host "📊 Starting memory monitoring..." -ForegroundColor Blue
$monitorJob = Start-Job -ScriptBlock {
    param($namespace)
    while ($true) {
        $pods = kubectl get pods -n $namespace --no-headers
        $readyPods = ($pods | Where-Object { $_ -match '1/1' } | Measure-Object).Count
        $totalPods = ($pods | Measure-Object).Count
        
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Pods: $readyPods/$totalPods ready" -ForegroundColor Yellow
        
        # Show memory usage if possible
        try {
            $topPods = kubectl top pods -n $namespace --no-headers 2>$null
            if ($topPods) {
                Write-Host "[$timestamp] Memory Usage:" -ForegroundColor Magenta
                $topPods | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            }
        } catch {
            # metrics-server might not be available
        }
        
        Start-Sleep -Seconds 15
    }
} -ArgumentList "calculator"

# Start memory load test
Write-Host "🔥 Starting memory load test..." -ForegroundColor Red
$durationSeconds = $DurationMinutes * 60
$jobs = @()

for ($i = 1; $i -le $ConcurrentUsers; $i++) {
    $job = Start-Job -ScriptBlock ${function:Start-MemoryLoadTest} -ArgumentList $i, $durationSeconds
    $jobs += $job
    Write-Host "Started memory user $i" -ForegroundColor Gray
    Start-Sleep -Milliseconds 500
}

# Wait for all jobs to complete
Write-Host "⏳ Waiting for memory load test to complete..." -ForegroundColor Yellow
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
Write-Host "🎉 Memory load test completed!" -ForegroundColor Green
Write-Host "Total memory requests: $totalRequests" -ForegroundColor Cyan
Write-Host "Average requests per user: $([math]::Round($totalRequests / $ConcurrentUsers, 2))" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Check pod scaling with: kubectl get pods -n calculator" -ForegroundColor Blue
Write-Host "📊 Check HPA status with: kubectl get hpa -n calculator" -ForegroundColor Blue
Write-Host "📊 Check memory usage with: kubectl top pods -n calculator" -ForegroundColor Blue

