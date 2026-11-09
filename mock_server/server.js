/**
 * cashUPay Mini — Standalone Mock API Server
 * Built with pure Node.js (no external dependencies needed)
 * Run: node mock_server/server.js
 */

const http = require('http');
const url = require('url');

const PORT = process.env.PORT || 8080;

// In-memory Database
let transactions = [
  {
    id: 'CU8F2A1',
    amount: 125000,
    brand: 'Visa',
    last4: '4821',
    maskedPan: '•••• 4821',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 15 * 60 * 1000).toISOString()
  },
  {
    id: 'CU7G910',
    amount: 48500,
    brand: 'GPN',
    last4: '1190',
    maskedPan: '•••• 1190',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 38 * 60 * 1000).toISOString()
  },
  {
    id: 'CU6B20E',
    amount: 310000,
    brand: 'Mastercard',
    last4: '7733',
    maskedPan: '•••• 7733',
    status: 'DECLINED',
    reason: 'LIMIT_EXCEEDED',
    createdAt: new Date(Date.now() - 64 * 60 * 1000).toISOString()
  },
  {
    id: 'CU5D332',
    amount: 87000,
    brand: 'Visa',
    last4: '2208',
    maskedPan: '•••• 2208',
    status: 'SUCCESS',
    createdAt: new Date(Date.now() - 86 * 60 * 1000).toISOString()
  },
  {
    id: 'CU4X901',
    amount: 64000,
    brand: 'GPN',
    last4: '9012',
    maskedPan: '•••• 9012',
    status: 'VOIDED',
    createdAt: new Date(Date.now() - 128 * 60 * 1000).toISOString()
  }
];

const idempotencyStore = new Map();

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, Idempotency-Key'
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer((req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Idempotency-Key'
    });
    return res.end();
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  // Add realistic latency (400 - 800ms)
  const latency = 400 + Math.floor(Math.random() * 400);

  setTimeout(() => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      let parsedBody = {};
      try {
        if (body) parsedBody = JSON.parse(body);
      } catch (_) {}

      console.log(`[${new Date().toLocaleTimeString()}] ${method} ${pathname} (Latency: ${latency}ms)`);

      // 1. POST /auth/login
      if (pathname === '/auth/login' && method === 'POST') {
        const { merchantId, pin } = parsedBody;
        if (merchantId === 'warung-maju' && (pin === '123456' || pin.length === 6)) {
          return sendJson(res, 200, {
            token: `mock-jwt-${Date.now()}`,
            expiresIn: 3600
          });
        }
        return sendJson(res, 401, {
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'ID merchant atau PIN salah'
          }
        });
      }

      // 2. GET /merchant/profile
      if (pathname === '/merchant/profile' && method === 'GET') {
        return sendJson(res, 200, {
          id: 'warung-maju',
          name: 'Warung Maju',
          mid: '8801-2290',
          city: 'Jakarta',
          avatarInitials: 'WM'
        });
      }

      // 3. POST /transactions
      if (pathname === '/transactions' && method === 'POST') {
        const idemKey = req.headers['idempotency-key'] || parsedBody.idempotencyKey;
        if (idemKey && idempotencyStore.has(idemKey)) {
          console.log(`  ↪ Idempotency hit: Returning cached result for key ${idemKey}`);
          return sendJson(res, 200, idempotencyStore.get(idemKey));
        }

        const { amount, brand, last4, maskedPan } = parsedBody;
        // SoftPOS Rule: Contactless without PIN limit is Rp 1.000.000 (Regulasi Bank Indonesia)
        const isDeclined = amount > 1000000;
        const randomHex = Math.floor(Math.random() * 0xFFFFFF).toString(16).toUpperCase().padStart(6, '0');
        const id = `CU${randomHex}`;

        const tx = {
          id,
          amount: amount || 0,
          brand: brand || 'Visa',
          last4: last4 || '4821',
          maskedPan: maskedPan || `•••• ${last4 || '4821'}`,
          status: isDeclined ? 'DECLINED' : 'SUCCESS',
          reason: isDeclined ? 'LIMIT_EXCEEDED' : null,
          createdAt: new Date().toISOString()
        };

        transactions.unshift(tx);
        if (idemKey) {
          idempotencyStore.set(idemKey, tx);
        }

        console.log(`  ↪ Transaction created: ${tx.id} [${tx.brand} - Rp ${tx.amount.toLocaleString('id-ID')}] -> ${tx.status}`);
        return sendJson(res, isDeclined ? 200 : 201, tx);
      }

      // 4. GET /transactions
      if (pathname === '/transactions' && method === 'GET') {
        const status = parsedUrl.query.status;
        const query = parsedUrl.query.query;
        let filtered = [...transactions];

        if (status && status !== 'Semua') {
          filtered = filtered.filter(t => t.status.toLowerCase() === status.toLowerCase());
        }

        if (query) {
          const q = query.toLowerCase();
          filtered = filtered.filter(t =>
            t.id.toLowerCase().includes(q) ||
            t.brand.toLowerCase().includes(q) ||
            t.last4.includes(q)
          );
        }

        return sendJson(res, 200, {
          items: filtered,
          page: 1,
          hasMore: false
        });
      }

      // 5. POST /transactions/:id/void
      if (pathname.startsWith('/transactions/') && pathname.endsWith('/void') && method === 'POST') {
        const parts = pathname.split('/');
        const id = parts[2];
        const tx = transactions.find(t => t.id === id);

        if (!tx) {
          return sendJson(res, 404, { error: 'Transaksi tidak ditemukan' });
        }
        if (tx.status !== 'SUCCESS') {
          return sendJson(res, 409, { error: 'Hanya transaksi sukses yang dapat dibatalkan' });
        }

        tx.status = 'VOIDED';
        console.log(`  ↪ Transaction voided: ${id}`);
        return sendJson(res, 200, tx);
      }

      // 6. GET /summary
      if (pathname === '/summary' && method === 'GET') {
        return sendJson(res, 200, {
          totalSalesToday: 2847500,
          todayPercentageDiff: 12,
          todayTransactionCount: transactions.length,
          todayAverageTicket: 237000,
          todaySuccessRate: 92,
          totalSales7d: 15420000,
          weeklyPercentageDiff: 8,
          totalCount7d: 84,
          successRate7d: 93,
          daily7d: [
            { dayName: 'Sen', amount: 1800000 },
            { dayName: 'Sel', amount: 2100000 },
            { dayName: 'Rab', amount: 1950000 },
            { dayName: 'Kam', amount: 2400000 },
            { dayName: 'Jum', amount: 2800000 },
            { dayName: 'Sab', amount: 3100000 },
            { dayName: 'Min', amount: 2847500, isCurrent: true }
          ],
          cardShares: [
            { brand: 'Visa', totalAmount: 7400000, percentage: 48 },
            { brand: 'Mastercard', totalAmount: 4780000, percentage: 31 },
            { brand: 'GPN', totalAmount: 3240000, percentage: 21 }
          ]
        });
      }

      return sendJson(res, 404, { error: 'Not Found' });
    });
  }, latency);
});

server.listen(PORT, () => {
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log(`║      cashUPay Mini — SoftPOS Mock API Server           ║`);
  console.log(`║      Listening on http://localhost:${PORT}                 ║`);
  console.log(`║      Ready for test requests                           ║`);
  console.log('╚════════════════════════════════════════════════════════╝');
});
