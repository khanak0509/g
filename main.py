

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uuid


import firebase_admin
from firebase_admin import credentials, firestore
if not firebase_admin._apps:
    cred = credentials.Certificate("automate-genie-48cb3-firebase-adminsdk-fbsvc-04d9a2172d.json")
    firebase_admin.initialize_app(cred)
db = firestore.client()


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from langchain_community.agent_toolkits.github.toolkit import GitHubToolkit
from langchain_community.utilities.github import GitHubAPIWrapper
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import Tool
from langchain_community.tools import YouTubeSearchTool
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import ToolNode, tools_condition
from datetime import datetime, time
import httpx
import ast
import os
from langchain.tools import tool
from langchain_community.utilities import GoogleSerperAPIWrapper
from langchain_community.tools import WikipediaQueryRun
from langchain_community.utilities import WikipediaAPIWrapper
from langchain_community.utilities.twilio import TwilioAPIWrapper
from twilio.rest import Client
from langchain_core.prompts import PromptTemplate
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
from langchain_tavily import TavilySearch
from langgraph.checkpoint.sqlite import SqliteSaver
import sqlite3
from langchain_google_community import CalendarToolkit
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_core.output_parsers import StrOutputParser


con = sqlite3.connect('chatbot.db',check_same_thread=False)
checkpointer = SqliteSaver(conn=con)


wikipedia = WikipediaQueryRun(api_wrapper=WikipediaAPIWrapper())


import getpass
from dotenv import load_dotenv
load_dotenv()
memory = MemorySaver()
youtube = YouTubeSearchTool()
os.environ["TAVILY_API_KEY"]= os.getenv('TAVILY_API_KEY')

ACCOUNT_SID=os.getenv('TWILIO_ACCOUNT_SID')
AUTH_TOKEN=os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_NUMBER=os.getenv('TWILIO_PHONE_NUMBER')

client = Client(ACCOUNT_SID, AUTH_TOKEN)

sender_email = os.getenv('SENDER_EMAIL')
sender_password = os.getenv('SENDER_PASSWORD')


from langchain_google_community import CalendarToolkit
from langchain_google_community.calendar.utils import (
    build_resource_service,
    get_google_credentials,
)


# search = GoogleSerperAPIWrapper()
# google_search = [
#     Tool(
#         name="Intermediate_Answer",
#         func=search.run,
#         description="useful for when you need to ask with search",
#     )
# ]


os.environ["GOOGLE_API_KEY"] = os.getenv('GOOGLE_API_KEY')

llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",
    temperature=0,
    timeout=None,
    max_retries=2,
)

for env_var in [
    "GITHUB_APP_ID",
    "GITHUB_APP_PRIVATE_KEY",
    "GITHUB_REPOSITORY",
]:
    if not os.getenv(env_var):
        os.environ[env_var] = getpass.getpass(f"Enter {env_var}: ")

github = GitHubAPIWrapper()
toolkit = GitHubToolkit.from_github_api_wrapper(github)

tools = toolkit.get_tools()

@tool
def mail(email: str,subject:str,main:str) -> dict:
    """send email"""
    smtp_server = 'smtp.gmail.com'
    smtp_port = 587
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From']= sender_email
    msg['To']= email
    msg.attach(MIMEText(main, "plain"))
    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
                server.starttls()
                server.login(sender_email, sender_password)
                server.send_message(msg)
                return "sent successfull"
    except smtplib.SMTPAuthenticationError:
            return "Failed to authenticate with the SMTP server. Check your email and password."
import requests
import requests
import ast
from langchain.prompts import PromptTemplate
from langchain_core.tools import tool

