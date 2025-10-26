# Test Framework

### Overview

This sample shows how to use the unit test framework. 

The UiTest API **@ohos.UiTest** has to be introduced. 

If log printing debugging is required, **@ohos.hilog** has to be introduced additionally.

### Preview

N/A

### How to Use

- Import the project in the **uitest** directory to DevEco Studio.
- Check the test code implementation in the **ohostest** directory.
- Execute the test case code in DevEco Studio to view the execution effect. For details, see the test framework section in the guide on the official website.
- The execution result of the test case code in this project varies according to the actual development device. You can modify the parameters in the code as required.

### Project Directory

```
├──entry/src/main/ets                             // Core code
│  ├──clickability  
│  │  └──ClickAbility.ets                         // Tap entry class
│  ├──dragability  
│  │  └──DragAbility.ets                          // Dragging entry class
│  ├──entryability  
│  │  └──EntryAbility.ets                         // Entry point class
│  ├──flingability  
│  │  └──FlingAbility.ets                         // Inertial scrolling entry class
│  ├──inputability  
│  │  └──InputAbility.ets                         // Input entry class
│  ├──mouseability  
│  │  └──MouseAbility.ets                         // Mouse entry class
│  ├──pages  
│  │  ├──Click.ets                                // Page tapping
│  │  ├──Drag.ets                                 // Page dragging
│  │  ├──Fling.ets                                // Inertial page scrolling
│  │  ├──Fourth.ets                               // Page 4
│  │  ├──Index.ets                                // Home page
│  │  ├──Input.ets                                // Input page
│  │  ├──Mouse.ets                                // Mouse page
│  │  ├──Pinch.ets                                // Pinch page
│  │  ├──Scroller.ets                             // Scrolling page
│  │  ├──Swipe.ets                                // Swiping page
│  │  └──Third.ets                                // Page 3
│  ├──pinchability  
│  │  └──PinchAbility.ets                         // Pinch entry class
│  ├──pointmatrixability  
│  │  └──PointMatrixAbility.ets                   // Matrix entry class
│  ├──scrollerability  
│  │  └──ScrollerAbility.ets                      // Scrolling entry class
│  ├──swipeAbility  
│  │  └──SwipeAbility.ets                         // Swiping entry class
│  └──util  
│     └──Logger.ets                               // Logger
├──entry/src/main/resources                       // App resources
├──entry/src/ohosTest/ets                         // Code area
│  ├──test
│  │  ├──BasicExampleTest                        
│  │  │  └──BasicExample.test.ets                 // Basic automation test script
│  │  ├──findCommentExampleTest                        
│  │  │  ├──component
│  │  │  │  └──FindCommentExample.test.ets        // Find the component automation script.
│  │  │  └──window
│  │  │     └──FindWindowExample.test.ets         // Search window automation script
│  │  ├──operationExampleTest                        
│  │  │  ├──ui
│  │  │  │  ├──ClickEvent.test.ets                // Tap event automation script
│  │  │  │  ├──FlingEvent.test.ets                //  Automation script for inertial scrolling events
│  │  │  │  ├──InputEvent.test.ets                // Input event automation script
│  │  │  │  ├──MouseEvent.test.ets                // Mouse event automation script
│  │  │  │  ├──PinchEvent.test.ets                // Pinch event automation script
│  │  │  │  ├──PointMatrixEvent.test.ets          // Matrix event automation script
│  │  │  │  ├──ScreenCapEvent.test.ets            // Automation script for screen capture events
│  │  │  │  ├──ScrollerEvent.test.ets             // Scrolling event automation script
│  │  │  │  └──SwipeEvent.test.ets                // Swiping event automation script
│  │  │  └──window
│  │  │     ├──MoveToEvent.test.ets               // Move event automation script
│  │  │     │ ReSizeWindow.test.ets               // Window resize automation script
│  │  │     └──WindowAttr.test.ets                // Automation script for obtaining the window
│  │  └──List.test.ets                            // Test script list
│  ├──testability
│  │  ├──pages
│  │  │  └──Index.ets                             // Home page
│  │  └──TestAbility.ets   
│  ├──testrunner                       
│  │  └──OpenHarmonyTestRunner.ets  
│  └──util                       
│     └──Logger.ts                                // Logger
└──entry/src/ohosTest/resources                   // App resource directory
```

 Notes:

- The prerequisite is to import **UiTest dependency import {Driver,ON,Component,Uiwindow,MatchPattern}** from **'@ohos.UiTest'**. 
1. All APIs provided by the **On** class are synchronous. You can use the builder mode to implement the chain call of APIs to construct component filtering conditions. 
2. All the APIs provided by the **Driver** and **Component** classes are asynchronous (in Promise mode), and the await syntax must be used. 
3. All UI test cases must be written in the asynchronous syntax and comply with the asynchronous test case specifications of JsUnit.

### How to Implement

#### Example of the uitestUI test framework

- 1) Place page components in **index.ets** of **entry**.
- 2) Define a test case in **it()** in **test/basicExample.test.ets** of **ohosTest**. Three parameters are supported: case name, filtering parameter, and case function. The behavior of the use case operation is written asynchronously.
- 3) Specify a unique ability as the entry by setting **bundleName and abilityName (EntryAbility)** in **want()**.
- 4) Start a specified ability (equivalent to manually running the HAP) by calling **abilityDelegatorRegistry.getAbilityDelegator.startAbility(want)**.
- 5) Obtain the top-level ability object of the current application by calling **abilityDelegatorRegistry.getAbilityDelegator.getCurrentTopAbility().then((ability)=>{})**.
- 6) Introduce the **Driver** class as the main entry of the UiTest framework to provide capabilities such as the search control, timer, assertion, and single-node back key.
- 7) Add the following test content to **.then()** in step 5: 
  - For example, call **driver.pressBack()** to check whether the back key is available in this sample. 
  - Check whether the execution can be performed after 1s using **driver.delayMs(1000)**. 
  - Log printing: It is recommended that the package name in the sample and that in the log be represented by constants, for example, **hilog.info(DOMAIN, TAG, BUNDLE + "StartAbility_001, begin")**, to facilitate package name changing and rectification.
- 8) End **event done ()**.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
