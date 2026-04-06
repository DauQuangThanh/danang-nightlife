# Step 2: Classify Data

## RULES

- ALL data handled by the application MUST be classified. Unclassified entities trigger a blocking review.
- Classification levels are: PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED. No other levels are permitted.
- When a data entity contains fields at multiple classification levels, the entity inherits the highest level.
- Classification MUST be reviewed annually and updated when data usage changes.

## INSTRUCTIONS

1. Enumerate every data entity in the application:
   - Database tables and their columns
   - API request and response DTOs
   - Message queue payloads
   - File storage objects
   - Cache entries
   - Log fields
2. Classify each entity according to this scheme:

   | Level        | Description                          | Examples                                  | Handling Requirements                                |
   | ------------ | ------------------------------------ | ----------------------------------------- | ---------------------------------------------------- |
   | PUBLIC       | Openly available information         | Marketing content, public documentation   | No special controls                                  |
   | INTERNAL     | Business internal data               | Employee directories, internal metrics    | Access control, no external sharing                  |
   | CONFIDENTIAL | Sensitive business or personal data  | PII (name, email, address), contracts     | Encryption at rest + transit, audit logging, access control |
   | RESTRICTED   | Highly sensitive regulated data      | PHI, payment cards, SSN, financial records| End-to-end encryption, strict access control, DLP, retention policies, on-prem processing where required |

3. For each CONFIDENTIAL and RESTRICTED entity, document:
   - Data retention period
   - Encryption requirements (algorithm, key management)
   - Access control requirements (who can access, under what conditions)
   - Applicable regulatory framework(s)
4. Produce the data classification register using the template at [../templates/data-classification-register.md](../templates/data-classification-register.md).
5. Flag any data entities that are currently unencrypted but classified as CONFIDENTIAL or RESTRICTED.
6. Flag any database tables or API responses that lack a documented classification.

## VALIDATION

- [ ] Every database table has a documented classification level
- [ ] Every API endpoint's request/response DTOs have documented classification levels
- [ ] CONFIDENTIAL and RESTRICTED entities have documented retention periods
- [ ] CONFIDENTIAL and RESTRICTED entities have documented encryption requirements
- [ ] No unclassified entities remain
- [ ] Data classification register is complete and uses the standard template

Proceed to [./step-03-assess-controls.md](step-03-assess-controls.md)
