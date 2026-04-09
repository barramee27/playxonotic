const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  getToken: () => ipcRenderer.invoke('get-token'),
  setToken: (token) => ipcRenderer.invoke('set-token', token),
  removeToken: () => ipcRenderer.invoke('remove-token'),
  getUser: () => ipcRenderer.invoke('get-user'),
  setUser: (user) => ipcRenderer.invoke('set-user', user),
  authLogin: (email, password) => ipcRenderer.invoke('auth-login', email, password),
  authSignup: (username, email, password) => ipcRenderer.invoke('auth-signup', username, email, password),
  authVerify: (token) => ipcRenderer.invoke('auth-verify', token),
  loginSuccess: () => ipcRenderer.invoke('login-success'),
  getGamePath: () => ipcRenderer.invoke('get-game-path'),
  getPlatform: () => process.platform,
});
