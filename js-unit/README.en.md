# Test Framework

### Overview
This sample shows how to use the unit test framework.

The code component repository arkXtest of the automatic test framework is used. If log printing and debugging are required, the log printing API **@ohos.hilog** needs to be introduced. 

Compared with UI automation test cases, unit test cases focus more on the verification and logic processing of data returned by APIs.


### Preview
N/A

How to Use
- Import the project in the **JsUnit directory** to DevEco Studio.
- Check the test code implementation in the **ohostest** directory.
- Execute the test case code in DevEco Studio to view the execution effect. For details, see the test framework section in the guide on the official website.

### Project Directory

```
├──entry/src/ohosTest/ets                         // Code area
│  ├──test
│  │  ├──assertExampleTest                        
│  │  │  └──assertExample.test.ets                // Assertion automation test script
│  │  ├──basicExampleTest                        
│  │  │  └──basicExample.test.ets                 // Basic automation test script
│  │  ├──callBackExampleTest                        
│  │  │  └──callBackExample.test.ets              // Callback automation test script
│  │  ├──coverExampleTest                        
│  │  │  └──coverExample.test.ets                 // Nested automation test script
│  │  ├──customExampleTest                        
│  │  │  └──customExample.test.ets                // Custom automation test script
│  │  ├──paramExampleTest                        
│  │  │  └──paramExample.test.ets                 // Parameter automation test script
│  │  ├──data.json                                // json data file
│  │  └──List.test.ets                            // Test script list
│  ├──testability
│  │  ├──pages
│  │  │  └──Index.ets                             // Home page
│  │  └──TestAbility.ets   
│  ├──testrunner                       
│  │  └──OpenHarmonyTestRunner.ets                
│  └──util                       
│      └──Logger.ets                              // Logger
└──entry/src/ohosTest/resources                   // App resource directory
```

### How to Implement

#### Example of the jsunit unit test framework
* 1) Place page components in **index.ets** of **entry**.
* 2) Define a test case in **it()** in **test/basicExample.test.ets** of **ohosTest**. Three parameters are supported: case name, filtering parameter, and case function. The behavior of the use case operation is written asynchronously.
* 3) Call **Want ()** to specify a unique ability, that is, entry. Call **want()** to specify **bundleName** (com.samples.test.jsunit) and **abilityName** (EntryAbility).
* 4) Start a specified ability (equivalent to manually running the HAP) by calling **abilityDelegatorRegistry.getAbilityDelegator.startAbility(want)**.
* 5) Obtain the top-level ability object of the current application by calling **abilityDelegatorRegistry.getAbilityDelegator.getCurrentTopAbility().then((ability)=>{})**.
* 6) Add the following test content to ****.then()**** in step 5:
    * For example, to check whether the ability name of the current UIAbility is correct, introduce the assertion API in step 5 and check whether the assertion result meets the expectation. Use the expect().assertEqual() assertion to check whether the actual value is equal to the expected value.
* 7) Complete the test by calling **done ()**.

### Required Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
