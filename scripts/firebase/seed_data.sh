#!/bin/bash

# Add sample job postings
firebase firestore:set /jobs/job1 -d '{
  "title": "Senior Flutter Developer",
  "location": "Remote",
  "salary": "\$120k"
}' --project=your-project-id