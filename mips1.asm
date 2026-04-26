.data
# --- Main Menu ---
menu_header: .asciiz "-----------------------------------\n MINI PRODUCTIVITY DASHBOARD\n-----------------------------------\n"
menu_options: .asciiz "1. To-Do List\n2. Quick Notes\n3. Pomodoro Timer\n4. Weekly Habit Tracker\n5. Reset All\n6. Exit\n-----------------------------------\nEnter your choice: "

# --- To-Do List ---
todo_menu: .asciiz "\n--- To-Do List ---\n1. Add Task\n2. View Tasks\n3. Mark Task as Done\n4. Delete Task\n5. Back to Main Menu\nChoice: "
add_task_prompt: .asciiz "Enter task description: "
priority_prompt: .asciiz "Enter priority (1=High, 2=Medium, 3=Low): "
priority_high: .asciiz "[H] "
priority_medium: .asciiz "[M] "
priority_low: .asciiz "[L] "
task_added: .asciiz "Task added successfully!\n"
no_tasks: .asciiz "No tasks found.\n"
mark_task_prompt: .asciiz "Enter task number to mark as done: "
delete_task_prompt: .asciiz "Enter task number to delete: "
task_marked: .asciiz "Task marked as done!\n"
task_deleted: .asciiz "Task deleted successfully!\n"
invalid_task: .asciiz "Invalid task number!\n"
invalid_priority: .asciiz "Invalid priority! Using Medium.\n"
done_marker: .asciiz " [Done]"

# --- Quick Notes ---
notes_menu: .asciiz "\n--- Quick Notes ---\n1. Add Note\n2. View Notes\n3. Delete Note\n4. Clear All Notes\n5. Back to Main Menu\nChoice: "
add_note_prompt: .asciiz "Enter your note: "
note_added: .asciiz "Note added successfully!\n"
no_notes: .asciiz "No notes found.\n"
delete_note_prompt: .asciiz "Enter note number to delete: "
note_deleted: .asciiz "Note deleted successfully!\n"
notes_cleared: .asciiz "All notes cleared!\n"

# --- Habit Tracker ---
habit_menu: .asciiz "\n--- Weekly Habit Tracker ---\n1. Add Habit\n2. View Habits\n3. Mark Habit for Day\n4. View Weekly Summary\n5. Back to Main Menu\nChoice: "
add_habit_prompt: .asciiz "Enter habit name: "
habit_added: .asciiz "Habit added successfully!\n"
no_habits: .asciiz "No habits found.\n"
day_prompt: .asciiz "Enter day (0=Mon,1=Tue,2=Wed,3=Thu,4=Fri,5=Sat,6=Sun): "
habit_prompt: .asciiz "Enter habit number: "
habit_marked: .asciiz "Habit marked for today!\n"
habit_summary_header: .asciiz "\n--- Weekly Habit Summary ---\n"
progress_label: .asciiz "Progress: "

# --- Pomodoro ---
pomodoro_menu: .asciiz "\n--- Pomodoro Timer ---\n1. Start Timer (25min work + 5min break)\n2. Custom Timer\n3. Back to Main Menu\nChoice: "
work_time_prompt: .asciiz "Enter work duration (minutes): "
break_time_prompt: .asciiz "Enter break duration (minutes): "
work_start: .asciiz "\nWORK TIME started!\n"
break_start: .asciiz "\nBREAK TIME started!\n"
time_remaining: .asciiz "Time remaining: "
minutes: .asciiz " minutes "
seconds: .asciiz " seconds\n"
timer_complete: .asciiz "\nTimer complete!\n"
beep_sound: .asciiz "\nPlaying completion sound...\n"

# --- Daily Summary ---
daily_summary_header: .asciiz "\n-----------------------------------\n          DAILY SUMMARY\n-----------------------------------\n"
tasks_summary: .asciiz "Today's Tasks: "
pending_tasks: .asciiz " pending, "
completed_tasks: .asciiz " done\n"
habits_summary: .asciiz "Habits completed today: "
notes_summary: .asciiz "Notes added today: "
newline: .asciiz "\n"

