# Salesforce Well-Architected Framework - Architecture & Security Audit Prompt

## Audit Overview
Perform a comprehensive architecture and security audit of the Salesforce implementation based on the Salesforce Well-Architected Framework. This audit evaluates three core pillars with weighted importance: **Trusted (35%)**, **Easy (30%)**, and **Adaptable (35%)**.

## Scoring System
- Each section should be scored from 1-10 (10 being best practice implementation)
- Final score = (Trusted Score × 0.35) + (Easy Score × 0.30) + (Adaptable Score × 0.35)
- Provide specific recommendations for any score below 7

---

## PILLAR 1: TRUSTED (35% Weight)

### 1.1 SECURE (15% of total weight - 43% of Trusted pillar)

#### Identity & Access Management (5% total weight)
**Evaluation Criteria:**
- [ ] Multi-factor authentication enforced for all users
- [ ] Role-based access control properly implemented
- [ ] Permission sets used appropriately vs profiles
- [ ] Session security settings optimized
- [ ] Login IP ranges and login hours configured where appropriate
- [ ] Single Sign-On (SSO) implementation follows security best practices

**Audit Questions:**
1. How is user authentication handled? Is MFA enforced?
2. Are permission sets used instead of modifying standard profiles?
3. Is the principle of least privilege applied?
4. How are service accounts and integrations authenticated?
5. Are there any shared accounts or generic logins?

**Score: ___/10**

#### Data Protection (4% total weight)
**Evaluation Criteria:**
- [ ] Field-level security implemented appropriately
- [ ] Sharing rules align with business requirements
- [ ] Platform encryption enabled where required
- [ ] Data classification implemented
- [ ] Privacy controls for sensitive data (PII, PHI)
- [ ] Data masking in non-production environments

**Audit Questions:**
1. What data classification scheme is used?
2. How is sensitive data protected at rest and in transit?
3. Are sharing rules minimizing data exposure?
4. Is platform encryption configured for sensitive fields?
5. How is data anonymized in sandboxes?

**Score: ___/10**

#### Application Security (3% total weight)
**Evaluation Criteria:**
- [ ] Secure coding practices in custom code
- [ ] Input validation and sanitization
- [ ] SOQL injection prevention
- [ ] Cross-site scripting (XSS) protection
- [ ] CSRF protection enabled
- [ ] Secure API development practices

**Audit Questions:**
1. Are dynamic SOQL queries avoided or properly sanitized?
2. How is user input validated in custom components?
3. Are security review guidelines followed for custom code?
4. How are Lightning components secured against XSS?
5. Are API endpoints properly secured and rate-limited?

**Score: ___/10**

#### Network Security (3% total weight)
**Evaluation Criteria:**
- [ ] API security best practices implemented
- [ ] Network access controls configured
- [ ] SSL/TLS properly configured
- [ ] IP restrictions where appropriate
- [ ] CORS policies properly configured
- [ ] Rate limiting on APIs

**Audit Questions:**
1. How are external API calls secured?
2. Are IP restrictions in place for sensitive operations?
3. Is HTTPS enforced for all connections?
4. How are CORS policies configured for Lightning components?
5. What network monitoring is in place?

**Score: ___/10**

### 1.2 COMPLIANT (10% of total weight - 29% of Trusted pillar)

#### Regulatory Compliance (4% total weight)
**Evaluation Criteria:**
- [ ] GDPR compliance measures implemented
- [ ] Industry-specific regulations addressed (HIPAA, SOX, etc.)
- [ ] Data residency requirements met
- [ ] Right to be forgotten processes
- [ ] Consent management implemented
- [ ] Audit trail maintained

**Audit Questions:**
1. What regulatory requirements apply to this org?
2. How is data residency managed?
3. Are consent and privacy preferences tracked?
4. How are data subject rights handled?
5. What audit trails are maintained?

**Score: ___/10**

#### Governance Framework (3% total weight)
**Evaluation Criteria:**
- [ ] Change management processes established
- [ ] Approval workflows for critical changes
- [ ] Documentation standards maintained
- [ ] Policy enforcement mechanisms
- [ ] Regular governance reviews conducted
- [ ] Compliance monitoring automated

