# **Remote Communication Platform**
## Overview
Remote communication platform (RCP) provides network data request functionalities. Compared with the HTTP request capability in Network Kit, RCP is easier to use and stands out with the following features:

* Sending PATCH requests

* Setting BaseURL

* Canceling the specified or ongoing session request.

* Customizing certificate verification based on service requirements.

* Customizing DNS resolution.

* Caching responses by custom interceptors

* Capturing detailed tracing information during the HTTP request in a session

## Preview
![](screenshots/device/rcp_en.gif)

## Project Directory
````
├──entry/src/main/ets                                   // Code
│  ├──common
│  |  ├──CommonConstants.ets                            // Constants
│  |  └──Logger.ets                                     // Logging utility
│  ├──entryability
│  |  └──EntryAbility.ets                               // Entry ability
│  ├──entrybackupability
│  |  └──EntryBackupAbility.ets
│  ├──pages
│  |  ├──BaseRequest.ets                                // Basic structure and logic for making network requests
│  |  ├──DNSSetting.ets                                 // DNS settings
│  │  └──Index.ets                                      // Home page
│  |  ├──MultipartForm.ets                              // APIs for handling multipart form data, useful for handling complex form submissions
│  |  ├──RequestAndResponse.ets                         // Request and response example
│  |  └──TracingPoint.ets                               // Tracing and logging HTTP requests and responses
|  └──utils.ets
│     ├──Interceptors.ets                               // Utility for intercepting network requests and responses
│     └──NetworkStateSimulator.ets                      // Utility for simulating a slow-speed network
└──entry/src/main/resources                             // Static resources of the app
````
## Required Permissions
ohos.permission.INTERNET: allows an app to access Internet.

## Constraints
* The sample app is supported only on Huawei phones running the standard system.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.