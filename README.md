<div align="center">

# 🎧 YUKI YT Downloader API

### ⚡ Advanced Media Streaming & Downloading Engine

<p>
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&pause=1000&color=6C63FF&center=true&vCenter=true&multiline=true&repeat=true&width=600&height=60&lines=FastAPI+YouTube+Downloader;Direct+Audio+and+Video+Streaming;Smart+Media+Caching+System+⚡" alt="Typing SVG" />
</p>

<p>
  <a href="https://github.com/SUDEEPBOTS/Downloader/stargazers"><img src="https://img.shields.io/github/stars/SUDEEPBOTS/Downloader?style=for-the-badge&logo=github&color=6C63FF&logoColor=white" alt="Stars"></a>
  <a href="https://github.com/SUDEEPBOTS/Downloader/network/members"><img src="https://img.shields.io/github/forks/SUDEEPBOTS/Downloader?style=for-the-badge&logo=git&color=FF6B6B&logoColor=white" alt="Forks"></a>
  <a href="https://github.com/SUDEEPBOTS/Downloader/issues"><img src="https://img.shields.io/github/issues/SUDEEPBOTS/Downloader?style=for-the-badge&logo=github&color=FFC93C&logoColor=white" alt="Issues"></a>
</p>

<p>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white" alt="FastAPI">
  <img src="https://img.shields.io/badge/Python-3.11-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/yt--dlp-FF0000?style=flat-square&logo=youtube&logoColor=white" alt="YT-DLP">
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker">
</p>

---

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">

</div>

## 🎯 What is YUKI YT Downloader?

**YUKI YT API** is a high-performance backend server built with FastAPI and `yt-dlp`. It allows seamless downloading and streaming of YouTube audio and video directly through HTTP endpoints.

The system features a **Smart Caching Engine** that temporarily stores downloaded media to serve repeated requests instantly without re-downloading! 🚀

<div align="center">
<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%">
</div>

## ✨ Features

<table>
<tr>
<td>

### 🛠️ Media Engine
- Extract from ANY YouTube URL
- Direct audio/video streaming
- Token-based secure downloads
- Uses latest `yt-dlp`

</td>
<td>

### ⚡ Smart Caching
- Caches downloaded files
- Instant replay for cached files
- Tracks total download stats
- Automatic background caching

</td>
</tr>
<tr>
<td>

### 🚀 API Endpoints
- `/download` - Generate secure tokens
- `/stream/{id}` - Stream media
- `/stats` - View API usage stats
- FAST asynchronous responses

</td>
<td>

### ☁️ Cloud Ready
- Dockerized deployment
- Heroku `app.json` support
- Render & Koyeb deployment
- Uses SQLite for stats

</td>
</tr>
</table>

<div align="center">
<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%">
</div>

## 🚀 Deployment

### ☁️ One-Click Deploy

Easily deploy the API 24/7 on your favorite cloud platform!

<p align="left">
  <a href="https://heroku.com/deploy?template=https://github.com/SUDEEPBOTS/Downloader">
    <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy to Heroku">
  </a>
  &nbsp;
  <a href="https://render.com/deploy?repo=https://github.com/SUDEEPBOTS/Downloader">
    <img src="https://render.com/images/deploy-to-render-button.svg" alt="Deploy to Render">
  </a>
  &nbsp;
  <a href="https://app.koyeb.com/deploy?type=git&repository=github.com/SUDEEPBOTS/Downloader&branch=main&name=yuki-yt-api">
    <img src="https://www.koyeb.com/static/images/deploy/button.svg" alt="Deploy to Koyeb">
  </a>
</p>

### ⚡ Local Quick Setup

```bash
# 1️⃣ Clone the repository
git clone https://github.com/SUDEEPBOTS/Downloader.git
cd Downloader

# 2️⃣ Install dependencies
pip install -r requirements.txt

# 3️⃣ Run the API
uvicorn YUKIYTAPI.main:app --host 0.0.0.0 --port 8000
```

<div align="center">
<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%">
</div>

## 🛡️ Tech Stack

| Technology | Purpose |
|:-----------|:--------|
| **FastAPI** | High-performance async web framework |
| **yt-dlp** | Core media extraction engine |
| **SQLite3** | Lightweight database for stats |
| **Uvicorn** | ASGI server for FastAPI |

<div align="center">
<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%">
</div>

## 📜 License

This project is open source and available under the Proprietary License. See [LICENSE](LICENSE) for details.

---

<div align="center">

### ⭐ Star this repo if you found it useful!

<p>
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=500&size=18&pause=1000&color=6C63FF&center=true&vCenter=true&repeat=true&width=400&height=30&lines=Made+with+%E2%9D%A4%EF%B8%8F+by+SUDEEPBOTS" alt="Footer" />
</p>

<a href="https://github.com/SUDEEPBOTS">
  <img src="https://img.shields.io/badge/GitHub-SUDEEPBOTS-181717?style=for-the-badge&logo=github" alt="GitHub">
</a>
<a href="https://t.me/SUDEEPBOTS">
  <img src="https://img.shields.io/badge/Telegram-SUDEEPBOTS-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram">
</a>

</div>
