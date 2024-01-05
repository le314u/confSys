//const Script = require('./modules/Script.mjs')
const { app, BrowserWindow, ipcMain} = require('electron')
const path = require('node:path')
let senha = ''

const createWindow = () => {
    const win = new BrowserWindow({
      width: 800,
      height: 600,
      autoHideMenuBar: true, // Esta opção remove a barra de título
      webPreferences: {
        preload: path.join(__dirname, 'preload.js')
      }
    })
    
    win.loadFile('login.html')

    ipcMain.on('login', (event, pwd) => {
      console.log(pwd)
      senha = pwd
      if(pwd != ''){
        win.webContents.send('refresh', '');
        win.loadFile('index.html')
      }
    })

    ipcMain.on('refresh', (event, pwd) => {
      win.loadFile('index.html')
    })

    ipcMain.on('execute-script', (event, scriptPath) => {
      win.webContents.send('output', 'Olá, processo de renderização foi um sucesso!');

    })




  }


app.whenReady().then(() => {
    createWindow()  
  })

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
  })




class Script{
  constructor(name,about,path){
    this.name = name;
    this.about = about;
    this.path = path;
  }
  getName(){return this.name}
  getAbout(){return this.about}
  getPath(){return this.path}
}