# --- Reset & Errors ---
reset_confirm: .asciiz "\nAre you sure? This will delete ALL data! (1=Yes, 0=No): "
reset_success: .asciiz "All data reset successfully!\n"
error_msg: .asciiz "Invalid choice! Please try again.\n"

# --- General ---
space: .asciiz " "
colon: .asciiz ": "
bracket_open: .asciiz "["
bracket_close: .asciiz "]"
slash: .asciiz "/"

# --- Memory Buffers ---
input_buffer: .space 256
task_array: .space 3072      # Up to 4 tasks of 768 chars (larger to accommodate priority )
task_count: .word 0

notes_array: .space 1024     # Up to 4 notes of 256 chars
note_count: .word 0

habit_array: .space 1024     # Up to 4 habits of 256 chars
habit_count: .word 0
habit_status: .space 28      # 4 habits x 7 days, "N" or "Y" for each day

# Current day tracking (0=Monday, 6=Sunday)
current_day: .word 0

.text
.globl main

# === MAIN PROGRAM ===
main:
    # Initialize current day (you could get this from system time, but for simplicity we'll track it)
    li $t0, 0
    sw $t0, current_day

main_loop:
    # Display main menu
    la $a0, menu_header
    li $v0, 4
    syscall
    la $a0, menu_options
    li $v0, 4
    syscall

    # Get user choice
    li $v0, 5
    syscall
    move $t0, $v0

    # Menu choices
    beq $t0, 1, todo_list
    beq $t0, 2, quick_notes
    beq $t0, 3, pomodoro_timer
    beq $t0, 4, habit_tracker
    beq $t0, 5, reset_all
    beq $t0, 6, show_daily_summary  # Show summary before exiting

    # Invalid choice
    la $a0, error_msg
    li $v0, 4
    syscall
    j main_loop

# ================= TO-DO LIST =================
todo_list:
    la $a0, todo_menu
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, add_task_mem
    beq $t0, 2, view_tasks_mem
    beq $t0, 3, mark_task_mem
    beq $t0, 4, delete_task_mem
    beq $t0, 5, main_loop

    la $a0, error_msg
    li $v0, 4
    syscall
    j todo_list

add_task_mem:
    # Get task description
    la $a0, add_task_prompt
    li $v0, 4
    syscall

    la $a0, input_buffer
    li $a1, 256
    li $v0, 8
    syscall
    jal remove_newline
    
    # Get priority
    la $a0, priority_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t7, $v0  # Store priority in $t7
    

    # Copy input_buffer into task_array with priority 
    lw $t1, task_count
    li $t2, 768    # Increased buffer size for each task
    la $t3, task_array
    mul $t4, $t1, $t2      # Offset
    add $t3, $t3, $t4
    
    # Add priority prefix based on user input
    li $t9, 1
    beq $t7, $t9, add_high_priority
    li $t9, 2
    beq $t7, $t9, add_medium_priority
    li $t9, 3
    beq $t7, $t9, add_low_priority
    
    # Default to medium if invalid
    la $a0, invalid_priority
    li $v0, 4
    syscall
    j add_medium_priority_force

add_high_priority:
    la $t5, priority_high
    j copy_priority_loop

add_medium_priority:
add_medium_priority_force:
    la $t5, priority_medium
    j copy_priority_loop

add_low_priority:
    la $t5, priority_low

copy_priority_loop:
    lb $t6, 0($t5)
    beqz $t6, priority_done
    sb $t6, 0($t3)
    addi $t5, $t5, 1
    addi $t3, $t3, 1
    j copy_priority_loop

priority_done:
    # Now copy the task description
    la $a0, input_buffer
copy_task_desc_loop:
    lb $t5, 0($a0)
    beqz $t5, task_desc_done
    sb $t5, 0($t3)
    addi $a0, $a0, 1
    addi $t3, $t3, 1
    j copy_task_desc_loop

task_desc_done:
    sb $zero, 0($t3)
    
    # Increment task count
    lw $t6, task_count
    addi $t6, $t6, 1
    sw $t6, task_count

    la $a0, task_added
    li $v0, 4
    syscall
    j todo_list

