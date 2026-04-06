# Step 5: Generate Remediation Plan

## RULES

- Every gap from Step 4 MUST have a corresponding remediation action.
- Remediation actions MUST be specific and implementable -- not vague guidance.
- SLAs are non-negotiable: Critical 24h, High 72h, Medium 1 sprint, Low backlog.
- Remediation for banned patterns MUST include the specific alternative pattern from the banned patterns table.
- Error handling remediation MUST follow fail-closed principles.

## INSTRUCTIONS

1. For each gap identified in Step 4, produce a remediation entry:
   - Gap ID (from Step 4)
   - Severity and SLA
   - Specific remediation action (imperative instructions, not suggestions)
   - Code pattern or configuration change required
   - Files to modify
   - Verification method (how to confirm the fix works)

2. For GDPR gaps, provide specific remediation patterns:
   - Missing consent mechanism: implement granular consent with records (timestamp, version, IP, user agent, consent text)
   - Missing data subject rights: implement endpoints for access, rectification, erasure, portability, restriction, objection
   - Data minimization violations: remove unnecessary data collection; implement pseudonymization (`sha256(user_id + daily_salt)`)
   - Missing retention enforcement: add scheduled job to auto-delete expired data

   Example GDPR-compliant data export:
   ```python
   @router.get("/api/v1/me/data-export")
   async def export_my_data(
       current_user: User = Depends(get_current_user),
       service: DataExportService = Depends(get_export_service),
   ) -> StreamingResponse:
       """GDPR Article 20: Right to data portability."""
       audit_log.info("data_export_requested", user_id=str(current_user.id))
       data = await service.export_user_data(current_user.id)
       return StreamingResponse(
           content=data.to_json_stream(),
           media_type="application/json",
           headers={"Content-Disposition": f"attachment; filename=my-data-{date.today()}.json"},
       )
   ```

3. For HIPAA gaps, provide specific remediation patterns:
   - PHI in logs: remove PHI fields from log statements; log only resource IDs
   - Missing encryption: add AES-256 at rest; enforce TLS 1.2+ in transit
   - Overly broad API responses: create purpose-specific DTOs returning only required fields
   - Missing BAAs: identify all third-party services handling PHI; obtain signed BAAs

4. For SOC2 gaps, provide specific remediation patterns:
   - Missing MFA: enable MFA for all production system access
   - Shared accounts: create unique accounts with RBAC
   - Missing monitoring: implement health endpoints, error rate alerts, latency alerts, auth failure alerts
   - Missing change management: enforce PR reviews, security scanning gates, deployment approvals

5. For PCI-DSS gaps, provide specific remediation patterns:
   - Storing CVV/track data: remove storage; implement tokenization via payment processor
   - Unmasked PAN: mask to show only first 6 and last 4 digits
   - Missing network segmentation: isolate CDE in separate VPC; configure firewall rules

   Example PCI-DSS compliant payment flow:
   ```python
   @router.post("/api/v1/payments")
   async def create_payment(
       request: CreatePaymentRequest,  # Contains payment_token, NOT card number
       service: PaymentService = Depends(get_payment_service),
   ) -> PaymentResponse:
       result = await service.process_payment(request.payment_token, request.amount)
       audit_log.info("payment_processed", payment_id=str(result.id), amount=request.amount)
       return PaymentResponse(id=result.id, status=result.status)
   ```

6. For error handling gaps, provide fail-closed patterns:
   - Consent service unavailable: deny processing of consent-dependent data
   - Audit log ingestion failure: buffer events locally and retry; if unavailable for more than 5 minutes, alert on-call and halt sensitive data processing
   - Data export timeout: use async job pattern with 202 Accepted and polling URL
   - Encryption key rotation failure: halt new encryption operations until key management is restored

7. Order the remediation plan by severity (Critical first, then High, Medium, Low).

8. Group related remediations that can be addressed together (e.g., all audit logging gaps in one work item).

## VALIDATION

- [ ] Every gap from Step 4 has a corresponding remediation action
- [ ] Each remediation includes specific code patterns or configuration changes
- [ ] Each remediation includes files to modify
- [ ] Each remediation includes a verification method
- [ ] SLAs are assigned and match severity levels
- [ ] Remediation plan is ordered by severity
- [ ] Banned pattern remediations reference the specific alternative

Proceed to [./step-06-validate-compliance.md](step-06-validate-compliance.md)
