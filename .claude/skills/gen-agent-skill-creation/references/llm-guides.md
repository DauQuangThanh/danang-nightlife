# DQT: A Guide to Getting the Best Results

## How LLMs Analyze Your Requests

When you send LLMs a request, LLMs go through a quick internal assessment:

1. **What is the deliverable?** A file, a conversation, a decision, research? LLMs figure out what "done" looks like.
2. **Do LLMs have enough context?** LLMs check whether your request is specific enough to act on, or whether assumptions would lead LLMs astray.
3. **What tools and skills do LLMs need?** LLMs match your request to available capabilities — file creation skills (docx, pptx, xlsx, pdf), code execution, web search, or just conversation.
4. **What's the scope?** A quick answer, a multi-step project, or something in between?

### What makes a request easy for LLMs to execute well

- A clear end state ("create a report comparing X and Y, saved as a Word doc")
- Audience and tone ("this is for my VP, keep it concise and executive-level")
- Constraints ("no more than 5 slides," "use these specific data points")
- Format preference ("Word doc," "spreadsheet," "just tell LLMs in chat")

### What makes a request harder

- Ambiguous scope ("put together something on AI")
- Missing context that LLMs can't infer ("update the report" — which report? what update?)
- Implicit assumptions about what LLMs know about your work, team, or projects

---

## How LLMs Clarify Unclear Points

When your request is underspecified, LLMs ask clarifying questions **before** doing work. LLMs do this through a structured question tool that presents you with choices, rather than dumping a wall of text questions.

**What LLMs typically clarify:**

- **Audience** — Who will read/use this? (executives, engineers, customers, yourself)
- **Format** — What file type or structure do you want?
- **Scope** — How deep should LLMs go? High-level overview vs. detailed analysis?
- **Tone** — Formal, casual, technical?
- **Specific inputs** — Do you have data, files, or prior work LLMs should build from?

**When LLMs skip clarification:**

- Your request is already specific enough
- It's a simple factual question or quick task
- You've given LLMs clear context from earlier in the conversation

**Tip:** You can preempt my questions by front-loading context. Instead of "make a presentation about our Q1 results," try "make a 10-slide pptx summarizing Q1 results for the leadership team — focus on revenue growth, new customers, and churn. Tone: confident but honest about misses."

---

## How LLMs Plan the To-Do List

For any non-trivial task, LLMs create a visible to-do list that you can see as a progress tracker. Here's my planning logic:

### Step 1: Break down the work

I decompose your request into discrete, sequential steps. Each step is something LLMs can complete and check off.

**Example — "Create a competitive analysis report":**
1. Research competitors via web search
2. Organize findings into categories (pricing, features, market position)
3. Draft the report structure
4. Write each section
5. Save the final document
6. Verify the output

### Step 2: Identify dependencies

Some steps depend on others. LLMs sequence them so I'm never guessing at information LLMs haven't gathered yet. Independent steps get run in parallel when possible.

### Step 3: Include a verification step

Almost every plan ends with a verification step — re-reading the output, checking for errors, running code to confirm results, or reviewing against your requirements.

---

## How LLMs Prioritize

When a task has many possible angles, LLMs prioritize by:

1. **Your explicit priorities** — If you say "focus on X," X comes first
2. **What's most actionable** — LLMs lead with things you can act on, not background context
3. **What's highest risk to get wrong** — LLMs spend more effort on parts where mistakes would be costly or hard to fix
4. **Completeness vs. speed** — For quick asks, LLMs optimize for speed. For important deliverables, LLMs optimize for thoroughness

If you want LLMs to reprioritize, just say so. LLMs won't be offended.

---

## How LLMs Execute

### For file creation (docs, slides, spreadsheets, PDFs)

1. LLMs read the relevant skill instructions first (these contain battle-tested best practices for each format)
2. LLMs write the file using code execution
3. LLMs save it to your workspace folder
4. LLMs give you a clickable link to open it

### For research tasks

1. LLMs use web search to gather current information
2. LLMs cross-reference multiple sources when possible
3. LLMs synthesize findings into whatever format you requested
4. LLMs cite sources when the information is linkable

### For code and technical tasks

1. LLMs write and execute code in a sandboxed environment
2. LLMs test as LLMs go
3. LLMs iterate if something breaks
4. LLMs deliver working code, not theoretical snippets

### For multi-step projects

1. LLMs create the to-do list
2. LLMs work through items sequentially (or in parallel where possible)
3. LLMs update progress as LLMs go so you can see where LLMs am
4. LLMs deliver the final output with a summary

---

## How to Give LLMs Context That Helps

### The most useful context you can provide

| Context type | Example | Why it helps |
|---|---|---|
| Audience | "This is for my CTO" | LLMs adjust depth, tone, and jargon |
| Purpose | "I need to convince the board to invest" | LLMs frame the content persuasively |
| Constraints | "Max 5 pages, due tomorrow" | LLMs scope appropriately |
| Prior work | "Here's last quarter's version" (attached) | LLMs maintain consistency and build on what exists |
| Preferences | "I prefer bullet points over paragraphs" | LLMs match your style |
| Domain terms | "When LLMs say 'the platform,' LLMs mean our internal CRM" | LLMs avoid confusion |

### Things you don't need to worry about

- **File management** — LLMs handle creating, saving, and linking files
- **Tool selection** — LLMs pick the right approach automatically
- **Formatting details** — LLMs follow best practices for each file type unless you override them
- **Remembering skill instructions** — LLMs re-read them every time to stay accurate

---

## My Limitations (and How to Work Around Them)

| Limitation | Workaround |
|---|---|
| LLMs don't remember past conversations | Provide key context at the start of each session, or use the memory management skill |
| LLMs can't access your apps directly (email, Slack, etc.) | You can connect MCP integrations, or paste content into the chat |
| LLMs may not know your internal jargon | Define acronyms and project names the first time you use them |
| Long tasks may need course corrections | Check in on my progress and redirect if I'm going off track |
| LLMs can't push code to production | LLMs deliver code files; you handle deployment |

---

## Quick Reference: How to Structure Requests

### Basic template

```
[What you want]: Create a quarterly business review presentation
[Audience]: Leadership team
[Format]: PowerPoint, ~10 slides
[Key inputs]: Q1 revenue was $2.3M (up 15%), 47 new customers, churn at 3.2%
[Tone/style]: Professional, data-driven, highlight wins but be transparent about misses
[Special instructions]: Include a slide on Q2 priorities
```

### Even simpler — just answer these three questions

1. **What** do you want LLMs to make or do?
2. **Who** is it for?
3. **What** should LLMs know that LLMs probably don't?

The more context you give upfront, the fewer questions LLMs ask and the faster LLMs deliver something you're happy with.