@tool
def google_form_link(topic_of_form: str):
    """
    Creates a Google Form based on a topic using AI and returns the form link
    """

    prompt = PromptTemplate(
        template="""
        You are a Google Form creator. 
        Generate 3-5 questions for a form on this topic: {topic_of_form}

        Format the output as a valid JSON list only, no explanations, no code fences.
        Example:
        [
            {{"type": "mcq", "title": "How satisfied are you?", "choices": ["Very satisfied", "Satisfied", "Neutral", "Dissatisfied"]}},
            {{"type": "text", "title": "Any suggestions for us?"}}
        ]
        """,
        input_variables=["topic_of_form"]
    )

    chain = prompt | llm
    response = chain.invoke({"topic_of_form": topic_of_form})

    if hasattr(response, "content"):  
        text_response = response.content
    else:  
        text_response = response.get("text", "")

    text_response = text_response.strip()
    if text_response.startswith("```"):
        text_response = text_response.split("```")[1]  
        if "\n" in text_response:
            text_response = text_response.split("\n", 1)[1]  
        text_response = text_response.strip("`").strip()

    try:
        questions = ast.literal_eval(text_response)
    except Exception as e:
        raise ValueError(f"Could not parse cleaned LLM output: {text_response}") from e

    data = {
        "title": f"{topic_of_form} Form",
        "questions": questions
    }
    web_app_url='https://script.google.com/macros/s/AKfycbycF2ZE_06pCQ_jZs7Epl7JxJ-h2yhCQrI9cr9PeZb_njD5iIrzGdjoTRIHORjoHLKNWQ/exec'

    response = requests.post(web_app_url, json=data)
    return response.text


@tool
def send_google_form(email: str, subject: str, main: str, form_link: str, sender_email: str):
    """Send Google Form link via email"""
    import smtplib
    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText

    smtp_server = 'smtp.gmail.com'
    smtp_port = 587

    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = email
    msg.attach(MIMEText(f"{main}\n\nPlease fill the form: {form_link}", "plain"))

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.send_message(msg)
            return "Email sent successfully!"
    except smtplib.SMTPAuthenticationError:
        return "Failed to authenticate with the SMTP server. Check your email and password."


@tool
def resume(path):
    """This tool makes a portfolio from a PDF resume path"""
    loder = PyPDFLoader(
        path
    )
    docs_list = loder.load() 
    docs=  " ".join([doc.page_content for doc in docs_list])

    promt = PromptTemplate(
        template="""You are an expert career advisor and LinkedIn profile writer. 
I will provide you a professional resume. 
Your task is to generate high-quality content for all sections of a LinkedIn profile based on this resume.

Follow these rules:

1. **About Section:** Write a concise, professional, and engaging summary (3-5 sentences) that highlights skills, experience, and career goals. Use plain text; do not use Markdown, bold, or asterisks.  

2. **Experience Section:** For each job or project in the resume, provide:
   - Job/Project Title
   - Company/Organization (if any)
   - Dates (optional)
   - 2-3 bullet points summarizing achievements and responsibilities. Use hyphens (-) for bullets, not stars or asterisks.

3. **Education Section:** List degrees, institutions, and graduation years (if available). Use plain text.

4. **Skills Section:** List all relevant skills in a comma-separated list.

5. **Accomplishments/Certifications Section:** Include awards, certifications, notable achievements, competitions, or recognitions.

6. **Recommendations for Headline:** Suggest 1-2 professional headlines that summarize the user’s expertise and career goals.

7. **Contact Section (optional):** Suggest ways a recruiter can contact you professionally (email, LinkedIn link).

**Formatting rules:**
- Plain text only. No Markdown, asterisks, or special formatting.
- Use clear headings for each section: About, Experience, Education, Skills, Accomplishments, Headline, Contact.
- Make it concise, readable, and professional.  

***example***
Headline : B.tech'28@IIT JODHPUR | bakckend & flutter developer | passioate about genai | agentic ai & open source 
about : I'm Khanak Khandelwal, a second-year B.Tech student at IIT Jodhpur, driven by a passion for building intelligent, scalable, and impactful tech solutions. My interests lie at the intersection of software development and artificial intelligence, with a strong focus on deep learning, computer vision, and autonomous systems.
I have hands-on experience in backend and mobile app development, leveraging technologies like Python, FastAPI, Flutter, and Firebase to build robust, user-focused applications. I’m particularly fascinated by cutting-edge domains such as Generative AI (GANs), Agentic AI, and AI automation, and I am always exploring how these technologies can be leveraged to create impactful, real-world solutions. 
My technical toolkit includes frameworks and tools like PyTorch, TensorFlow, OpenCV, LangChain, and LangGraph, which I use to build scalable and innovative AI systems.
Driven by a desire to innovate, I enjoy solving complex problems and collaborating on projects that push the boundaries of what's possible. I'm actively seeking opportunities to apply my skills and contribute to teams that are shaping the future of technology.

current position : contributor in gssoc

education : IIT JODHPUR
location : INDIA
city: jaipur ,rajasthan
skills : langgraph , langchain , genai, andriod dev, computer vision , flutter , dart , fastapi , tensorflow , keras , deepleaening , sckitlearn , numpy , pandas , python , c++

if any place is not there is leave it 

Here is the resume:
{resume}

""",
    input_variables=['resume']
    )
    parser = StrOutputParser()

    chain = promt | llm | parser
    result =chain.invoke({
        'resume' : docs
    })

    return result






