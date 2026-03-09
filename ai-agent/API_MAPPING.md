# API Mapping

Feature: Create Record

Endpoint

POST /api/records

Request

multipart/form-data

Fields:

title: string
notes: string
tags: array<string>
important: boolean
files: file[]

Example Request JSON

{
 "title": "Blood Test Result",
 "notes": "Annual health check",
 "tags": ["Blood", "Diabetes"],
 "important": true
}

Response

{
 "id": 1,
 "title": "Blood Test Result",
 "notes": "Annual health check",
 "tags": ["Blood", "Diabetes"],
 "important": true,
 "attachments": [
   "https://server/uploads/file1.jpg"
 ]
}