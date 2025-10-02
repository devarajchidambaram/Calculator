import http from 'k6/http';
import { check, sleep } from 'k6';

// Configure quick smoke: low RPS, short duration. Adjust via env vars.
export const options = {
  scenarios: {
    smoke: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.RPS || 10), // requests per second
      timeUnit: '1s',
      duration: __ENV.DURATION || '30s',
      preAllocatedVUs: 10,
      maxVUs: 50,
    },
  },
  thresholds: {
    http_req_duration: [
      // 95th percentile should be under X ms (default 200ms)
      `p(95)<${Number(__ENV.P95_MS || 200)}`,
    ],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

const headers = {
  'Content-Type': 'application/json',
};

function postCalc(path, a, b) {
  const url = `${BASE_URL}/v1/calculator/${path}`;
  const payload = JSON.stringify({ a, b });
  const res = http.post(url, payload, { headers });
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has result': (r) => {
      try {
        const body = r.json();
        return typeof body?.result === 'number';
      } catch (_) {
        return false;
      }
    },
  });
}

export default function () {
  // Use small floats to exercise parsing
  postCalc('add', 12.5, 3.5);
  postCalc('subtract', 12.5, 3.5);
  postCalc('multiply', 12.5, 3.5);
  postCalc('divide', 12.5, 3.5);
  sleep(1);
}