**Audit Questions:**
1. What change management process is followed?
2. How are policies enforced in the system?
3. What approval processes exist for sensitive operations?
4. How is compliance monitored and reported?
5. Are governance roles clearly defined?

**Score: ___/10**

#### Data Governance (3% total weight)
**Evaluation Criteria:**
- [ ] Data retention policies implemented
- [ ] Data quality standards enforced
- [ ] Master data management strategy
- [ ] Data lineage tracking
- [ ] Data stewardship roles defined
- [ ] Data archival processes

**Audit Questions:**
1. How are data quality issues identified and resolved?
2. What data retention policies are in place?
3. How is master data managed across systems?
4. Are data steward roles clearly defined?
5. How is data lineage tracked for critical data?

**Score: ___/10**

### 1.3 RELIABLE (10% of total weight - 29% of Trusted pillar)

#### Availability & Uptime (4% total weight)
**Evaluation Criteria:**
- [ ] Disaster recovery plan exists and tested
- [ ] Business continuity measures implemented
- [ ] SLA requirements defined and monitored
- [ ] Backup and restore procedures tested
- [ ] High availability architecture where needed
- [ ] Incident response procedures defined

**Audit Questions:**
1. What disaster recovery procedures are in place?
2. How often are backups tested for restoration?
3. What are the RTO and RPO requirements?
4. How is system availability monitored?
5. What incident response procedures exist?

**Score: ___/10**

#### Performance Optimization (3% total weight)
**Evaluation Criteria:**
- [ ] Query optimization implemented
- [ ] Bulk processing patterns used
- [ ] Caching strategies implemented
- [ ] Resource utilization monitored
- [ ] Governor limits proactively managed
- [ ] Performance baselines established

**Audit Questions:**
1. How are SOQL queries optimized?
2. Are bulk processing patterns used in integrations?
3. How are governor limits monitored and managed?
4. What caching mechanisms are implemented?
5. How is performance measured and optimized?

**Score: ___/10**

#### Monitoring & Alerting (3% total weight)
**Evaluation Criteria:**
- [ ] Real-time monitoring systems in place
- [ ] Error tracking and logging comprehensive
- [ ] Performance metrics collected and analyzed
- [ ] Proactive alerting configured
- [ ] Dashboard and reporting systems
- [ ] Automated health checks

**Audit Questions:**
1. What monitoring tools are in use?
2. How are errors tracked and escalated?
3. What performance metrics are collected?
4. How are system health checks automated?
5. What alerting mechanisms are in place?

**Score: ___/10**

**TRUSTED PILLAR TOTAL SCORE: ___/10**

---

## PILLAR 2: EASY (30% Weight)

### 2.1 INTENTIONAL (12% of total weight - 40% of Easy pillar)

#### Architecture Design (4% total weight)
**Evaluation Criteria:**
- [ ] Solution architecture documented and followed
- [ ] Integration patterns properly implemented
- [ ] Data architecture optimized
- [ ] Technical design reviews conducted
- [ ] Architecture decisions documented
- [ ] Scalability considerations addressed

**Audit Questions:**
1. Is there a documented solution architecture?
2. How are integration patterns standardized?
3. What data architecture principles are followed?
4. How are architectural decisions tracked?
5. How is the architecture reviewed and updated?

**Score: ___/10**

#### User Experience Design (4% total weight)
**Evaluation Criteria:**
- [ ] UI consistency across applications
- [ ] Accessibility compliance (WCAG)
- [ ] Mobile responsiveness implemented
- [ ] User journey optimization
- [ ] Design system implemented
- [ ] Usability testing conducted

**Audit Questions:**
1. How is UI consistency maintained?
2. What accessibility standards are followed?
3. How is mobile experience optimized?
4. Are user journeys documented and optimized?
5. What usability testing processes exist?

**Score: ___/10**

#### Business Process Alignment (4% total weight)
**Evaluation Criteria:**
- [ ] Process automation aligned with business needs
- [ ] Workflow optimization implemented
- [ ] Business rules properly implemented
- [ ] Exception handling comprehensive
- [ ] Process documentation maintained
- [ ] Stakeholder alignment achieved

