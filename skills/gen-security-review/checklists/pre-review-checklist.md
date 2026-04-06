# Pre-Review Checklist

Complete this checklist before starting a security review to ensure you have the necessary context and access.

## Context Gathering

- [ ] **Application type identified**: API service / web app / microservice / CLI tool / serverless / library
- [ ] **Primary language and framework identified**: (e.g., Python/FastAPI, Java/Spring, Node/Express)
- [ ] **Authentication model documented**: JWT / session-based / OAuth / API keys / none
- [ ] **Data sensitivity classified**: PII / financial / health records / credentials / low sensitivity
- [ ] **Trust boundaries mapped**: External input entry points identified

## Access Verified

- [ ] Source code files accessible and readable
- [ ] Configuration files available (`.env.example`, `config/`, `settings.py`, `application.yml`)
- [ ] Dependency manifests available (`package.json`, `requirements.txt`, `pom.xml`, `go.mod`, `.csproj`)
- [ ] Auth middleware/guard code located
- [ ] CORS and security header configuration located

## Scope Defined

- [ ] **Files in scope listed** (or "entire repo" if full audit)
- [ ] **Priority areas identified**:
  - [ ] Authentication/authorization code
  - [ ] Input handling (controllers, routes, API handlers)
  - [ ] Data access layer (repositories, queries, ORM calls)
  - [ ] Configuration and deployment files
- [ ] **Out of scope documented** (if any areas excluded)

## Existing Security Controls Noted

- [ ] WAF presence: Yes / No / Unknown
- [ ] Rate limiting: Yes / No / Unknown
- [ ] CORS policy reviewed: Yes / No
- [ ] CSP headers reviewed: Yes / No
- [ ] Dependency scanning in CI: Yes / No / Unknown

## Review Parameters

- [ ] **Severity thresholds defined**: Which severities block merge?
- [ ] **Review depth**: Full audit / changed files only / targeted area
- [ ] **Compliance requirements**: GDPR / HIPAA / SOC2 / PCI-DSS / none
