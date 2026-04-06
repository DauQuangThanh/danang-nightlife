# Step 1: Identify Applicable Frameworks

## RULES

- Every application MUST be evaluated against all four frameworks (GDPR, HIPAA, SOC2, PCI-DSS) before any can be excluded.
- A framework is applicable if ANY data type or processing activity falls under its scope.
- When in doubt, include the framework. False positives are preferable to missed obligations.
- Multi-jurisdiction data: apply the strictest applicable regulation. GDPR requirements typically supersede less strict local regulations.

## INSTRUCTIONS

1. Inventory all data types the application collects, processes, stores, or transmits.
2. For each data type, determine if it falls under any of these categories:
   - **PII** (names, emails, addresses, phone numbers, IP addresses) -- triggers GDPR review
   - **PHI** (health records, diagnoses, treatment data, insurance info) -- triggers HIPAA review
   - **Financial data** (revenue, contracts, internal metrics) -- triggers SOC2 review
   - **Cardholder data** (PAN, cardholder name, expiration date, service code) -- triggers PCI-DSS review
3. Determine the geographic scope of data subjects:
   - EU/EEA residents -- GDPR applies regardless of where the organization is based
   - US patients -- HIPAA applies if the organization is a covered entity or business associate
   - Any jurisdiction -- SOC2 applies if the organization stores customer data in a SaaS model
4. Determine the distribution model:
   - SaaS handling customer data -- SOC2 likely required
   - Processing payments -- PCI-DSS applies
   - Healthcare context -- HIPAA applies
5. Document the determination for each framework with rationale:
   - Framework name
   - Applicable: YES / NO
   - Rationale (which data types or processing activities trigger applicability)
   - Triggering data entities (list specific database tables, API fields, or data flows)
6. If the application serves users in multiple jurisdictions, list all applicable jurisdictions and note that the strictest regulation governs.

## VALIDATION

- [ ] All four frameworks (GDPR, HIPAA, SOC2, PCI-DSS) were explicitly evaluated
- [ ] Each determination includes a rationale referencing specific data types or processing activities
- [ ] Geographic scope of data subjects is documented
- [ ] Distribution model is documented
- [ ] At least one framework is identified as applicable (if none apply, document why and escalate for review)

Proceed to [./step-02-classify-data.md](step-02-classify-data.md)