**Audit Questions:**
1. How are business processes documented?
2. Are workflows optimized for efficiency?
3. How are business rules implemented and maintained?
4. What exception handling exists?
5. How is stakeholder feedback incorporated?

**Score: ___/10**

### 2.2 AUTOMATED (10% of total weight - 33% of Easy pillar)

#### DevOps & CI/CD (4% total weight)
**Evaluation Criteria:**
- [ ] Continuous integration pipelines implemented
- [ ] Automated testing frameworks in place
- [ ] Deployment automation configured
- [ ] Release management processes
- [ ] Version control best practices
- [ ] Environment management strategy

**Audit Questions:**
1. What CI/CD tools and processes are used?
2. How is automated testing implemented?
3. What deployment strategies are followed?
4. How are releases managed and tracked?
5. What version control practices are followed?

**Score: ___/10**

#### Process Automation (3% total weight)
**Evaluation Criteria:**
- [ ] Business process automation implemented
- [ ] Workflow triggers optimized
- [ ] Data synchronization automated
- [ ] Event-driven architecture utilized
- [ ] Integration automation in place
- [ ] Manual processes minimized

**Audit Questions:**
1. What business processes are automated?
2. How are workflow triggers optimized?
3. What data synchronization processes exist?
4. How are events handled in the system?
5. What manual processes could be automated?

**Score: ___/10**

#### Monitoring & Analytics (3% total weight)
**Evaluation Criteria:**
- [ ] Automated reporting systems implemented
- [ ] Performance analytics in place
- [ ] Usage metrics collected
- [ ] Predictive analytics utilized
- [ ] Real-time dashboards available
- [ ] Data-driven decision making enabled

**Audit Questions:**
1. What automated reporting exists?
2. How are performance metrics analyzed?
3. What usage analytics are collected?
4. How is predictive analytics implemented?
5. What real-time monitoring exists?

**Score: ___/10**

### 2.3 ENGAGING (8% of total weight - 27% of Easy pillar)

#### User Adoption (3% total weight)
**Evaluation Criteria:**
- [ ] Training programs implemented
- [ ] Change management strategies in place
- [ ] User feedback mechanisms active
- [ ] Adoption metrics tracked
- [ ] User onboarding optimized
- [ ] Support systems available

**Audit Questions:**
1. What training programs exist for users?
2. How is change management handled?
3. What user feedback mechanisms are in place?
4. How are adoption metrics measured?
5. What user support systems exist?

**Score: ___/10**

#### Communication & Collaboration (3% total weight)
**Evaluation Criteria:**
- [ ] Team collaboration tools implemented
- [ ] Knowledge sharing platforms active
- [ ] Communication workflows optimized
- [ ] Documentation accessible
- [ ] Cross-team coordination effective
- [ ] Information sharing streamlined

**Audit Questions:**
1. What collaboration tools are used?
2. How is knowledge shared across teams?
3. What communication workflows exist?
4. How accessible is documentation?
5. How is cross-team coordination managed?

**Score: ___/10**

#### Innovation & Continuous Improvement (2% total weight)
**Evaluation Criteria:**
- [ ] Innovation processes established
- [ ] Feedback loops implemented
- [ ] Continuous learning culture fostered
- [ ] Technology adoption strategies in place
- [ ] Improvement initiatives tracked
- [ ] Best practice sharing encouraged

**Audit Questions:**
1. What innovation processes exist?
2. How are feedback loops implemented?
3. What continuous learning initiatives exist?
4. How are new technologies evaluated?
5. What improvement tracking mechanisms exist?

**Score: ___/10**

**EASY PILLAR TOTAL SCORE: ___/10**

---

## PILLAR 3: ADAPTABLE (35% Weight)

### 3.1 RESILIENT (18% of total weight - 51% of Adaptable pillar)

#### Error Handling & Recovery (6% total weight)
**Evaluation Criteria:**
- [ ] Exception handling strategies comprehensive
- [ ] Graceful degradation patterns implemented
- [ ] Recovery mechanisms automated
- [ ] Rollback procedures tested
- [ ] Error logging comprehensive
- [ ] Recovery time objectives met

**Audit Questions:**
1. How are exceptions handled in custom code?
2. What graceful degradation patterns exist?
3. How are recovery procedures automated?
4. What rollback capabilities exist?
5. How are errors logged and tracked?

