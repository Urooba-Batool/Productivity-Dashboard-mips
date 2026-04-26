# 🧠 Mini Productivity Dashboard (MIPS Assembly)

This project is a **console-based productivity dashboard** built using **MIPS Assembly Language**. It simulates a simple personal productivity system with multiple features like task management, notes, timer, and habit tracking — all implemented at a low-level programming level.

The goal of this project is to demonstrate understanding of:
- Assembly language programming
- Memory handling
- Control flow and branching
- User interaction via system calls

---

## 📌 Features

### ✅ 1. To-Do List
- Add tasks with priority (High / Medium / Low)
- View all tasks
- Mark tasks as completed
- Delete tasks
- Handles invalid inputs

### 📝 2. Quick Notes
- Add short notes
- View saved notes
- Delete individual notes
- Clear all notes

### ⏱️ 3. Pomodoro Timer
- Simulates a productivity timer
- Helps in time management (focus sessions)

### 📊 4. Weekly Habit Tracker
- Track habits across days
- Helps visualize consistency

### 🔄 5. Reset System
- Clears all stored data (tasks, notes, habits)

### ❌ 6. Exit Option
- Cleanly terminates the program

---

## 🏗️ Project Structure

The program is written in a single `.asm` file and divided logically into sections:

### 🔹 Data Segment (`.data`)
Contains:
- Menu strings
- Prompts
- Messages (success, error handling)
- Labels for priorities and status (e.g., `[H]`, `[Done]`)

### 🔹 Text Segment (`.text`)
Handles:
- Main menu navigation
- Feature-specific logic (To-Do, Notes, etc.)
- Input/output using syscalls
- Looping and branching logic

---

## ⚙️ How It Works

- The program starts with a **main menu**
- User selects an option (1–6)
- Control jumps to the respective module
- After completing an operation, user is returned to the menu

The system uses:
- Registers for temporary storage
- Arrays (in memory) for storing tasks/notes
- Conditional branching for logic handling

---

## ▶️ How to Run

### 🧪 Requirements
You need a MIPS simulator such as:
- MARS (Recommended)
- SPIM / QtSPIM

### 🚀 Steps
1. Open the `.asm` file in MARS or SPIM
2. Assemble the code
3. Run the program
4. Use the console to interact with the menu

---

## 💡 Concepts Used

- MIPS syscalls (I/O handling)
- Branching (`beq`, `bne`, `j`)
- Loops and control flow
- String handling in memory
- Array-like data storage
- Modular logic using labels

---

## ⚠️ Limitations

- Data is not persistent (resets when program stops)
- Limited memory (fixed-size arrays)
- Basic UI (console-based)

---

## 🌱 Future Improvements

- File handling for data persistence
- Better UI formatting
- Dynamic memory management
- More advanced timer functionality

---

## 🎯 Purpose of Project

This project was created as part of coursework to:
- Apply assembly language concepts practically
- Build a real-world inspired system using low-level programming
- Strengthen understanding of how high-level features are implemented at machine level

---

## 👩‍💻 Author

**Urooba Batool**  
Software Engineering Student  

---
