# TaskLoom

A decentralized task management system built on Stacks blockchain using Clarity smart contracts.

## Features
- Create and manage task lists
- Add/update/delete tasks 
- Assign tasks to addresses
- Task completion tracking with multiple status states
- Task history and audit trail

## Contract Functions

### Task Management
- create-task
- update-task
- delete-task
- assign-task
- update-task-status (supports pending, in-progress, completed, cancelled)
- complete-task

### Task Lists
- create-list
- add-task-to-list
- remove-task-from-list

### Query Functions
- get-task-details
- get-list-details
- get-user-tasks

## Task Status States
Tasks can have the following status states:
- pending: Initial state of a new task
- in-progress: Task is actively being worked on
- completed: Task has been finished
- cancelled: Task has been cancelled

## Testing
Tests are located in the `/tests` directory and can be run using Clarinet.
