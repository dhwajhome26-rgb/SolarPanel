
<h1 align="center">🌞 SolarPanel</h1>

**Made By DhwaJ_XD**

## 💻 Panel Installation
1. Clone The Repository Or Download:
`git clone https://github.com/teryxlabs/v4panel`

` curl -sL https://deb.nodesource.com/setup_23.x | sudo bash - `

`apt-get install nodejs git`

3. Go To panel Directory:
`cd v4panel`

4. Install Some Importent:
`apt install zip -y && unzip panel.zip`

5. Install Dependencies:
`npm install && npm run seed && npm run createUser`

6. Start The Panel:
`node . # Or Use pm2 To Keep It Online`

---

## ⛓️‍💥 Daemon Installation
1. Clone the repository:
`git clone https://github.com/dragonlabsdev/daemon`

2. go to panel directory:
`cd daemon`

3. Install some importent:
`apt install zip -y && unzip daemon.zip && cd daemon`

5. Install dependencies:
`npm install`

6. Configure DracoDaemon:
- Get your Panel's access key from the panel's config.json file and set it as 'remoteKey'. Do the same for the other way, set your DracoDaemon access key and configure it on the Panel.

7. Start the Daemon:
`node . # or use pm2 to keep it online`

