# Architecture

This repository contains:

Backend
Spring Boot REST API

Frontend
Flutter mobile application using MVVM architecture.

Communication
Flutter communicates with backend using REST APIs.

Flow

Flutter View
→ ViewModel
→ Repository/API service
→ Spring Boot Controller
→ Service
→ Repository
→ Database

Rules

- Flutter models must match backend DTO JSON fields.
- API endpoints must start with /api.
- Backend returns JSON responses.