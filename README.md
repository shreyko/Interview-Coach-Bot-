# Interview Coach Bot

A conversational user interface (CUI) project that simulates a mock interview experience for software engineering internship preparation.  
Built with Flutter for the frontend and Flask with Groq's LLaMA 3 API for the backend.

---

## Project Overview

- **Select a Company**: Google, Amazon, Meta, etc.
- **Choose Interview Type**: Behavioral or Technical.
- **Interact in Real Time**: Submit answers, ask follow-up questions, and get realistic interviewer feedback.
- **Final Summary**: Receive strengths, weaknesses, and improvement tips at the end of the interview.

---

## Technologies Used

- Flutter (Frontend)
- Flask (Backend server)
- Groq API (LLaMA 3 70B model for conversation generation)
- HTTP communication (between app and backend)

---

## Setup Instructions

### 1. Prerequisites

- Install Flutter:  
    [Flutter Setup Instructions Here](https://docs.flutter.dev/get-started/install)

- Install Python 3.7 or later.
- Install required Python packages:
  ```bash
  pip install flask flask-cors groq

## Running the App

### 1. Clone the Repository
```
git clone https://github.com/your-username/interview-coach-bot.git](https://github.com/shreyko/Interview-Coach-Bot-.git
cd interview-coach-bot
```
### 2. Start the Flask Backend Server

Before starting the Flutter app, you must have the backend server running.

From the cloned directory, run:

```bash
python .\lib\AI.py
```
This will start the flask server locally

### 3. Run the Flutter Application

In your cloned directory run the following:
```bash
flutter pub get
flutter ruun
```

