# Face Detection

## Overview

This sample code illustrates how to use the face detection capability of Core Vision Kit.

It simulates how to select an image, recognize face information, and display the result. The face information includes the face bounding boxes, facial landmark positions, confidence, and facial orientation (Euler angle).

You need to use **@hms.ai.face.faceDetector.d.ts**, which contains the APIs for face detection.

## Preview

|         **App home screen**         |             **Selecting an image**            |             **Starting detection**            |
|:------------------------:|:--------------------------------:|:--------------------------------:|
| ![](screenshots/app_en.png) | ![](screenshots/selectImage_en.png) | ![](screenshots/faceResult_en.png) |

Instructions:

1. On the home screen of a mobile phone, tap **faceDetectorDemo** to start the app.
2. Tap **Select image** to select an image from the gallery or take a photo using the camera.
3. Tap **Start detection** to recognize face information. The result is displayed in text.

## Project Directory
```
├─entry/src/main/ets
│  ├─entryability
│  │  ├─EntryAbility.ets            // Entry ability
│  └─pages
│     └─Index.ets                   // App home screen
└─entry/src/main/resources          // Directory for storing resource files
```

## How to Implement

The APIs for the face detection control in this sample have been defined in **@hms.ai.face.faceDetector.d.ts**.
~~~
*   function detect(visionInfo: VisionInfo): Promise<Array<Face>>;
~~~
Before using the service, you need to import **faceDetector**.
Call the face detection API, pass an image to be recognized, and receive the processing result (text information). For details, please refer to **entry/src/main/ets/pages/Index.ets**.

## Required Permissions

N/A

## Dependencies

N/A

## Constraints

1. The sample app is only supported on Huawei phones, tablets, and 2-in-1 devices with standard systems.
2. The HarmonyOS version must be HarmonyOS NEXT Developer Beta1 or later.
3. The DevEco Studio version must be DevEco Studio NEXT Developer Beta1 or later.
4. The HarmonyOS SDK version must be HarmonyOS NEXT Developer Beta1 SDK or later.
