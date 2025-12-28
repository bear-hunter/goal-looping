Marginal Gains App: Master Development Guide
1. Project Vision & Philosophy
Core Identity: "The Operating System for Continuous Improvement." Unlike standard to-do lists (like HabitNow) or mood journals (like Proddy), Marginal Gains is a closed-loop system. It connects Strategy (Direction) to Action (Daily work) to Correction (Reflection), ensuring that every action serves a larger goal and every failure becomes a lesson.

Pillar 1: Strategy (The Map): Breaking big goals into specific Factors (Knowledge, Skills, Attributes).

Pillar 2: Action (The Engine): A robust Task & Habit manager that executes the strategy.

Pillar 3: Correction (The Compass): Kolb’s Experiential Learning Cycle to analyze performance and generate new "Experiments" (Tasks).

2. Feature Expansion: "HabitNow" & "Proddy" Integration
To match top-tier market standards, the "Action" module must be significantly upgraded while remaining tied to the "Strategy."

A. Advanced Habit Engine (The "HabitNow" Standard)
Flexible Scheduling:

Specific Days: (e.g., "Gym on Mon, Wed, Fri").

Frequency: (e.g., "Read 3 times per week").

Repetition: (e.g., "Drink water 5 times a day").

Habit Types:

Build (Positive): "Run 5km" (Track completion).

Quit (Negative): "No Social Media" (Track avoidance/clean time).

Timed: "Meditate for 10 mins" (Integrated countdown timer).

Data Model Addition: "Streak Freeze" (allow 1 skip without breaking streak).

B. Psychological Depth (The "Proddy" Standard)
"The Why": Every habit must have a linked "Motivation" field (e.g., "I run to have energy for my kids"). Display this during the daily check-in.

Mood & Barrier Logging: When checking off a habit (or missing one), prompt for a quick mood rating or "Barrier Tag" (e.g., "Tired", "No Time"). This feeds into the Weekly Audit.

3. The "Connected System" Architecture
This is the most critical logic for the AI to understand. The tabs are not separate apps; they are different views of the same data.

Connection 1: The "Factor" is the Anchor
Every Task, Habit, and Reflection MUST be linked to a specific Factor (e.g., "Time Management").

The "Work Volume" Meter:

Logic: We do not auto-calculate "Competence" (User does that manually). Instead, we calculate "Effort/Volume."

Visual: On the Strategy Screen, each Factor (e.g., "Coding Skill") gets a progress ring or heat map.

Formula: (Completed Tasks linked to Factor) + (Habit Reps linked to Factor) + (Reflections linked to Factor).

User Feedback: "Wow, I've put 15 units of effort into 'Coding' this week."

Connection 2: The Reflection "Detail View" & History
Current Issue: Users can't see past reflection details.

Reflection History Screen: A list view of past cycles.

Reflection Detail Screen: A read-only view of a saved cycle showing:

The "Experience" (What happened).

The "Abstraction" (The pattern identified).

The Output: The "Experiments" that were generated from this reflection and their current status (Pending/Done).

Connection 3: Explicit Criteria for Levels
Current Issue: Users rate themselves 1-10 but forget what "7/10" means.

Data Model Update: The Factor model needs specific text fields for "Level 10 Definition" (Target Criteria) and "Level 1 Definition" (Starting Point).

4. Technical Implementation Roadmap
Phase 1: Data Model Refinement (Hive)
The AI must update lib/models/ to support the new features.

1. Update Factor Model:

Dart

@HiveField(8) String targetDescription;  // "What does Level 10 look like?"
@HiveField(9) String currentDescription; // "Why am I currently at Level 3?"
// Derived Getter
int get totalEffortUnits => linkedTaskIds.length + linkedHabitIds.length;
2. Update Habit Model:

Dart

@HiveField(6) String factorId;          // Link to Strategy
@HiveField(7) List<int> scheduledDays;  // [1, 3, 5] (Mon, Wed, Fri)
@HiveField(8) int targetFrequency;      // e.g., 3 times per day/week
@HiveField(9) String motivation;        // "The Why"
@HiveField(10) bool isNegative;         // true = Avoidance Habit
3. Update Reflection Model:

Dart

// Ensure linking to Factors is mandatory or strongly encouraged
@HiveField(5) List<String> linkedFactorIds; 
Phase 2: UI/UX Improvements
1. The "Factor Detail" Sheet:

When a user clicks a Factor in "Strategy," open a sheet showing:

Target vs. Current Level.

History: A timeline of every Task, Habit, and Reflection ever linked to this Factor. This proves to the user they are doing the work.

2. The Reflection Reader:

In ReflectionScreen, tapping a card opens ReflectionDetailScreen.

Include a "Resurrect" button: "Run this experiment again" (Clones the experiment to today's tasks).

3. The Task/Habit Dashboard (Home):

Separate "Top 2 Tasks" (Priority) from "Habit Routine" (Maintenance).

Add a "Calendar View" (like HabitNow) to see streaks visually.