@tool
def date_time() -> str:
    """Returns the current date and time."""
    return datetime.now().strftime("Current time: %Y-%m-%d %H:%M:%S")

@tool
def get_weather(city: str = "Jodhpur") -> str:
    """Returns current weather for a given city using OpenWeatherMap API."""
    api_key = "c6374f01fc1f66e699b8a8704e5574a7"
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
    response = httpx.get(url).json()
    
    if "main" in response:
        temp = response["main"]["temp"]
        description = response["weather"][0]["description"]
        return f"The current temperature in {city} is {temp}°C with {description}."
    else:
        return f"Couldn't fetch weather data for {city}."
    

@tool
def send_sms(to_number,msg):
    """Sends an SMS message to a specified phone number."""
    try:
        message = client.messages.create(
                    to=to_number,
                    from_=TWILIO_NUMBER,
                    body=msg
                )
        return f"Message sent successfully. SID: {message.sid}"
    except Exception as e:
        return f"Failed to send SMS: {str(e)}"


# for tool in tools:
#     print(tool.name)


filter_list = [
    "Get Issue", "Comment on Issue", "List open pull requests (PRs)",
    "Get Pull Request", "Overview of files included in PR", "Create Pull Request",
    "List Pull Requests' Files", "Create File", "Read File", "Update File", "Delete File",
    "Overview of existing files in Main branch", "Overview of files in current working branch",
    "List branches in this repository", "Set active branch", "Create a new branch",
    "Get files from a directory", "Search issues and pull requests", "Search code",
    "Create review request"
]

tools = [tool for tool in toolkit.get_tools() if tool.name in filter_list]
tools.append(date_time)
tools.append(get_weather)
tools.append(youtube)
tools.append(wikipedia)
tools.append(send_sms)
tools.append(mail)
tools.append(TavilySearch(max_results=2))
tools.append(resume)
tools.append(google_form_link)
tools.append(send_google_form)
print("Filtered tools:", [t.name for t in tools])
print("Number of tools found:", len(tools))

rename_map = {
    "Get Issue": "get_issue",
    "Comment on Issue": "comment_issue",
    "List open pull requests (PRs)": "list_open_prs",
    "Get Pull Request": "get_pull_request",
    "Overview of files included in PR": "overview_files_pr",
    "Create Pull Request": "create_pr",
    "List Pull Requests' Files": "list_pr_files",
    "Create File": "create_file",
    "Read File": "read_file",
    "Update File": "update_file",
    "Delete File": "delete_file",
    "Overview of existing files in Main branch": "overview_main_files",
    "Overview of files in current working branch": "overview_branch_files",
    "List branches in this repository": "list_branches",
    "Set active branch": "set_active_branch",
    "Create a new branch": "create_branch",
    "Get files from a directory": "get_files_dir",
    "Search issues and pull requests": "search_issues_prs",
    "Search code": "search_code",
    "Create review request": "create_review_request"
}

for tool in tools:
    if tool.name in rename_map:
        tool.name = rename_map[tool.name]

print("Renamed tools:", [t.name for t in tools])

config = {"configurable": {"thread_id": "1"}}

agent_executor = create_react_agent(llm, tools,checkpointer= checkpointer,
                                    
                                    

                                    )



class ChatRequest(BaseModel):
    user_id: str  
    query: str


@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    try:
        events = agent_executor.stream(
            {"messages": [("user", req.query)]},
            config=config,
            recursion_limit=50,
            stream_mode="values",
            
        )

        response_text = ""
        for event in events:
            if "messages" in event:
                response_text = event["messages"][-1].content  

        print("Response:", response_text)

        chat_ref = db.collection("users").document(req.user_id).collection("chats").document()
        chat_ref.set({
            "query": req.query,
            "response": response_text,
            "timestamp": datetime.now().isoformat()
        })

        return {"response": response_text}
    except Exception as e:
        return {"error": str(e)}
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)


