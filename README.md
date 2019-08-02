# EASI-PRO SMART Applications

This is a demonstration of SMART-on-FHIR applications using the standalone launch to administer Patient-Reported Outcomes (PRO) instruments at point-of-care, more specifically– Patient Reported Outcomes Measurement Information System (PROMIS). This work was done as part of multi-site collaborative grant– EASI-PRO _(Electronic Health Record Access to Seamless Integration of PROMIS)_.

### Devices: iPad(s) & iPhone(s)

# Installation

### Step1. Download

1. Xcode is a requirement for publishing native iOS applications
2. `git clone --recursive https://github.com/chb/easipro-smart.git`
3. Make sure submodules [ResearchKit](http://researchkit.org) and [Swift-SMART](http://github.com/smart-on-fhir/swift-smart.git) are downloaded.

### Step2. Open `EASIPRO.xworkspace` in Xcode

1. Add `SwiftSMART.xcodeproj`
2. Add `AssessmentCenter.xcodeproj`
3. Add `ResearchKit.xcodeproj`
4. Add `EASIPRO-Clinic.xcodeproj`

### Step3. Build and Compile submodules (SwiftSMART, AssessmentCenter, ResearchKit)

### Step4. View General Tab for EASIPRO-Clinic project

1. Select Target- `EASIPRO-Clinic`
2. Find **Embedded Binaries** section and **Add** compiled frameworks
    - `SMART.frameworkiOS`
    - `AssessmentCenter.frameworkiOS`
    - `ResearchKit.frameworkiOS`

### Step5. SMART & AssessmentCenter settings

1. Open `AppDelegate` of the Apps (EASIPRO-Clinic)
2. Change `settings` as per the FHIR Server, protected servers are also supported
```swift
let settings = [
            "client_name"   : "easipro-clinic",
            "client_id"     : "app-client-id",
            "redirect"      : "easipro-clinic://smartcallback",
            "scope"         : "openid profile user/*.* launch"
        ]
```
3. Create a AssessmentCenter Client with endpoint, access identifier, access token
```
SMARTClient.shared.acClient = ACClient(baseURL: URL(string: "https://www.assessmentcenter.net/ac_api/2014-01/")!, accessIdentifier: "<# - AC Access Identifier - #>", token: "<# - AC Token - #>")
```
### Step6. Build and Run EASIPRO-Clinic! 

--------

# Grant

- NCATS EASIPRO / Harvard Catalyst CTSA
- Raheel Sayeed, Daniel Gottlieb, Kenneth Mandl (PI), Justin Starren (PI)
- Computational Health Informatics Program, Boston Children's Hospital