# Helper function to convert integer to string
int_to_string:
    # $a0 = integer to convert
    # Returns: $v0 = address of string buffer (uses input_buffer temporarily)
    move $t0, $a0
    la $v0, input_buffer  # Reuse input_buffer for conversion
    addi $v0, $v0, 200    # Use later part of buffer
    
    # Handle zero case
    beqz $t0, convert_zero
    
    # Convert to string (reverse order)
    addi $t1, $v0, 10     # Max 10 digits
    sb $zero, 0($t1)      # Null terminate
    
convert_loop:
    blez $t0, convert_done
    li $t2, 10
    div $t0, $t2
    mfhi $t3              # Remainder (last digit)
    mflo $t0              # Quotient
    
    addi $t3, $t3, 48     # Convert to ASCII
    addi $t1, $t1, -1
    sb $t3, 0($t1)
    j convert_loop

convert_done:
    move $v0, $t1
    jr $ra

convert_zero:
    li $t1, '0'
    sb $t1, 0($v0)
    li $t1, 0
    sb $t1, 1($v0)
    jr $ra

view_tasks_mem:
    lw $t0, task_count
    beqz $t0, no_tasks_found_mem
    
    li $t1, 0
view_task_loop:
    lw $t2, task_count
    bge $t1, $t2, view_task_done
    
    # Print task number
    move $a0, $t1
    addi $a0, $a0, 1
    li $v0, 1
    syscall
    la $a0, colon
    li $v0, 4
    syscall
    
    # Print task content (with priority already included)
    la $a0, task_array
    li $t3, 768
    mul $t4, $t1, $t3
    add $a0, $a0, $t4
    li $v0, 4
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $t1, $t1, 1
    j view_task_loop
view_task_done:
    j todo_list

no_tasks_found_mem:
    la $a0, no_tasks
    li $v0, 4
    syscall
    j todo_list

mark_task_mem:
    lw $t0, task_count
    beqz $t0, no_tasks_found_mem

    la $a0, mark_task_prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    # Validate task number
    blez $t0, invalid_task_num
    lw $t1, task_count
    bgt $t0, $t1, invalid_task_num

    # Convert to 0-based index
    addi $t0, $t0, -1

    # Get task address
    la $t2, task_array
    li $t3, 768
    mul $t4, $t0, $t3
    add $t2, $t2, $t4

    # Find end of task string
    move $t5, $t2
find_end:
    lb $t6, 0($t5)
    beqz $t6, append_done
    addi $t5, $t5, 1
    j find_end

append_done:
    # Append [✓]
    la $t7, done_marker
append_loop:
    lb $t8, 0($t7)
    beqz $t8, append_finish
    sb $t8, 0($t5)
    addi $t7, $t7, 1
    addi $t5, $t5, 1
    j append_loop

append_finish:
    sb $zero, 0($t5)

    la $a0, task_marked
    li $v0, 4
    syscall
    j todo_list

#yahan se
invalid_task_num:
    la $a0, invalid_task
    li $v0, 4
    syscall
    j todo_list

delete_task_mem:
    lw $t0, task_count
    beqz $t0, no_tasks_found_mem
    
    la $a0, delete_task_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Validate task number
    blez $t0, invalid_task_num
    lw $t1, task_count
    bgt $t0, $t1, invalid_task_num
    
    # Convert to 0-based index
    addi $t0, $t0, -1
    
    # Shift all subsequent tasks up
    move $t2, $t0
delete_shift_loop:
    lw $t3, task_count
    addi $t3, $t3, -1
    bge $t2, $t3, delete_shift_done
    
    # Copy next task to current position
    la $t4, task_array
    li $t5, 768
    mul $t6, $t2, $t5
    add $t4, $t4, $t6
    
    la $t7, task_array
    addi $t8, $t2, 1
    mul $t9, $t8, $t5
    add $t7, $t7, $t9
    
    # Copy string
    li $t1, 0
copy_delete_loop:
    lb $t3, 0($t7)
    sb $t3, 0($t4)
    beqz $t3, copy_delete_done
    addi $t1, $t1, 1
    addi $t4, $t4, 1
    addi $t7, $t7, 1
    j copy_delete_loop

copy_delete_done:
    addi $t2, $t2, 1
    j delete_shift_loop

delete_shift_done:
    # Decrement count
    lw $t0, task_count
    addi $t0, $t0, -1
    sw $t0, task_count
    
    la $a0, task_deleted
    li $v0, 4
    syscall
    j todo_list


