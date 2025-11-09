# PetAlert  
**University of North Texas**  
**CSSE 4901 – Capstone Project**  
**Instructor:** David Keathly  
**Team:** Sunrise Inc  

---

## Project Overview
PetAlert is a Flutter-based mobile application designed to assist families during pet emergencies by providing a quick and organized way to store pet information, generate missing-pet alerts, and contact relevant authorities or shelters.  
Users can easily manage pet profiles, maintain emergency contacts, and generate alert messages, emails, and flyers with minimal effort.

---

## Sprint 2 Progress Summary

| Feature | Status | Description |
|----------|---------|-------------|
| Pet Profile (R1) | Green (Completed) | Users can create, edit, and save pet profiles including name, species, age, and photo. |
| Owner & Emergency Contact Info (R2) | Yellow (In Progress) | Contact information saving and retrieval work; interface validation and error handling under refinement. |
| Missing Pet Alert System (R3) | Yellow (In Progress) | Alert text generation complete and email sharing functional; additional formatting and social media integration scheduled. |
| Regular Update Prompts (R4) | Green (Completed) | Notifications implemented to remind users to refresh pet information after a defined period. |
| Recommendations Section (R5) | Yellow (In Progress) | Section loads properly; content enhancement and improved layout planned. |
| Toxic Food Infographics (R6) | Yellow (In Progress) | Static infographic screens developed; category filters and resizing updates to be completed in Sprint 3. |

**Overall Sprint 2 Status:** Approximately 70% of all features are operational. Core modules are stable and undergoing user interface improvements.

---

## Features Summary
1. Pet Profile Management – add, edit, and update pet details with image upload capability.  
2. Owner and Emergency Contacts – maintain essential contact data for quick reference.  
3. Missing Pet Alert System – generate pre-formatted alerts for phone, email, and flyer use.  
4. Update Reminders – scheduled prompts encouraging users to keep information current.  
5. Recommendations – curated advice and content for pet care and safety.  
6. Toxic Food Infographics – visual educational resources on pet health and safety.

---

## Test Plan
Testing details are documented in **TestPlanTracker_Updated.xlsx**, organized by user story.  
Color codes are used for test outcomes:
- Green: Verified and fully functional  
- Yellow: Partially implemented, further testing needed  
- Red: Planned for future sprint  

Each test case outlines:
- Preconditions  
- Test steps  
- Expected outcomes  
- Sprint outcome and notes

---

## System Requirements
- Flutter 3.35 or later  
- Dart 3.x  
- Android SDK 33+ / iOS 16+  
- IDE: Visual Studio Code or Android Studio  

### Dependencies
- image_picker  
- path_provider  
- shared_preferences  
- flutter_local_notifications

---

## Folder Structure
```
PetAlert/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── add_pet_screen.dart
│   │   ├── contacts_screen.dart
│   │   ├── alerts_screen.dart
│   └── shared/
│       ├── models/pet.dart
│       └── services/pet_storage.dart
│
├── assets/
│   ├── images/
│   └── icons/
│
├── test/
│   └── widget_tests.dart
│
└── docs/
    ├── Requirements_Template.pdf
    └── TestPlanTracker_Updated.xlsx
```

---

## Sprint 2 Highlights
- Implemented Add Pet functionality with validation and local storage.  
- Integrated Camera and Gallery for photo input.  
- Added Reminder Logic for periodic updates.  
- Improved UI layout consistency and internal code organization.  
- Created detailed Test Plan Tracker for all user stories.  
- Achieved overall feature stability across devices.

---

## Sprint 3 Goals
- Implement social media sharing for missing pet alerts.  
- Add Firebase or SQLite backend for persistent data management.  
- Enhance user interface transitions and animations.  
- Expand Recommendations and Infographics functionality.  
- Conduct user testing for performance and accessibility feedback.

---

## Team Members
- Ojaswi Subedi  
- Bibek Pandey   
- Kimberley Juarez  
- Anjali Fernando
- Tanvi Biswal

---

## License
This project is created as part of the University of North Texas – CSSE 4901 Capstone Course.  
All content is for academic and educational use only.
