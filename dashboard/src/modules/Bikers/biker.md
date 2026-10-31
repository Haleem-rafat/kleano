● Admin creating biker accounts
● Assigning areas + priorities + working days & hours
● Automatic request assignment logic with fallback rules
Epic: Automated Order Assignment to Bikers
User Story 1: Admin Creates Biker Account
As an Admin, I want to create a biker account so that the biker can operate and receive
orders
Acceptance Criteria:
1. Given I am on the “Create Biker” page, when I fill in biker details (name, phone,
email, ID, password) and click save, then a new biker account should be created.
2. Click on the “ create biker schedule” button to navigate to the screen where the
admin can select working days, areas from the list, and then the biker should be
linked to those areas.
3. A biker may have one or multiple assigned areas.
4. A biker cannot receive orders from areas not assigned to him.
User Story 2: Admin Defines Biker Working Days & Time
As an Admin, I want to specify the biker’s working days and working hours so that the
system assigns orders only when the biker is available
Acceptance Criteria:
1. Admin must be able to choose working days.
2. Admin must pick time slots.
3. The system must only consider the biker “available” if the current day and time
falls within their schedule.
4. If a biker is offline or outside working hours, the system must exclude them from
assignment.
User Story 3: Admin Sets Area Priority for Each Biker
As an Admin, I want to set a priority level for each assigned area so that, the system
knows which areas a biker should receive orders for first
Acceptance Criteria:
1. Each selected area should include a priority number (1 = highest).
2. Two or more areas may have the same priority value for the same biker
3. If multiple bikers are assigned to the same area, each biker can have different
priority values for that area.
User Story 4: Primary Auto-Assignment Logic
As a System, I want to automatically assign the order to the most suitable biker so that
orders are allocated efficiently
Rule #1: Pick the available biker with the highest area priority & nearest to
location
Acceptance Criteria:
1. Given a user submits an order, when the system identifies all bikers assigned to
that area AND currently available, then it should rank them by:
a. Area priority (highest first)
b. Distance from the order location (nearest first)
2. The system assigns the order to the biker with the highest priority + nearest
distance.
User Story 5: Secondary Assignment (Same Priority, but first is
unavailable)
As a System, I want to assign the order to another biker with the same priority if the
first one is busy, so that orders are not stuck waiting
Acceptance Criteria:
1. If the top-priority biker for that area is busy or not available, then the system
checks other bikers with the same priority.
2. System selects the biker with the same priority, BUT the next nearest distance.
3. Busy means:
○ Biker already has an active order overlapping with this time, OR
○ Biker is marked unavailable/offline
User Story 6: Third-Level Assignment (Lower Priority)
As a System. I want to assign the order to a lower-priority biker if no high-priority
bikers are free
So that the order is still handled without delay
Acceptance Criteria:
1. If no bikers with top priority are available or free, then the system should look
for bikers with lower priority assigned to the same area.
2. The system assigns to the nearest lower-priority biker with no active order at the
requested time.
User Story 7: Handling Full Capacity Scenario
As a System, I want to assign the order to the best fallback biker when all assigned
priority bikers are busy, so that the order does not get stuck
Acceptance Criteria:
1. If all bikers with assigned priority to the area are busy, then the system selects
a biker who:
a. Has the lowest priority for the area
b. Is available
c. Has no active order at this time
d. Is nearest to the order location
2. If no biker meets the conditions above, the system should send a notification to
Admin.