# ================= QUICK NOTES =================
quick_notes:
    la $a0, notes_menu
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, add_note_mem
    beq $t0, 2, view_notes_mem
    beq $t0, 3, delete_note_mem
    beq $t0, 4, clear_notes_mem
    beq $t0, 5, main_loop

    la $a0, error_msg
    li $v0, 4
    syscall
    j quick_notes

add_note_mem:
    la $a0, add_note_prompt
    li $v0, 4
    syscall

    la $a0, input_buffer
    li $a1, 256
    li $v0, 8
    syscall
    jal remove_newline

    # Copy input_buffer into notes_array
    lw $t1, note_count
    li $t2, 256
    la $t3, notes_array
    mul $t4, $t1, $t2
    add $t3, $t3, $t4
    
    # Copy note text
    la $a0, input_buffer
copy_note_text_loop:
    lb $t5, 0($a0)
    sb $t5, 0($t3)
    beqz $t5, copy_note_text_done
    addi $a0, $a0, 1
    addi $t3, $t3, 1
    j copy_note_text_loop

copy_note_text_done:
    # No timestamp added anymore
    lw $t6, note_count
    addi $t6, $t6, 1
    sw $t6, note_count

    la $a0, note_added
    li $v0, 4
    syscall
    j quick_notes

view_notes_mem:
    lw $t0, note_count
    beqz $t0, no_notes_mem
    li $t1, 0
view_note_loop:
    lw $t2, note_count
    bge $t1, $t2, view_note_done
    
    # Print note number
    move $a0, $t1
    addi $a0, $a0, 1
    li $v0, 1
    syscall
    la $a0, colon
    li $v0, 4
    syscall
    
    # Print note content
    la $a0, notes_array
    li $t3, 256
    mul $t4, $t1, $t3
    add $a0, $a0, $t4
    li $v0, 4
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $t1, $t1, 1
    j view_note_loop
view_note_done:
    j quick_notes

no_notes_mem:
    la $a0, no_notes
    li $v0, 4
    syscall
    j quick_notes

delete_note_mem:
    lw $t0, note_count
    beqz $t0, no_notes_mem
    
    la $a0, delete_note_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Validate note number
    blez $t0, invalid_note_num
    lw $t1, note_count
    bgt $t0, $t1, invalid_note_num
    
    # Convert to 0-based index
    addi $t0, $t0, -1
    
    # Shift all subsequent notes up
    move $t2, $t0
delete_note_shift_loop:
    lw $t3, note_count
    addi $t3, $t3, -1
    bge $t2, $t3, delete_note_shift_done
    
    # Copy next note to current position
    la $t4, notes_array
    li $t5, 256
    mul $t6, $t2, $t5
    add $t4, $t4, $t6
    
    la $t7, notes_array
    addi $t8, $t2, 1
    mul $t9, $t8, $t5
    add $t7, $t7, $t9
    
    # Copy string
    li $t1, 0
copy_note_delete_loop:
    lb $t3, 0($t7)
    sb $t3, 0($t4)
    beqz $t3, copy_note_delete_done
    addi $t1, $t1, 1
    addi $t4, $t4, 1
    addi $t7, $t7, 1
    j copy_note_delete_loop

copy_note_delete_done:
    addi $t2, $t2, 1
    j delete_note_shift_loop

delete_note_shift_done:
    # Decrement count
    lw $t0, note_count
    addi $t0, $t0, -1
    sw $t0, note_count
    
    la $a0, note_deleted
    li $v0, 4
    syscall
    j quick_notes

invalid_note_num:
    la $a0, invalid_task  # Reuse invalid task message
    li $v0, 4
    syscall
    j quick_notes

clear_notes_mem:
    li $t0, 0
    sw $t0, note_count
    la $a0, notes_cleared
    li $v0, 4
    syscall
    j quick_notes

# ================= POMODORO TIMER =================
pomodoro_timer:
    la $a0, pomodoro_menu
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, start_standard_timer
    beq $t0, 2, start_custom_timer
    beq $t0, 3, main_loop

    la $a0, error_msg
    li $v0, 4
    syscall
    j pomodoro_timer

