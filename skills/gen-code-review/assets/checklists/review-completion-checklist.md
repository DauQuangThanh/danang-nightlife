# Review Completion Checklist

Use this checklist to verify the review itself is complete and thorough.

## Coverage

- [ ] All files in scope have been reviewed
- [ ] Changed files were prioritized over unchanged files
- [ ] Entry points and public APIs received extra scrutiny

## Finding Quality

- [ ] Every finding includes file path and line number
- [ ] Every finding includes explanation of why it matters
- [ ] Every MUST FIX and SHOULD FIX includes a concrete suggested fix
- [ ] Findings are categorized by severity (MUST FIX / SHOULD FIX / CONSIDER / PRAISE)

## Report Completeness

- [ ] Simplicity score (1-5) is provided with justification
- [ ] Maintainability score (1-5) is provided with justification
- [ ] Overall verdict is given (APPROVE / REQUEST CHANGES / NEEDS DISCUSSION)
- [ ] At least one PRAISE item is included
- [ ] Report follows the structured template from [templates/review-report.md](../../templates/review-report.md)
- [ ] Recommendations are ordered by impact (most impactful first)

## Review Principles

- [ ] All suggestions follow "simple > smart" principle
- [ ] Feedback addresses the code, not the person
- [ ] Framework-mandated patterns are not flagged
- [ ] Legacy code in unchanged files is noted as CONSIDER, not MUST FIX
- [ ] Performance complexity is accepted when backed by evidence
