# Custom Dialog Set

### Overview

This sample uses CustomDialog, bindContentCover, and bindSheet to implement multiple custom dialog pop-ups.

### Preview

| Slide-to-select dialog                      | Modal dialog                                 | Semi-modal dialog                             | Toast dialog                              |
|---------------------------------------------|----------------------------------------------|-----------------------------------------------|-------------------------------------------|
| ![image](screenshots/device/slide_en.gif)   | ![image](screenshots/device/modality_en.gif) | ![image](screenshots/device/semimodal_en.gif) | ![image](screenshots/device/toast_en.gif) |
| Privacy agreement dialog                    | Full-screen dialog                           | Custom calendar selector dialog               | Semi-modal + full-screen dialog           |
| ![image](screenshots/device/privacy_en.gif) | ![image](screenshots/device/screen_en.gif)   | ![image](screenshots/device/customize_en.gif) | ![image](screenshots/device/add_en.gif)   |

### How to Use

After the loading is complete, eight customized dialog pop-up types are displayed on the home page. Tap the corresponding button to go to the corresponding dialog pop-up page.
1. Swipe to select a dialog pop-up: Tap the two buttons at the bottom of the page to display the time selector dialog pop-up in 12-hour format and text selector dialog pop-up.
2. Modal dialog pop-up: Tap the bottom of the page to select a passenger. A modal dialog pop-up is displayed. Tap the **OK** button at the bottom of the modal dialog pop-up to close it.
3. Semi-modal dialog pop-up: Tap the button for selecting the taste and tableware on the page. A semi-modal dialog pop-up is displayed. Tap the mask layer to close the dialog pop-up.
4. Toast dialog pop-up: Tap the button at the bottom. A toast dialog pop-up is displayed, indicating that the login is successful. The dialog pop-up disappears after 3 seconds.
5. Privacy agreement dialog pop-up: Tap the button at the bottom to display the privacy agreement dialog pop-up. The content in the dialog pop-up can be scrolled. You can tap the privacy agreement. After you tap the button, a new page is displayed. Tap the back button on the new page to return to the privacy agreement dialog pop-up. Tap **Agree** or **Disagree** to close the dialog pop-up.
6. Full-screen dialog pop-up: Touch the button at the bottom to display the full-screen dialog pop-up. Touch the down arrow in the upper left corner to close the dialog pop-up. Swipe down to damp the dialog pop-up. When the swiping distance is greater than 300, the dialog pop-up is closed. Otherwise, the dialog pop-up goes back to the original position.
7. Custom calendar selector dialog pop-up: Tap a date on the page. A date selector dialog pop-up is displayed. Only dates after the current date can be selected. After the selection is complete, the dialog pop-up is closed and the date is changed to the selected date.
8. Semi-modal + full-screen dialog pop-up: Tap **open sheet1** to display the first semi-modal dialog pop-up. Tap the text box. Tap **close sheet1** to close the first dialog pop-up. Taping the **open sheets2** button opens the second semi-modal dialog pop-up that has two buttons. Taping the **close sheets2** button closes only the second semi-modal dialog pop-up. Taping the **close sheets1 sheet2** button closes the first and second semi-modal dialog pop-ups.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common/constant
│  │  └──CommonConstants.ets                   // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets                      // Entry ability
│  ├──pages                 
│  │  ├──Index.ets                             // Homepage
│  │  ├──BindContentCoverDemo.ets              // Modal dialog pop-up
│  │  ├──BindSheet.ets                         // Semi-modal dialog pop-up
│  │  ├──CustomCalendar.ets                    // Custom calendar selector dialog pop-up
│  │  ├──FullScreen.ets                        // Full-screen dialog pop-up
│  │  ├──Privacy.ets                           // Privacy agreement dialog pop-up
│  │  ├──ScrollOption.ets                      // Scroll-to-select dialog pop-up
│  │  └──TwoLevelPageSheet.ets                 // Semi-modal + full-screen dialog pop-up
│  ├──view                  
│  │  └──CustomCalendarPickerDialog.ets        // Custom calendar dialog pop-up
│  └──viewmodel 
│     ├──BindContentModel.ets                  // Modal dialog pop-up API and data
│     ├──DataManager.ets                       // Data storage class
│     ├──DateModel.ets                         // Date class
│     ├──GetDate.ets                           // Function for obtaining dates
│     └──MonthDataSource.ets                   // Month data class
└──entry/src/main/resources                    // App resource directory
```

### How to Implement
1. Scroll-to-select dialog pop-up: implemented by the TimePickerDialog.show (time selector dialog pop-up) and TextPickerDialog.show (text selector dialog pop-up) components.
2. Modal dialog pop-up: Use the **bindContentCover** attribute to bind a full-screen modal page to the component. After a user taps the page, the modal page is displayed. The content of the modal is customizable. The transition type can be set to none, slide-up and slide-down animation, and opacity gradient animation.
3. Semi-modal dialog pop-up: Use the **bindSheet** attribute to bind a semi-modal page to the component. After the page is taped, the semi-modal page is displayed.
4. Toast dialog pop-up: Use the custom dialog pop-up (CustomDialog) to simulate the toast dialog pop-up. You can set various attribute values of the CustomDialogController class to implement the effect.
5. Privacy agreement dialog pop-up: Use the stack component to simulate the dialog pop-up. The visibility attribute is used to control the display and hiding of the dialog pop-up. In this way, a new page is displayed when a user taps the button for returning to the privacy agreement dialog pop-up, and the dialog pop-up is not closed when the user taps the button for returning to the privacy agreement dialog pop-up.
6. Full-screen dialog pop-up: Use the **translate** attribute to hide the full-screen page outside the visible area. When a user taps the full-screen dialog pop-up button, the full-screen dialog pop-up is displayed through animation. In the gesture attribute, use the PanGesture drag gesture event to close the dialog pop-up when the sliding down is greater than 300. Otherwise, the dialog pop-up goes back to the original position.
7. Custom calendar selector dialog pop-up: Use **CustomDialog** to implement the custom calendar selector. Use the **LazyForEach** component to cyclically traverse months. In this example, two months (the current month and the next month) are displayed. Use **Forach** to traverse each day of each month.
8. Semi-modal + full-screen dialog pop-up: Use the **bindSheet** attribute to bind the first semi-modal page to the **open sheet1** button component and bind the second semi-modal page to the **open sheet2** button component on the first semi-modal page. In this way, two-level semi-modal dialog pop-ups are implemented.

### Required Permissions
N/A

### Dependencies
N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
