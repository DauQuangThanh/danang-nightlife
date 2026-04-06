# Data Classification Register

**Project**: [PROJECT NAME]
**Date**: [YYYY-MM-DD]
**Assessor**: [AGENT ID / REVIEWER NAME]
**Commit SHA**: [COMMIT SHA]

---

## Classification Levels

| Level        | Description                          | Handling Requirements                                |
| ------------ | ------------------------------------ | ---------------------------------------------------- |
| PUBLIC       | Openly available information         | No special controls                                  |
| INTERNAL     | Business internal data               | Access control, no external sharing                  |
| CONFIDENTIAL | Sensitive business or personal data  | Encryption at rest + transit, audit logging, access control |
| RESTRICTED   | Highly sensitive regulated data      | End-to-end encryption, strict access control, DLP, retention policies |

---

## Database Tables

| Table Name       | Classification | Data Types        | Applicable Regulations | Retention Period | Encryption | Notes |
| ---------------- | -------------- | ----------------- | ---------------------- | ---------------- | ---------- | ----- |
| [table_name]     | [LEVEL]        | [PII/PHI/PAN/etc] | [GDPR/HIPAA/etc]       | [period]         | [YES/NO]   | -     |

---

## API Endpoints

| Endpoint                  | Method | Request Classification | Response Classification | Data Types        | Applicable Regulations | Audit Logged |
| ------------------------- | ------ | ---------------------- | ----------------------- | ----------------- | ---------------------- | ------------ |
| [/api/v1/resource]        | [GET]  | [LEVEL]                | [LEVEL]                 | [PII/PHI/PAN/etc] | [GDPR/HIPAA/etc]       | [YES/NO]     |

---

## Message Queues / Events

| Queue/Topic Name | Classification | Data Types        | Applicable Regulations | Encrypted in Transit | Notes |
| ---------------- | -------------- | ----------------- | ---------------------- | -------------------- | ----- |
| [queue_name]     | [LEVEL]        | [PII/PHI/PAN/etc] | [GDPR/HIPAA/etc]       | [YES/NO]             | -     |

---

## File Storage

| Storage Location   | Classification | Data Types        | Applicable Regulations | Encrypted at Rest | Retention Period | Notes |
| ------------------ | -------------- | ----------------- | ---------------------- | ------------------ | ---------------- | ----- |
| [bucket/path]      | [LEVEL]        | [PII/PHI/PAN/etc] | [GDPR/HIPAA/etc]       | [YES/NO]           | [period]         | -     |

---

## Cache Entries

| Cache Key Pattern  | Classification | Data Types        | TTL      | Notes |
| ------------------ | -------------- | ----------------- | -------- | ----- |
| [pattern]          | [LEVEL]        | [PII/PHI/PAN/etc] | [duration]| -     |

---

## Log Fields

| Log Source         | Fields Logged          | Classification | Contains Sensitive Data | Compliant |
| ------------------ | ---------------------- | -------------- | ----------------------- | --------- |
| [log_source]       | [field1, field2, ...]  | [LEVEL]        | [YES/NO - detail]       | [YES/NO]  |

---

## Summary

| Classification Level | Entity Count | Encrypted at Rest | Encrypted in Transit | Audit Logged | Retention Defined |
| -------------------- | ------------ | ------------------ | -------------------- | ------------ | ----------------- |
| PUBLIC               | [count]      | N/A                | N/A                  | N/A          | N/A               |
| INTERNAL             | [count]      | [count/total]      | [count/total]        | [count/total]| [count/total]     |
| CONFIDENTIAL         | [count]      | [count/total]      | [count/total]        | [count/total]| [count/total]     |
| RESTRICTED           | [count]      | [count/total]      | [count/total]        | [count/total]| [count/total]     |

---

## Unclassified Entities (Action Required)

| Entity Name | Entity Type       | Suspected Level | Action Required |
| ----------- | ----------------- | --------------- | --------------- |
| [name]      | [table/API/queue] | [LEVEL]         | [Classify and document] |
