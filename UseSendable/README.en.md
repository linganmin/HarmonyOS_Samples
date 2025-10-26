# Sendable Use Cases

### Overview

This sample demonstrates the following use cases of sendable data: multi-thread collaboration (log and dotting) in
producer-consumer pattern, and cross-thread communication and UI status update implemented through sendable objects.

### Preview

![](screenshots/device/UseSendable.en.gif)

#### How to Use

1. Touch **Sendable inter-thread sharing**. The **File downloads** page is displayed.
2. Touch **Start**. The button changes to **Pause**, and the progress bar increases by 20% each time.
3. When the progress bar reaches 100%, the button changes to **Finished**.
4. Touch **Pause**. The button changes to **Resume**, and the progress bar stops increasing.
5. Touch **Resume**. The button changes to **Pause**, and the progress bar increases by 20% each time.
6. Return to the home page and touch **Producer-consumer pattern**. The **Producer-consumer pattern** page is displayed.
7. Touch **One consumer thread consumes** and then **Main thread generates one log**. A log with **consumerOne** is printed.
8. Touch **Two consumer threads consume**, and touch **Main thread generates one log** multiple times. Logs with **consumerOne** and **consumerTwo** are printed.
9. Touch **Ten child threads generate ten logs**. Ten logs are generated.
10. Touch **Continuously generate logs**. Logs are continuously printed.
11. Touch **Stop continuous log generation**. Logs are no longer printed.
12. Touch **Stop consumer thread**.
13. Exit the app.

## Project Directory

```
├──entry/src/main/ets                         // Code
│  ├──constants
│  │  └──Constants.ets                        // Common constants
│  ├──downLoadFilePage
│  │  ├──model                                // Entity class  
│  │  ├──DownLoadComponent.ets                // Download components
│  │  ├──DownLoadFilePage.ets                 // File downloads page
│  │  └──DownLoadVideo.ets                    // Progress bar
│  ├──entryability
│  │  └──EntryAbility.ets                     // Entry ability             
│  ├──pages
│  │  └──Index.ets                            // Home page    
│  ├──producerConsumer
│  │  ├──model                                // Entity class  
│  │  ├──tasks                                // Task
│  │  └──ProducerConsumerPage.ets             // Producer-consumer pattern (log printing) page
│  └──utils
│     └──Logger.ets                           // Log utility
└──entry/src/main/resources                   // Static resources
```

### Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.