start_standard_timer:
    li $s0, 25
    li $s1, 5
    j start_timer_work

start_custom_timer:
    la $a0, work_time_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $s0, $v0
    la $a0, break_time_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $s1, $v0

start_timer_work:
    la $a0, work_start
    li $v0, 4
    syscall
    mul $a0, $s0, 60
    jal countdown_timer
    jal play_completion_sound
    
    la $a0, break_start
    li $v0, 4
    syscall
    mul $a0, $s1, 60
    jal countdown_timer
    jal play_completion_sound
    
    la $a0, timer_complete
    li $v0, 4
    syscall
    j pomodoro_timer

countdown_timer:
    move $t0, $a0
countdown_loop:
    la $a0, time_remaining
    li $v0, 4
    syscall
    div $t1, $t0, 60
    rem $t2, $t0, 60
    move $a0, $t1
    li $v0, 1
    syscall
    la $a0, minutes
    li $v0, 4
    syscall
    move $a0, $t2
    li $v0, 1
    syscall
    la $a0, seconds
    li $v0, 4
    syscall
    li $a0, 1000
    li $v0, 32
    syscall
    addi $t0, $t0, -1
    bgtz $t0, countdown_loop
    jr $ra

play_completion_sound:
    # Play beep sound
    la $a0, beep_sound
    li $v0, 4
    syscall
    
    # System call for beep sound
    li $a0, 67   # Pitch (middle C)
    li $a1, 1000 # Duration in milliseconds
    li $a2, 32   # Instrument
    li $a3, 100  # Volume
    li $v0, 31   # Syscall for play note
    syscall
    
    # Wait for sound to finish
    li $a0, 1000
    li $v0, 32
    syscall
    
    jr $ra

# ================= HABIT TRACKER =================
habit_tracker:
    la $a0, habit_menu
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, add_habit_mem
    beq $t0, 2, view_habits_mem
    beq $t0, 3, mark_habit_mem
    beq $t0, 4, view_habit_summary
    beq $t0, 5, main_loop

    la $a0, error_msg
    li $v0, 4
    syscall
    j habit_tracker

add_habit_mem:
    la $a0, add_habit_prompt
    li $v0, 4
    syscall
    la $a0, input_buffer
    li $a1, 256
    li $v0, 8
    syscall
    jal remove_newline

    lw $t1, habit_count
    li $t2, 256
    la $t3, habit_array
    mul $t4, $t1, $t2
    add $t3, $t3, $t4
    
    # Initialize habit status for all days to 'N'
    la $t5, habit_status
    li $t6, 7
    mul $t7, $t1, $t6
    add $t5, $t5, $t7
    li $t8, 0
init_habit_status_loop:
    bge $t8, $t6, init_habit_status_done
    li $t9, 'N'
    sb $t9, 0($t5)
    addi $t5, $t5, 1
    addi $t8, $t8, 1
    j init_habit_status_loop

init_habit_status_done:
copy_habit_loop:
    lb $t5, 0($a0)
    sb $t5, 0($t3)
    beqz $t5, copy_habit_done
    addi $a0, $a0, 1
    addi $t3, $t3, 1
    j copy_habit_loop

copy_habit_done:
    lw $t6, habit_count
    addi $t6, $t6, 1
    sw $t6, habit_count

    la $a0, habit_added
    li $v0, 4
    syscall
    j habit_tracker

view_habits_mem:
    lw $t0, habit_count
    beqz $t0, no_habits_mem
    
    li $t1, 0
view_habit_loop:
    lw $t2, habit_count
    bge $t1, $t2, view_habit_done
    
    # Print habit number and name
    move $a0, $t1
    addi $a0, $a0, 1
    li $v0, 1
    syscall
    la $a0, colon
    li $v0, 4
    syscall
    
    la $a0, habit_array
    li $t3, 256
    mul $t4, $t1, $t3
    add $a0, $a0, $t4
    li $v0, 4
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $t1, $t1, 1
    j view_habit_loop

view_habit_done:
    j habit_tracker

no_habits_mem:
    la $a0, no_habits
    li $v0, 4
    syscall
    j habit_tracker