**Score: ___/10**

#### Scalability & Performance (6% total weight)
**Evaluation Criteria:**
- [ ] Horizontal scaling patterns implemented
- [ ] Performance under load tested
- [ ] Resource optimization ongoing
- [ ] Capacity planning processes in place
- [ ] Load testing conducted regularly
- [ ] Performance baselines maintained

**Audit Questions:**
1. How does the system scale under increased load?
2. What load testing is performed?
3. How is capacity planning conducted?
4. What performance optimization is ongoing?
5. How are performance baselines maintained?

**Score: ___/10**

#### Risk Management (6% total weight)
**Evaluation Criteria:**
- [ ] Risk assessment frameworks implemented
- [ ] Mitigation strategies defined
- [ ] Business impact analysis conducted
- [ ] Contingency planning in place
- [ ] Risk monitoring ongoing
- [ ] Risk communication established

**Audit Questions:**
1. What risk assessment processes exist?
2. How are risks mitigated?
3. What business impact analysis exists?
4. What contingency plans are in place?
5. How is risk monitored and communicated?

**Score: ___/10**

### 3.2 COMPOSABLE (17% of total weight - 49% of Adaptable pillar)

#### Modular Architecture (6% total weight)
**Evaluation Criteria:**
- [ ] Microservices patterns implemented where appropriate
- [ ] API-first architecture followed
- [ ] Service-oriented architecture principles applied
- [ ] Decoupled system design implemented
- [ ] Component reusability maximized
- [ ] Interface standardization achieved

**Audit Questions:**
1. How modular is the current architecture?
2. Are API-first principles followed?
3. How are services decoupled?
4. What component reusability exists?
5. How are interfaces standardized?

**Score: ___/10**

#### Integration Capabilities (6% total weight)
**Evaluation Criteria:**
- [ ] API management and governance implemented
- [ ] Data integration patterns standardized
- [ ] Event-driven integrations utilized
- [ ] Third-party connectivity optimized
- [ ] Integration monitoring in place
- [ ] Integration testing comprehensive

**Audit Questions:**
1. How are APIs managed and governed?
2. What data integration patterns are used?
3. How are events handled across systems?
4. How is third-party connectivity managed?
5. What integration testing exists?

**Score: ___/10**

#### Extensibility & Customization (5% total weight)
**Evaluation Criteria:**
- [ ] Custom development frameworks established
- [ ] Extension points and hooks available
- [ ] Configuration management optimized
- [ ] Customization without core modification achieved
- [ ] Upgrade path preservation maintained
- [ ] Backwards compatibility considered

**Audit Questions:**
1. How extensible is the current system?
2. What customization frameworks exist?
3. How is configuration managed?
4. How are upgrades handled with customizations?
5. What extension points are available?

**Score: ___/10**

**ADAPTABLE PILLAR TOTAL SCORE: ___/10**

---

## FINAL AUDIT SUMMARY

### Overall Score Calculation
- **Trusted Pillar Score**: ___/10 × 35% = ___
- **Easy Pillar Score**: ___/10 × 30% = ___
- **Adaptable Pillar Score**: ___/10 × 35% = ___

**FINAL WELL-ARCHITECTED SCORE: ___/10**

### Recommendations Priority Matrix

#### Critical Issues (Score < 5)
List all areas scoring below 5 with immediate action plans:

#### High Priority Improvements (Score 5-6)
List areas needing attention within 3 months:

#### Medium Priority Enhancements (Score 7-8)
List areas for improvement within 6 months:

#### Low Priority Optimizations (Score 9+)
List areas for future consideration:

### Action Plan
1. **Immediate Actions (Next 30 days)**
2. **Short-term Improvements (Next 90 days)**
3. **Medium-term Enhancements (Next 6 months)**
4. **Long-term Strategic Initiatives (Next 12+ months)**

### Compliance & Risk Assessment
- **Regulatory Compliance Status**
- **Security Risk Level**
- **Business Continuity Readiness**
- **Scalability Readiness**

---

*This audit should be conducted quarterly or after significant architectural changes. Each recommendation should include specific implementation steps, resource requirements, and success criteria.*