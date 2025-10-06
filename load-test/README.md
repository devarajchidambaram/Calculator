# 🚀 Auto-Scaling Load Testing Guide

This directory contains load testing scripts to test the auto-scaling capabilities of your Calculator API in Kubernetes.

## 📁 Test Scripts

### 1. **Quick Test** (`quick-test.ps1`)
- **Purpose**: Verify all endpoints are working correctly
- **Duration**: ~30 seconds
- **Usage**: `.\load-test\quick-test.ps1`

### 2. **CPU Load Test** (`cpu-load-test.ps1`)
- **Purpose**: Generate CPU load to trigger HPA scaling
- **Features**: 
  - Fibonacci calculations (CPU intensive)
  - Prime number generation
  - Matrix multiplication
  - Real-time pod monitoring
- **Usage**: `.\load-test\cpu-load-test.ps1 -ConcurrentUsers 10 -DurationMinutes 5`

### 3. **Memory Load Test** (`memory-load-test.ps1`)
- **Purpose**: Generate memory load to trigger HPA scaling
- **Features**:
  - Memory-intensive operations
  - Large array processing
  - Memory usage monitoring
- **Usage**: `.\load-test\memory-load-test.ps1 -ConcurrentUsers 5 -DurationMinutes 3`

## 🎯 Auto-Scaling Test Scenarios

### **Scenario 1: CPU-Intensive Load**
```powershell
# Light load (2-3 users)
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 3 -DurationMinutes 2

# Medium load (5-8 users) - Should trigger scaling
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 8 -DurationMinutes 3

# Heavy load (15+ users) - Should scale to max replicas
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 15 -DurationMinutes 5
```

### **Scenario 2: Memory-Intensive Load**
```powershell
# Light memory load
.\load-test\memory-load-test.ps1 -ConcurrentUsers 3 -DurationMinutes 2

# Heavy memory load - Should trigger scaling
.\load-test\memory-load-test.ps1 -ConcurrentUsers 8 -DurationMinutes 4
```

### **Scenario 3: Mixed Load (CPU + Memory)**
```powershell
# Run both tests simultaneously in different terminals
# Terminal 1:
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 8 -DurationMinutes 5

# Terminal 2:
.\load-test\memory-load-test.ps1 -ConcurrentUsers 5 -DurationMinutes 5
```

## 📊 Monitoring Commands

### **Real-time Pod Monitoring**
```bash
# Watch pod scaling in real-time
kubectl get pods -n calculator -w

# Check pod resource usage
kubectl top pods -n calculator

# Check HPA status
kubectl get hpa -n calculator -w
```

### **Detailed Pod Information**
```bash
# Describe pods for detailed info
kubectl describe pods -n calculator

# Check pod logs
kubectl logs -f deployment/calculator-api -n calculator

# Check events
kubectl get events -n calculator --sort-by='.lastTimestamp'
```

## 🎛️ HPA Configuration

Your HPA is configured with:
- **Min Replicas**: 2
- **Max Replicas**: 10
- **CPU Target**: 70%
- **Memory Target**: 80%

### **Expected Behavior**:
1. **Normal Load**: 2-3 pods running
2. **Medium Load**: 4-6 pods (CPU/Memory > 70%/80%)
3. **Heavy Load**: 8-10 pods (max scaling)
4. **Load Decrease**: Pods scale down gradually

## 🔧 Troubleshooting

### **If Pods Don't Scale Up**:
1. Check if metrics-server is installed:
   ```bash
   kubectl get pods -n kube-system | grep metrics-server
   ```

2. Check HPA status:
   ```bash
   kubectl describe hpa calculator-hpa -n calculator
   ```

3. Check resource requests/limits in deployment

### **If Pods Scale Too Aggressively**:
1. Adjust HPA targets in `k8s/hpa.yaml`
2. Increase resource requests in `k8s/deployment.yaml`
3. Adjust scaling policies

### **If Load Test Fails**:
1. Ensure port-forward is running:
   ```bash
   kubectl port-forward svc/calculator-service 8080:80 -n calculator
   ```

2. Check pod status:
   ```bash
   kubectl get pods -n calculator
   ```

3. Check application logs:
   ```bash
   kubectl logs deployment/calculator-api -n calculator
   ```

## 📈 Performance Metrics

### **Key Metrics to Monitor**:
- **Pod Count**: `kubectl get pods -n calculator`
- **CPU Usage**: `kubectl top pods -n calculator`
- **Memory Usage**: `kubectl top pods -n calculator`
- **Response Times**: Check load test output
- **Error Rates**: Check load test output

### **Expected Response Times**:
- **Basic Math**: < 100ms
- **Fibonacci(30)**: 1-5 seconds
- **Primes(1000)**: 100-500ms
- **Matrix(20x20)**: 200-800ms
- **Memory Test**: 500ms-2s

## 🎉 Success Criteria

Your auto-scaling is working correctly if:
1. ✅ Pods scale up when load increases
2. ✅ Pods scale down when load decreases
3. ✅ Response times remain reasonable under load
4. ✅ No pod crashes or errors
5. ✅ HPA metrics show proper scaling decisions

## 🚀 Advanced Testing

### **Stress Test**:
```powershell
# Maximum load test
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 20 -DurationMinutes 10
.\load-test\memory-load-test.ps1 -ConcurrentUsers 10 -DurationMinutes 8
```

### **Endurance Test**:
```powershell
# Long-running test
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 5 -DurationMinutes 30
```

### **Spike Test**:
```powershell
# Sudden load spike
.\load-test\cpu-load-test.ps1 -ConcurrentUsers 25 -DurationMinutes 1
```

Happy testing! 🎯

