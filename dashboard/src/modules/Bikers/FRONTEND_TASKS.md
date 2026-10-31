# Biker Management - Frontend Tasks

## Task 1: Create Biker Account Form

**User Story:** Admin Creates Biker Account

### Subtasks:

1. **Create "Create Biker" page/form component**

   - Form fields:
     - Name (text input)
     - Phone (text input)
     - Email (text input)
     - ID/National ID (text input)
     - Password (password input)
   - Save/Submit button
   - Form validation
   - Success/error handling

2. **Add "Create Biker Schedule" button**
   - Button should navigate to biker schedule configuration screen
   - Should be accessible after biker creation or from biker details page

---

## Task 2: Biker Schedule Configuration Screen

**User Story:** Admin Defines Biker Working Days & Time

### Subtasks:

1. **Working Days Selection UI**

   - Multi-select or checkbox component for days of the week
   - Allow admin to select one or multiple working days
   - Visual indication of selected days

2. **Time Slots Selection UI**

   - Time picker component for start time
   - Time picker component for end time
   - Support for multiple time ranges per day (if needed)
   - Validation to ensure end time is after start time

3. **Area Assignment UI**

   - Multi-select dropdown/list of available areas
   - Display selected areas
   - Allow removal of selected areas
   - Visual indication that biker is linked to selected areas

4. **Save Schedule Functionality**
   - Save button to persist schedule configuration
   - Success/error feedback
   - Navigation after save

---

## Task 3: Area Priority Configuration UI

**User Story:** Admin Sets Area Priority for Each Biker

### Subtasks:

1. **Priority Input for Each Area**

   - For each assigned area, provide a priority number input
   - Priority number input (1 = highest priority)
   - Display priority value clearly

2. **Priority Management**

   - Allow multiple areas to have the same priority value
   - Visual display of priority levels (e.g., badges, numbers)
   - Validation for priority values

3. **Priority Display in Biker Details**
   - Show assigned areas with their priority values
   - Display in a table or list format
   - Allow editing of priorities

---

## Task 4: Biker Availability Status Display

**User Story:** Admin Defines Biker Working Days & Time

### Subtasks:

1. **Availability Status Indicator**

   - Display biker's current availability status
   - Show if biker is:
     - Available (within working hours and online)
     - Offline
     - Outside working hours
     - Busy (has active order)

2. **Working Hours Display**
   - Show biker's working days and hours in biker details
   - Calendar or schedule view of working hours
   - Visual representation of availability

---

## Task 5: Order Assignment Status Display

**User Stories:** Primary Auto-Assignment Logic, Secondary Assignment, Third-Level Assignment, Full
Capacity Scenario

### Subtasks:

1. **Assignment Information Display**

   - Show which biker was assigned to an order
   - Display assignment reason/priority if applicable
   - Show biker's distance from order location (if available)

2. **No Biker Available Notification UI**
   - Notification component/modal when no biker meets assignment conditions
   - Alert admin when system cannot assign order
   - Display relevant information about why assignment failed

---

## Task 6: Biker Details Page Enhancements

**Related to all user stories**

### Subtasks:

1. **Display Assigned Areas**

   - List all areas assigned to the biker
   - Show priority for each area
   - Visual indication of area assignments

2. **Display Working Schedule**

   - Show working days and hours
   - Calendar view or schedule table
   - Current availability status

3. **Edit Schedule Button**
   - Button to edit biker's schedule
   - Navigate to schedule configuration screen
   - Pre-populate form with existing schedule data

---

## Task 7: Validation & Error Handling

**Related to all user stories**

### Subtasks:

1. **Form Validation**

   - Validate all required fields
   - Email format validation
   - Phone number validation
   - Password strength requirements
   - Priority number validation (must be positive integer)

2. **Business Logic Validation**

   - Ensure at least one area is selected
   - Ensure at least one working day is selected
   - Ensure time slots are valid
   - Prevent duplicate area assignments (if applicable)

3. **Error Messages**
   - User-friendly error messages
   - Success confirmations
   - Loading states during API calls

---

## Task 8: Navigation & Routing

**Related to all user stories**

### Subtasks:

1. **Route Configuration**

   - Route for "Create Biker" page
   - Route for "Biker Schedule" configuration page
   - Route for "Biker Details" page with schedule editing

2. **Navigation Flow**
   - After creating biker → navigate to schedule configuration
   - From biker list → navigate to biker details
   - From biker details → navigate to schedule editing
   - Breadcrumb navigation



api body for scudle :
{
    "biker": "68c720ae5b3c4327aaa57e7b",                  // ObjectId
    "shifts": [
        {
            "timeSlot": "14:15",
            "city": "68c0ceedc69ab0816b8a7da3",           // ObjectId
            "area": "68c9fad3c6fddfa61072321b",           // ObjectId
            "day": "MONDAY",     // - SATURDAY | SUNDAY | MONDAY | TUESDAY | WEDNESDAY | THURSDAY | FRIDAY -
            "priorityLevel": 1     // 1 - 2 - 3
        }
    ]
}