mark_habit_mem:
    lw $t0, habit_count
    beqz $t0, no_habits_mem
    
    # Get habit number
    la $a0, habit_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t1, $v0
    
    # Validate habit number
    blez $t1, invalid_habit_num
    lw $t2, habit_count
    bgt $t1, $t2, invalid_habit_num
    
    # Get day number
    la $a0, day_prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t3, $v0
    
    # Validate day number
    bltz $t3, invalid_day_num
    li $t4, 6
    bgt $t3, $t4, invalid_day_num
    
    # Convert to 0-based indices
    addi $t1, $t1, -1
    
    # Calculate position in habit_status array
    la $t5, habit_status
    li $t6, 7
    mul $t7, $t1, $t6
    add $t7, $t7, $t3
    add $t5, $t5, $t7
    
    # Mark as 'Y'
    li $t8, 'Y'
    sb $t8, 0($t5)
    
    la $a0, habit_marked
    li $v0, 4
    syscall
    j habit_tracker

invalid_habit_num:
    la $a0, invalid_task
    li $v0, 4
    syscall
    j habit_tracker

invalid_day_num:
    la $a0, invalid_task
    li $v0, 4
    syscall
    j habit_tracker

view_habit_summary:
    lw $t0, habit_count
    beqz $t0, no_habits_mem
    
    la $a0, habit_summary_header
    li $v0, 4
    syscall
    
    li $t1, 0  # Habit index
summary_habit_loop:
    lw $t2, habit_count
    bge $t1, $t2, summary_done
    
    # Print habit name
    move $a0, $t1
    addi $a0, $a0, 1
    li $v0, 1
    syscall
    la $a0, colon
    li $v0, 4
    syscall
    
    la $a0, habit_array
    li $t3, 256
    mul $t4, $t1, $t3
    add $a0, $a0, $t4
    li $v0, 4
    syscall
    
    la $a0, space
    li $v0, 4
    syscall
    
    # Print status array
    la $a0, bracket_open
    li $v0, 4
    syscall
    
    la $t5, habit_status
    li $t6, 7
    mul $t7, $t1, $t6
    add $t5, $t5, $t7
    
    li $t8, 0  # Day index
summary_day_loop:
    bge $t8, $t6, summary_day_done
    
    # Print day status
    lb $a0, 0($t5)
    li $v0, 11
    syscall
    
    addi $t8, $t8, 1
    addi $t5, $t5, 1
    
    blt $t8, $t6, print_day_space
    j summary_day_loop

print_day_space:
    la $a0, space
    li $v0, 4
    syscall
    j summary_day_loop

summary_day_done:
    la $a0, bracket_close
    li $v0, 4
    syscall
    
    # Calculate and print progress
    la $a0, space
    li $v0, 4
    syscall
    la $a0, progress_label
    li $v0, 4
    syscall
    
    # Count 'Y's for this habit
    la $t5, habit_status
    li $t6, 7
    mul $t7, $t1, $t6
    add $t5, $t5, $t7
    
    li $t8, 0  # Day counter
    li $t9, 0  # 'Y' counter
count_y_loop:
    bge $t8, $t6, count_y_done
    lb $a0, 0($t5)
    li $a1, 'Y'
    bne $a0, $a1, not_y
    addi $t9, $t9, 1
not_y:
    addi $t8, $t8, 1
    addi $t5, $t5, 1
    j count_y_loop

count_y_done:
    # Print progress count
    move $a0, $t9
    li $v0, 1
    syscall
    la $a0, slash
    li $v0, 4
    syscall
    li $a0, 7
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $t1, $t1, 1
    j summary_habit_loop

summary_done:
    j habit_tracker

# ================= DAILY SUMMARY =================
show_daily_summary:
    la $a0, daily_summary_header
    li $v0, 4
    syscall
    
    # Calculate task statistics
    jal count_tasks_today
    move $s0, $v0  # Pending tasks
    move $s1, $v1  # Completed tasks
    
    # Calculate habits completed today
    jal count_habits_today
    move $s2, $v0  # Habits completed today
    
    # Calculate notes added today (simplified: just total notes)
    lw $s3, note_count
    
    # Display task summary
    la $a0, tasks_summary
    li $v0, 4
    syscall
    move $a0, $s0
    li $v0, 1
    syscall
    la $a0, pending_tasks
    li $v0, 4
    syscall
    move $a0, $s1
    li $v0, 1
    syscall
    la $a0, completed_tasks
    li $v0, 4
    syscall
    
    # Display habits summary
    la $a0, habits_summary
    li $v0, 4
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    la $a0, slash
    li $v0, 4
    syscall
    lw $a0, habit_count
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    # Display notes summary
    la $a0, notes_summary
    li $v0, 4
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    j exit_program

