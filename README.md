# MindBloom — Mental Wellness Journal App

## Project Overview

MindBloom is a mental wellness journal app designed to help users reflect, track their moods, and build a healthier self-awareness habit. The app provides a calm and private space where users can log daily moods, write journal entries, view simple weekly insights, and control reminder settings.

The goal of MindBloom is to support emotional reflection through secure journaling, mood tracking, and rule-based wellness suggestions.

---

## Main Purpose

MindBloom helps users:

- Track how they feel each day
- Write private journal entries
- Save mood tags with each reflection
- Review past journal entries
- View simple 7-day mood insights
- Receive gentle reminder support
- Keep personal wellness data private and secure

This app is designed as a student Firebase project prototype.

---

## Firebase Services Used

This project uses the following Firebase services:

1. **Firebase Authentication**
   - Used for user sign up, login, password reset, and logout.

2. **Cloud Firestore**
   - Used to store private user data such as mood check-ins, journal entries, and reminder settings.

3. **Firebase Cloud Messaging / Reminder-Ready Setup**
   - Used as a planned reminder feature for daily journal prompts.

### Note About Firebase Storage

Firebase Storage was included in the original proposal as a possible way to store mindfulness media files. However, this prototype does **not** use Firebase Storage because Storage requires Blaze billing activation.

Instead, MindBloom uses Firestore-based or local resource information for the mindfulness resources section. This keeps the project within the free Firebase Spark plan while still demonstrating the resources feature.

---

## Core Features

### 1. Secure Login and Registration

MindBloom uses Firebase Authentication to protect user access.

Users can:

- Create an account
- Log in with email and password
- Reset their password
- Stay signed in through Firebase session persistence
- Log out from the settings page

This creates a secure entry point for the app.

---

### 2. Home and Mood Check-In

The Home screen gives users a simple and supportive dashboard.

The Home screen includes:

- Personalized greeting
- 7-day streak card
- Mood check-in card
- Mood buttons
- Journal shortcut button
- Daily reminder message

Available mood options:

- Calm
- Happy
- Stressed
- Tired

When a user taps a mood button, the mood is saved to Cloud Firestore under the user's private UID.

---

### 3. Private Journal Entry System

The Journal screen allows users to write private reflections and save them to Firestore.

Journal features include:

- Writing a journal entry
- Selecting a mood
- Adding mood tags
- Saving a draft
- Saving a completed entry
- Viewing journal history
- Deleting journal entries

Mood tags include:

- anxious
- hopeful
- tired
- grateful
- stressed
- calm

Each journal entry is stored under the logged-in user's UID, which keeps the data private.

---

### 4. Weekly Mood Insights

MindBloom includes a simple 7-day mood insight feature.

The app can review recent mood check-ins and provide a rule-based wellness suggestion.

Example:

> You felt stressed multiple times this week. Try a short breathing break before journaling tonight.

This feature is not medical advice. It is only a supportive reflection tool based on basic mood patterns.

---

### 5. Mindfulness Resources

The Resources screen provides supportive wellness content such as:

- Breathing exercise ideas
- Reflection prompts
- Gratitude journal prompts
- Mindfulness guide text

In this prototype, resources are not stored in Firebase Storage. Instead, they are shown through local content or Firestore metadata.

---

### 6. Reminder Settings

The Settings screen includes a reminder control for daily journaling.

Users can:

- Turn daily journal reminders on or off
- View the reminder time
- Read a privacy note
- Log out

The reminder feature is designed to support future Firebase Cloud Messaging integration.

---

## Firestore Data Structure

The app uses a UID-based Firestore structure.

```text
users
 └── userId
      ├── moodCheckins
      │    └── moodDocumentId
      ├── journalEntries
      │    └── journalDocumentId
      └── reminders
           └── settings