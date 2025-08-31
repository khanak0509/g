GenieBot 🤖
GenieBot is a powerful multifunctional AI assistant built using cutting-edge technologies including LangChain, LangGraph, and Google Generative AI. It serves as a comprehensive automation and productivity tool, seamlessly integrating with various services like GitHub, Google Workspace, communication platforms, and information services.
🌟 Key Features
1. GitHub Integration 🔧
Repository Management: Fetch issues, pull requests, and repository files
Create, update, and delete files and branches
Advanced code and issue search capabilities
Automated review request creation
2. Google Workspace Integration 📊
Google Calendar: View upcoming events, create & manage events
Google Forms: AI-powered form generation from topics
Automated email distribution of forms
Response analysis via Google Sheets integration
3. Communication Tools 📨
Email Integration: Send emails via Gmail SMTP, professional composition
SMS Capabilities: Message dispatch through Twilio
Automated notifications
4. AI & Knowledge Tools 🤖
Resume Analysis: Parse PDF resumes, generate LinkedIn content
Information Retrieval: Wikipedia queries, YouTube search
Real-time Data: Weather updates via OpenWeatherMap API
5. Additional Features ⚡
Real-time date and time tracking
Tavily search integration
Cross-platform compatibility
🛠 Prerequisites
Before running GenieBot, ensure you have:
Python 3.8+
Git
Google Cloud Platform account
Twilio account (for SMS features)
OpenWeatherMap API key
GitHub account with necessary permissions
⚡ Installation
Clone the repository:
```
git clone https://github.com/khanak0509/GenieBot.git
cd GenieBot
```
Set up a virtual environment:
```
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
```
Install dependencies:
```
pip install -r requirements.txt
```
Configure API Keys:
Create a .env file in the project root with:
```
GITHUB_TOKEN=your_github_token
GOOGLE_API_KEY=your_google_api_key
OPENWEATHER_API_KEY=your_weather_api_key
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
```
Set up Google Cloud credentials:
Download your Google Cloud credentials JSON file
Place it in the project root as client_secret.json
🚀 Usage
Start the bot:
```
python main.py
```
Available Commands:
GitHub operations: github help
Calendar operations: calendar help
Forms operations: forms help
Resume parsing: resume parse <file_path>
Weather check: weather <city_name>
Wikipedia search: wiki <query>
YouTube search: youtube <query>
📂 Project Structure
```
GenieBot/
├── main.py              # Entry point
├── tools/               # Tool implementations
│   ├── github_tools.py  # GitHub integration
│   ├── google_tools.py  # Google services
│   ├── comm_tools.py    # Communication tools
│   └── ai_tools.py      # AI implementations
├── config/              # Configuration files
├── utils/               # Utility functions
└── tests/               # Test suite
```
🔒 Security Notes
Never commit secrets like API keys, OAuth tokens, or Firebase plist/JSON files.
Use .env for local environment variables.
Keep credentials like client_secret.json local and add them to .gitignore.
🤝 Contributing
Fork the repository
Create a new branch: git checkout -b feature/my-feature
Make your changes
Commit your changes: git commit -m "Add my feature"
Push to branch: git push origin feature/my-feature
