# Requirements Document: Tip Calculator App

## 1. App Overview
This app is a simple tool for people eating at restaurants or cafes. It helps you figure out how much extra money (a "tip") to give the waiter and calculates the total bill. It also helps friends split the bill so everyone knows exactly how much they owe.

---

## 2. Main Goals
1. Let the user type in how much the meal cost.
2. Let the user pick a tip percentage (like 15% or 20%).
3. Show the final total clearly.
4. Let the user divide the total cost between a group of people.

---

## 3. User Stories
* **US-001:** As a user, I want to type in my bill amount so the app knows how much I spent.
* **US-002:** As a user, I want to tap a button to pick a tip percentage so I don't have to do the math in my head.
* **US-003:** As a user, I want to see the total amount (bill + tip) so I know what the final price is.
* **US-004:** As a user, I want to choose how many people are eating so we can split the bill evenly.

---

## 4. Features
* **F-001: Bill Input Box**
    * **What it does:** A box where you type the price of your food.
    * **When it appears:** At the very top of the screen.
    * **If it goes wrong:** If the user types letters instead of numbers, the app will just show "0."
* **F-002: Tip Selection**
    * **What it does:** A row of buttons (10%, 15%, 20%, 25%) to choose a tip.
    * **When it appears:** Just below the bill input box.
    * **If it goes wrong:** One percentage is always selected by default (like 20%) so there is never a "blank" choice.
* **F-003: People Stepper**
    * **What it does:** Plus (+) and Minus (-) buttons to change the number of people sharing the bill.
    * **When it appears:** Below the tip selection.
    * **If it goes wrong:** The number cannot go below 1 person.
* **F-004: The Results Display**
    * **What it does:** A large section that shows the "Total Tip," the "Total Bill," and the "Amount Per Person."
    * **When it appears:** At the bottom of the screen. It updates instantly whenever the user changes a number above.

---

## 5. Screens
* **S-001: Main Calculator Screen**
    * **What’s on it:** The bill input (F-001), tip buttons (F-002), people counter (F-003), and the results (F-004).
    * **How to get there:** This is the only screen in the app. It opens as soon as you tap the app icon.

---

## 6. Data
* **D-001:** The **Bill Amount** (a number that can have dots, like 12.50).
* **D-002:** The **Tip Percentage** (a whole number like 15 or 20).
* **D-003:** The **Number of People** (a whole number starting at 1).

---

## 7. Extra Details
* **Internet:** The app does **not** need the internet to work.
* **Storage:** The app does not need to save data after you close it. Every time you open it, it starts fresh at 0.
* **Permissions:** No camera, location, or photos are needed.
* **Appearance:** The app should look good in both "Light Mode" (white background) and "Dark Mode" (black background).

---

## 8. Build Steps
* **B-001:** Open Xcode and create a new "App" project using SwiftUI.
* **B-002:** Create the main screen (**S-001**) and add three "memory boxes" to hold our data (**D-001, D-002, D-003**).
* **B-003:** Add the Bill Input Box (**F-001**) so users can type their price.
* **B-004:** Add the Tip Picker buttons (**F-002**) and the People Stepper (**F-003**).
* **B-005:** Write the "Math" section to calculate the tip and the split using the data from (**D-001, D-002, D-003**).
* **B-006:** Add the Results Display (**F-004**) at the bottom to show the final numbers to the user.