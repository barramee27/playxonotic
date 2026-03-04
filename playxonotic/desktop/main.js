const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const https = require('https');
const http = require('http');

if (require('electron-squirrel-startup')) app.quit();

const BACKEND_URL = 'https://playxonotic.com';
const API_BASE = BACKEND_URL + '/api/auth';
const isDev = process.argv.includes('--dev');

const userDataPath = app.getPath('userData');
const tokenPath = path.join(userDataPath, 'auth-token.json');
const userPath = path.join(userDataPath, 'auth-user.json');

function readToken() {
  try {
    const data = JSON.parse(fs.readFileSync(tokenPath, 'utf8'));
    return data.token || null;
  } catch { return null; }
}

function writeToken(token) {
  fs.writeFileSync(tokenPath, JSON.stringify({ token }), 'utf8');
}

function removeToken() {
  try { fs.unlinkSync(tokenPath); } catch {}
}

function readUser() {
  try {
    return JSON.parse(fs.readFileSync(userPath, 'utf8'));
  } catch { return null; }
}

function writeUser(user) {
  fs.writeFileSync(userPath, JSON.stringify(user), 'utf8');
}

function removeUser() {
  try { fs.unlinkSync(userPath); } catch {}
}

function apiRequest(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_BASE + path);
    const isHttps = url.protocol === 'https:';
    const lib = isHttps ? https : http;
    const data = body ? JSON.stringify(body) : null;
    const headers = {
      'Content-Type': 'application/json',
      ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {}),
      ...(token ? { 'Authorization': 'Bearer ' + token } : {}),
    };
    const req = lib.request({
      hostname: url.hostname,
      port: url.port || (isHttps ? 443 : 80),
      path: url.pathname,
      method,
      headers,
    }, (res) => {
      let buf = '';
      res.on('data', (c) => { buf += c; });
      res.on('end', () => {
        try {
          const json = buf ? JSON.parse(buf) : {};
          if (res.statusCode >= 400) {
            reject(new Error(json.error || `HTTP ${res.statusCode}`));
          } else {
            resolve(json);
          }
        } catch (e) {
          reject(new Error('Invalid response'));
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

let loginWindow = null;
let gameWindow = null;

function openGameWindow() {
  if (gameWindow) return;
  const token = readToken();
  const user = readUser();
  if (!token || !user) return;

  const gameUrl = `${BACKEND_URL}/game/darkplaces-wasm.html?token=${encodeURIComponent(token)}&name=${encodeURIComponent(user.username)}`;

  gameWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    title: 'PlayXonotic',
    icon: path.join(__dirname, 'icons', 'icon.png'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
    },
    autoHideMenuBar: true,
    backgroundColor: '#0a0e17',
  });

  gameWindow.loadURL(gameUrl);
  gameWindow.on('closed', () => { gameWindow = null; });
}

function showLoginWindow() {
  if (loginWindow) return;
  loginWindow = new BrowserWindow({
    width: 420,
    height: 520,
    resizable: false,
    title: 'PlayXonotic - Sign In',
    icon: path.join(__dirname, 'icons', 'icon.png'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
    },
    autoHideMenuBar: true,
    backgroundColor: '#1b2838',
  });

  loginWindow.loadFile(path.join(__dirname, 'login.html'));
  loginWindow.on('closed', () => { loginWindow = null; });
}

function startApp() {
  const token = readToken();
  if (!token) {
    showLoginWindow();
    return;
  }
  apiRequest('GET', '/me', null, token).then(() => {
    openGameWindow();
  }).catch(() => {
    removeToken();
    removeUser();
    showLoginWindow();
  });
}

ipcMain.handle('get-token', () => readToken());
ipcMain.handle('set-token', (_e, token) => { writeToken(token); return true; });
ipcMain.handle('remove-token', () => { removeToken(); removeUser(); return true; });
ipcMain.handle('get-user', () => readUser());
ipcMain.handle('set-user', (_e, user) => { writeUser(user); return true; });

ipcMain.handle('auth-login', async (_e, email, password) => {
  const res = await apiRequest('POST', '/login', { email, password });
  return { token: res.token, user: res.user };
});

ipcMain.handle('auth-signup', async (_e, username, email, password) => {
  const res = await apiRequest('POST', '/signup', { username, email, password });
  return { token: res.token, user: res.user };
});

ipcMain.handle('auth-verify', async (_e, token) => {
  const res = await apiRequest('GET', '/me', null, token);
  return res.user;
});

ipcMain.handle('login-success', () => {
  if (loginWindow) {
    loginWindow.close();
    loginWindow = null;
  }
  openGameWindow();
});

ipcMain.handle('get-game-path', () => {
  const resourcePath = process.resourcesPath || path.join(__dirname, '..');
  return path.join(resourcePath, 'game');
});

app.whenReady().then(() => {
  startApp();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) startApp();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
