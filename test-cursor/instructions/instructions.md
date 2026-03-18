# 📱 Tip Calculator App — Requirements Document

---

## 1. App Overview

This app helps people quickly calculate tips when eating at restaurants or cafes.  
The user enters the bill amount, chooses a tip percentage, and sees the total.  
They can also split the bill between multiple people.

---

## 2. Main Goals

1. Make tip calculation fast and easy  
2. Show total amount clearly  
3. Allow splitting the bill between people  
4. Keep the app simple and easy to use  

---

## 3. User Stories

- **US-001**: As a user, I want to enter the bill amount so that I can calculate the tip  
- **US-002**: As a user, I want to choose a tip percentage so that I can decide how much to tip  
- **US-003**: As a user, I want to see the total amount so that I know how much to pay  
- **US-004**: As a user, I want to split the bill so that everyone pays their share  
- **US-005**: As a user, I want to change values quickly so that I can try different tips  

---

## 4. Features

- **F-001: Enter Bill Amount**  
  - What it does: Lets user type in the bill amount  
  - When it appears: On the main screen  
  - If something goes wrong: If user types letters, ignore or show “Enter numbers only”

- **F-002: Select Tip Percentage**  
  - What it does: Lets user pick tip (e.g. 10%, 15%, 20%)  
  - When it appears: Below bill input  
  - If something goes wrong: If nothing selected, use a default (e.g. 15%)

- **F-003: Show Tip Amount**  
  - What it does: Shows how much the tip is in money  
  - When it appears: After user enters bill or selects tip  
  - If something goes wrong: Show 0 if no bill entered  

- **F-004: Show Total Amount**  
  - What it does: Shows bill + tip  
  - When it appears: Updates live when values change  
  - If something goes wrong: Show 0 if inputs are empty  

- **F-005: Split Bill**  
  - What it does: Lets user choose number of people  
  - When it appears: Below total  
  - If something goes wrong: If number is 0, change it to 1 automatically  

- **F-006: Show Amount Per Person**  
  - What it does: Shows how much each person pays  
  - When it appears: After split number is chosen  
  - If something goes wrong: Show total if only 1 person  

---

## 5. Screens

- **S-001: Main Screen**  
  - What’s on screen:  
    - Bill amount input  
    - Tip percentage options  
    - Tip amount  
    - Total amount  
    - Split control (number of people)  
    - Amount per person  
  - How to get there:  
    - This is the first screen when app opens  

---

## 6. Data

- **D-001: Bill Amount**  
  - Number entered by user  

- **D-002: Tip Percentage**  
  - Selected percentage (e.g. 10, 15, 20)  

- **D-003: Number of People**  
  - How many people to split between  

- **D-004: Last Used Values (Optional)**  
  - Save last bill, tip, and split number for next time  

---

## 7. Extra Details

- No internet needed  
- Store data on the phone (simple saving)  
- No special permissions needed  
- Should support dark mode  
- Should update numbers instantly when user changes values  
- Use large, easy-to-read text  

---

## 8. Build Steps

- **B-001**: Create project in Xcode using SwiftUI  
- **B-002**: Build **S-001 (Main Screen)** layout  
- **B-003**: Add **F-001 (Bill Input)**  
- **B-004**: Add **F-002 (Tip Selection)**  
- **B-005**: Add **F-003 (Tip Amount Calculation)** using D-001 and D-002  
- **B-006**: Add **F-004 (Total Amount Calculation)**  
- **B-007**: Add **F-005 (Split Bill Control)** using D-003  
- **B-008**: Add **F-006 (Per Person Calculation)**  
- **B-009**: Add basic error handling (empty input, wrong values)  
- **B-010**: (Optional) Save data using **D-004**  
- **B-011**: Test the app with different numbers  
- **B-012**: Improve UI (spacing, font size, dark mode)  

---