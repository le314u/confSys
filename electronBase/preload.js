const { contextBridge, ipcRenderer } = require('electron');

// Expor ipcRenderer
contextBridge.exposeInMainWorld('ipcRenderer', {
  send: (channel, data) => {
    // Permitir apenas mensagens específicas
    const validChannels = ['execute-script','login','refresh'];
    if (validChannels.includes(channel)) {
      ipcRenderer.send(channel, data);
    }
  },
  receive: (channel, func) => {
    const validChannels = ['script-output', 'script-execution-error','create','output','refresh'];
    if (validChannels.includes(channel)) {
      ipcRenderer.on(channel, (event, ...args) => func(...args));
    }
  }
});

// Expor versões
contextBridge.exposeInMainWorld('versions', {
  node: () => process.versions.node,
  chrome: () => process.versions.chrome,
  electron: () => process.versions.electron
});
