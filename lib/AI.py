from flask import Flask, request, jsonify
from flask_cors import CORS
from groq import Groq

app = Flask(__name__)
CORS(app)

client = Groq(api_key="INSERT YOUR GROQ API KEY HERE")


@app.route("/submit_answer", methods=["POST"])
def submit_answer():
    data = request.json
    company = data.get("company")
    input_text = data.get("input")
    log = data.get("log", [])

    full_log = "\n".join([f"{m['role'].capitalize()}: {m['text']}" for m in log])
    prompt = f"""
You are a strict technical interviewer at {company}. Continue the interview based on the candidate's latest response.

Conversation so far:
{full_log}

Candidate's latest response:
{input_text}

Respond as a real interviewer. Ask a follow-up question or make a related observation.
"""

    response = client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama3-70b-8192",
        stream=False
    )
    return jsonify({"reply": response.choices[0].message.content.strip()})


@app.route("/ask_interviewer", methods=["POST"])
def ask_interviewer():
    data = request.json
    input_text = data.get("input")
    log = data.get("log", [])

    full_log = "\n".join([f"{m['role'].capitalize()}: {m['text']}" for m in log])
    prompt = f"""
You are a knowledgeable interviewer currently engaged in a mock interview.

This is the conversation log so far:
{full_log}

The candidate has now asked a question:
{input_text}

Answer clearly and professionally as the interviewer and ensure you do not give any hints much like a real interviewer unless you truly feel that the candidate is struggling or explicitly asking for it.
"""

    response = client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama3-70b-8192",
        stream=False
    )
    return jsonify({"reply": response.choices[0].message.content.strip()})



@app.route("/end_interview", methods=["POST"])
def end_interview():
    data = request.json
    company = data.get("company")
    log = data.get("log", [])

    full_log = "\n".join([f"{m['role'].capitalize()}: {m['text']}" for m in log])
    prompt = f"""
You are an experienced technical interviewer.

Below is the entire conversation from a mock interview with a candidate applying at {company}:

{full_log}

Now that the interview has concluded, please summarize:
1. Overall impression
2. Candidate's strengths
3. Candidate's weaknesses
4. Final advice or tips for improvement

Also make sure your report does not use ** ** to show something as bold. In fact do not bold any words.
"""

    response = client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama3-70b-8192",
        stream=False
    )
    return jsonify({"summary": response.choices[0].message.content.strip()})


@app.route("/get_question", methods=["POST"])
def get_question():
    data = request.json
    company = data.get("company")
    category = data.get("category")

    prompt = f"""
You are an interviewer at {company}. Ask the first {category.lower()} interview question to a candidate applying for a software engineering internship.
Act like a real interviewer do not give the candidate more context than what they need, and make sure you only give the question and no other information.
"""

    response = client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama3-70b-8192",
        stream=False
    )

    return jsonify({"question": response.choices[0].message.content.strip()})

if __name__ == "__main__":
    app.run(debug=True)
