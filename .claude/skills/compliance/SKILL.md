# Compliance Guidelines

## Core Principle

Compliance is not optional. It's a competitive advantage. Most competitors ignore these requirements — that's their problem, not yours.

## Data Protection Framework

### Before Processing ANY Personal Data

1. **Legal basis established?** (One of these required)
   - Consent (explicit, informed, documented)
   - Contract performance
   - Legal obligation
   - Legitimate interest (documented assessment)

2. **Data minimization applied?**
   - Only collect what's necessary
   - Don't ask for insurance info if you only need appointment date

3. **Consent mechanism in place?**
   - First-message consent for bots/automation
   - Clear, plain language explanation
   - Easy withdrawal option

### Consent Requirements

```typescript
// Consent record structure
interface ConsentRecord {
  contact_id: string
  consent_type: 'data_processing' | 'voice_recording' | 'marketing' | 'sms'
  granted: boolean
  granted_at: string | null  // ISO timestamp
  revoked_at: string | null
  source: string  // 'whatsapp_bot', 'voice_call', 'web_form'
  ip_address?: string
}

// ALWAYS check consent before processing
async function hasValidConsent(contactId: string, type: string): Promise<boolean> {
  const consent = await getLatestConsent(contactId, type)
  return consent?.granted && !consent?.revoked_at
}
```

### Data Subject Rights

Must be able to fulfill within 30 days:
- **Access** — What data do you have on me?
- **Rectification** — Fix incorrect data
- **Erasure** — Delete my data ("right to be forgotten")
- **Portability** — Export my data in machine-readable format
- **Objection** — Stop processing my data

**Implementation:** Build delete/export endpoints from day one, not as afterthought.

## Audit Logging

### What to Log

| Event | Required Fields |
|-------|----------------|
| Data access | who, what, when, why |
| Data modification | who, what changed, old value, new value, when |
| Data deletion | who, what, when, reason |
| Consent changes | who, type, granted/revoked, when |
| Authentication | user, success/failure, IP, timestamp |

### Log Format

```typescript
interface AuditLog {
  timestamp: string
  user_id: string | null
  action: 'create' | 'read' | 'update' | 'delete'
  table_name: string
  record_id: string
  old_values?: object
  new_values?: object
  ip_address?: string
  reason?: string
}
```

### Retention
- Audit logs: 5 years minimum
- Consent records: 5 years after last interaction
- Call recordings: Follow local law (90 days typical, configurable)
- Chat logs: 2 years default

## Data Residency

### Before Choosing Infrastructure

Ask: **Where will data be stored?**

| Client Location | Preferred Data Location | Notes |
|-----------------|------------------------|-------|
| Germany/EU | EU (Frankfurt, Dublin) | GDPR applies |
| Colombia | Colombia or US (with DPA) | Ley 1581 applies |
| US | US | State laws may apply |

### International Transfers

If data crosses borders:
- Document the transfer in data flow diagram
- Have Data Processing Agreement (DPA) in place
- Verify destination has "adequate protection" or use Standard Contractual Clauses

## Voice AI / Recording Specific

### Recording Disclosure (MANDATORY)

Before recording ANY call:
1. Disclose AI nature immediately
2. State call is being recorded
3. Get explicit consent or provide opt-out

```
"Hi, this is [Name], a digital assistant from [Company]. 
This call may be recorded for quality purposes. 
Is that okay with you?"
```

### Germany (§201 StGB)
- Recording without consent = criminal offense
- Consent must be EXPLICIT
- Two-party consent required

### EU AI Act (Article 50)
- Must disclose AI nature to caller
- No exceptions for "natural sounding" AI

## Documentation Checklist

Every project should have:
- [ ] Data Flow Diagram (where data comes from, goes to, who accesses)
- [ ] Data Retention Policy (how long each data type is kept)
- [ ] Privacy Impact Assessment (for high-risk processing)
- [ ] Data Subject Rights Procedure (how to handle requests)
- [ ] Processing Agreement (if using third-party processors)
- [ ] Consent mechanism documentation

## Country-Specific Triggers

### If client is in Germany:
- DSGVO (German GDPR) applies
- Stricter enforcement, higher scrutiny
- Betriebsrat (works council) may need involvement for employee-facing systems

### If client is in Colombia:
- Ley 1581 of 2012 applies
- SIC Directive 002/2024 for AI systems
- Register databases with RNBD if required

### If processing health data:
- Always "sensitive data" category
- Higher security requirements
- Privacy Impact Assessment mandatory
- Consider HIPAA if US patients involved

## Red Flags — STOP and Verify

- Client says "don't worry about compliance"
- No consent mechanism planned
- Health/financial data with no encryption plan
- Cross-border transfer with no documentation
- "We'll add privacy policy later"
- No plan for data deletion requests
