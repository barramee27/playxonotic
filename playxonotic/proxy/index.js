require('dotenv').config();
const dgram = require('dgram');
const { WebSocketServer } = require('ws');

const WS_PORT = parseInt(process.env.WS_PORT) || 27960;
const GAME_HOST = process.env.GAME_SERVER_HOST || '127.0.0.1';
const GAME_PORT = parseInt(process.env.GAME_SERVER_PORT) || 26000;

const wss = new WebSocketServer({ port: WS_PORT });

console.log(`WebSocket proxy listening on port ${WS_PORT}`);
console.log(`Forwarding to game server at ${GAME_HOST}:${GAME_PORT}`);

wss.on('connection', (ws, req) => {
  const clientAddr = req.socket.remoteAddress;
  console.log(`Client connected: ${clientAddr}`);

  // Disable Nagle's algorithm to reduce latency
  if (ws._socket && ws._socket.setNoDelay) {
    ws._socket.setNoDelay(true);
  }

  // Create a UDP socket for this WebSocket client
  const udpSocket = dgram.createSocket('udp4');
  let alive = true;

  // Forward WebSocket messages → UDP
  ws.on('message', (data) => {
    if (!alive) return;
    const buf = Buffer.isBuffer(data) ? data : Buffer.from(data);
    udpSocket.send(buf, 0, buf.length, GAME_PORT, GAME_HOST, (err) => {
      if (err) console.error(`UDP send error for ${clientAddr}:`, err.message);
    });
  });

  // Forward UDP responses → WebSocket
  udpSocket.on('message', (msg) => {
    if (!alive) return;
    if (ws.readyState === ws.OPEN) {
      ws.send(msg);
    }
  });

  udpSocket.on('error', (err) => {
    console.error(`UDP socket error for ${clientAddr}:`, err.message);
    cleanup();
  });

  ws.on('close', () => {
    console.log(`Client disconnected: ${clientAddr}`);
    cleanup();
  });

  ws.on('error', (err) => {
    console.error(`WebSocket error for ${clientAddr}:`, err.message);
    cleanup();
  });

  function cleanup() {
    if (!alive) return;
    alive = false;
    try { udpSocket.close(); } catch {}
    try { ws.close(); } catch {}
  }
});

wss.on('error', (err) => {
  console.error('WebSocket server error:', err.message);
});
