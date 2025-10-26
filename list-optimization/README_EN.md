# List Optimization

### Overview
This sample demonstrates the use of **ForEach** for rendering a long list, and contrasts it with **LazyForEach**, which leverages caching of list items and component reuse, to optimize the performance of long list. The comparison includes metrics such as total display time and frame loss rate.

### Preview
| ForEach Page                        | LazyForEach Page                        | 
|-------------------------------------|-----------------------------------------|
| ![](screenshots/device/ForEach.png) | ![](screenshots/device/LazyForEach.png) | 


How to Use

1. Start the app, and use **Frame** in **Profiler** of DevEco Studio to record the frame loss rate of the app in **ForEach** and **LazyForEach**.

2. Tap **ForEach** and **LazyForEach**, and record the time used to display all the information.

3. Tap **ForEach** and **LazyForEach**, and record the frame loss rate.

4. To facilitate comparison, data files of different sizes are provided in the **src/main/resources/rawfile** directory.


### Project Directory
```
├──entry/src/main/ets/
│  ├──components
│  │  ├──ArticleCardView.ets  
│  │  └──ReusableArticleCardView.ets  
│  ├──constants 
│  │  └──Constants.ets  
│  ├──entryability
│  │  └──EntryAbility.ets  
│  ├──model
│  │  ├──ArticleListData.ets  
│  │  └──LearningResource.ets         
│  ├──pages
│  │  ├──basicPre.ets 
│  │  ├──ForEachListPage.ets
│  │  ├──Header.ets
│  │  ├──Index.ets
│  │  ├──LazyForEachListPage.ets  
│  │  ├──prefetching.ets
│  │  └──song.ets
│  └──utils
│     ├──Logger.ets
│     └──ObservedArray.ets      
└──entry/src/main/resources                              
```

### How to Implement
The implementation of the long **ForEach** list is as follows:

1. Load list data locally to simulate a data request.

2. Use **ForEach** and the list item component to implement a long list.

The implementation of the long **LazyForEach** list is as follows:

1. Implement the **IDataSource** interface.

2. Load list data locally to simulate a data request.

3. Implement the **LazyForEach** list item component. Call **cachedCount** of **LazyForEach**. Use the @Reuseable annotation to reuse components to maximize the optimization.


### Required Permissions
**ohos.permission.INTERNET**: allows an app to access Internet.

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
