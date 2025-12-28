### **App Architecture Overview**

The app is built on three pillars: **Direction** (Strategy), **Action** (Tasks & Habits), and **Correction** (Kolb's Reflection).

---

### **Module 1: Strategy & Setup (Quarterly & Monthly)**

_Based on Goal Achievement Framework & Performance Plan._

**1. The Goal Anchor**

- **Medium-Term Goal:** Input your 6–12 month goal.
- **Dissection Tree:** Break the goal down into "Factors" (Knowledge, Skills, Attributes). These factors serve as the **master tags** for every task and reflection in the app.

**2. The Performance Plan (30 & 14 Days)**

- **Sprint Targets:** Define your Top 3 goals for the next 30 days and 14 days.
- **Time Defense:** Set your "Time Availability" status (e.g., "Very Little" or "Decent") to manage expectations.

---

### **Module 2: Priority Task Engine (Daily)**

_Based on your "2 Most Important Tasks" rule and Kolb's Experiment guidelines._

This module is designed to prevent overwhelm. It forces prioritization before execution.

**1. The "Top 2" Dashboard (Home Screen)**

- **The Constraint:** The screen prominently asks: _"What are the 2 most important tasks you need to do?"_
- **Input Rule:** You cannot add a 3rd task to this list until one is completed.
- **Source Selection:** When adding a "Top 2" task, the app offers three sources:
  1.  **New Entry:** Type a fresh task.
  2.  **From Experiments:** Pull a pending experiment from your Kolb's reflections (see Module 5).
  3.  **From Backlog:** Pull from the "Less Important" list.

**2. Subtask View**

- **Drill-Down:** Tapping a "Top 2" task opens a focused "Subtask View."
- **Checklist:** Break the main task into smaller steps here. This keeps the home screen clean.

**3. The "Less Important" Repository**

- **Separate List:** A collapsible section at the bottom for administrative tasks, chores, or "nice-to-haves."
- **Migration:** These never clutter the main view unless you explicitly promote one to the "Top 2."

---

### **Module 3: Habit & Barrier Defense (Daily)**

_Based on Performance Plan (Limiting Habits & Scripted Actions)._

This is not just a checkbox list; it is a defense system against the "Anticipated Barriers" you identified in the Performance Plan.

**1. Limiting Habit Tracker**

- **The "Avoidance" Streaks:** Track the _absence_ of bad habits (e.g., "No doom scrolling").
  - _Setup:_ Input habits from the "Limiting Habits" section of your Performance Plan.
  - _Log:_ Daily Check-in: "Did you succumb to [Habit] today?" (Yes/No).

**2. Scripted Action Protocols**

- **Trigger-Response Logging:**
  - _Setup:_ Input your "Scripted Actions" (e.g., "If distracted -> I will take 3 deep breaths").
  - _Active Tracking:_ A counter for how many times you successfully deployed a script when a barrier arose.
- **Barrier Journal:** A quick-add button to log a new barrier if one catches you off guard. This barrier log becomes data for your next Weekly Audit.

---

### **Module 4: The Weekly Audit (Weekly)**

_Based on Goal Achievement Framework (Steps 3 & 4)._

**1. The "Gap" Analysis**

- **Review:** The app presents the "Factors" from Module 1.
- **Scoring:**
  - Rate **Target Level** (1-10).
  - Rate **Current Level** (1-10).
- **Focus Generator:** The app calculates the gap and suggests: _"Your biggest gap is in [Focus]. This should be the subject of your next Kolb's Cycle."_

---

### **Module 5: The Reflection Forge (Gemini Integration)**

_Based on Guided Kolb's Reflection._

This module automates the feedback loop, turning reflections into tomorrow's "Top 2" tasks.

**1. The Gemini Bridge**

- **Markdown Import:** Paste your full Gemini conversation/grade here.
- **Parsing Engine:** The app scans for specific Markdown headers to extract data:
  - `# Experience` -> Saves to History.
  - `# Experiments` -> **Extracts bullet points as potential Tasks.**

**2. The "Experiment-to-Task" Pipeline**

- After parsing, the app presents the experiments identified by Gemini.
- **Action:** You click "Add to Top 2" or "Add to Backlog."
  - _Why this works:_ Kolb's guide says experiments must be "concise, specific, and actionable." This makes them perfect candidates for your "Top 2" tasks.

**3. Cycle Linking**

- **Tagging:** Associate the reflection with a "Factor" (e.g., "Time Management").
- **Threading:** Mark if this cycle is a "follow-up" to a previous one. This builds a visual chain of your compounding marginal gains.

---

### **Summary of the Integrated Workflow**

1.  **Morning:** Open app. Check **Habit Tracker** (Module 3). Set **Top 2 Tasks** (Module 2).
2.  **During Day:** Work on Top 2. Check off subtasks.
3.  **Barrier Encountered:** You get distracted.
    - _Action:_ Execute "Scripted Action" (e.g., turn off wifi).
    - _Log:_ Open Module 3 and tap "Scripted Action Used."
4.  **End of Day/Event:** You finish a task but felt frustrated.
    - _Action:_ Go to Gemini, run Kolb's prompt on the "frustration."
    - _Integration:_ Paste result into **Module 5**.
    - _Result:_ Gemini suggests an experiment ("Start with easy task for 5 mins"). You click "Add to Top 2 Tasks" for tomorrow.
5.  **Sunday:** Open **Module 4**. Rate your skills. See that "Focus" is lagging. Plan next week's tasks to specifically target "Focus."