count_tasks_today:
    # Count pending and completed tasks
    lw $t0, task_count
    li $t1, 0  # Pending counter
    li $t2, 0  # Completed counter
    li $t3, 0  # Task index
    
    beqz $t0, count_tasks_done
    
count_tasks_loop:
    bge $t3, $t0, count_tasks_done
    
    # Get task address
    la $t4, task_array
    li $t5, 768
    mul $t6, $t3, $t5
    add $t4, $t4, $t6
    
    # Check if task contains "(Done)"
    la $a0, done_marker
    move $a1, $t4
    jal string_contains
    
    beqz $v0, task_pending
    addi $t2, $t2, 1  # Increment completed
    j next_task_count
    
task_pending:
    addi $t1, $t1, 1  # Increment pending

next_task_count:
    addi $t3, $t3, 1
    j count_tasks_loop

count_tasks_done:
    move $v0, $t1  # Return pending count
    move $v1, $t2  # Return completed count
    jr $ra

count_habits_today:
    # Count habits completed today (current day)
    lw $t0, habit_count
    lw $t1, current_day  # Get current day (0-6)
    li $t2, 0  # Completed counter
    li $t3, 0  # Habit index
    
    beqz $t0, count_habits_done
    
count_habits_loop:
    bge $t3, $t0, count_habits_done
    
    # Calculate position in habit_status for current day
    la $t4, habit_status
    li $t5, 7
    mul $t6, $t3, $t5
    add $t6, $t6, $t1
    add $t4, $t4, $t6
    
    # Check if habit is completed today
    lb $t7, 0($t4)
    li $t8, 'Y'
    bne $t7, $t8, habit_not_completed
    addi $t2, $t2, 1

habit_not_completed:
    addi $t3, $t3, 1
    j count_habits_loop

count_habits_done:
    move $v0, $t2  # Return completed habits count
    jr $ra

# ================= RESET =================
reset_all:
    la $a0, reset_confirm
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    beqz $v0, reset_cancelled

    # Reset counts
    li $t0, 0
    sw $t0, task_count
    sw $t0, note_count
    sw $t0, habit_count

    # Clear habit status
    la $t1, habit_status
    li $t2, 28
    li $t3, 0
clear_habit_status:
    bge $t3, $t2, clear_habit_done
    sb $zero, 0($t1)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    j clear_habit_status

clear_habit_done:
    la $a0, reset_success
    li $v0, 4
    syscall
    j main_loop

reset_cancelled:
    j main_loop

# ================= UTILITY FUNCTIONS =================
remove_newline:
    la $t0, input_buffer
remove_loop:
    lb $t1, 0($t0)
    beqz $t1, remove_done
    beq $t1, 10, found_newline
    addi $t0, $t0, 1
    j remove_loop
found_newline:
    sb $zero, 0($t0)
remove_done:
    jr $ra

# String contains function
# $a0 = substring to search for
# $a1 = string to search in
# Returns $v0 = 1 if found, 0 if not found
string_contains:
    move $t0, $a0  # substring
    move $t1, $a1  # main string
    
outer_loop:
    lb $t2, 0($t1)
    beqz $t2, not_found
    
    move $t3, $t0  # reset substring pointer
    move $t4, $t1  # save current position
    
inner_loop:
    lb $t5, 0($t3)
    beqz $t5, found
    lb $t6, 0($t4)
    beqz $t6, not_found
    bne $t5, $t6, inner_loop_fail
    addi $t3, $t3, 1
    addi $t4, $t4, 1
    j inner_loop

inner_loop_fail:
    addi $t1, $t1, 1
    j outer_loop

found:
    li $v0, 1
    jr $ra

not_found:
    li $v0, 0
    jr $ra

exit_program:
    li $v0, 10
    syscall
