# Collection of Verification Code Scenarios

### Overview

This sample describes five verification code scenarios: displaying the cursor in the text box, adding a horizontal bar at the bottom, changing the background color, selecting a verification code, and sliding a verification code.

### Preview
| Cursor in text box                        | Horizontal bar adding                      | Background color change                        | Verification code selection                |
|-------------------------------------------|--------------------------------------------|------------------------------------------------|--------------------------------------------|
| ![image](screenshots/device/text_EN.gif)  | ![image](screenshots/device/bottom_EN.gif) | ![image](screenshots/device/background_EN.gif) | ![image](screenshots/device/choose_EN.gif) |
| Verification code sliding                 |
| ![image](screenshots/device/slide_EN.gif) |

### How to Use

After the loading is complete, five verification code instances are displayed on the home page. Tap the corresponding button to access the corresponding verification code page.
1. Cursor display in a text box: If you input a number, the cursor moves to the next text box and the lower border changes the color.
2. Add a horizontal bar at the bottom: Input a 6-digit number in the text box.
3. Background color change: The background color changes after you input a number.
4. Select a verification code: Tap the text on the image in the sequence of the prompt text, and then tap **Submit**.
5. Slide a verification code: Tap the slider to slide rightward until the image is stitched completely.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  ├──Constants.ets                         // Common constant class
│  │  └──GlobalBuilderContext.ets              // Global page information
│  ├──entryability
│  │  └──EntryAbility.ets                      // Entry ability
│  ├──pages                 
│  │  ├──BackgroundColorChange.ets             // Background color change
│  │  ├──BottomWithBar.ets                     // Add a horizontal bar at the bottom.
│  │  ├──Index.ets                             // Home page
│  │  ├──SelectVerificationCode.ets            // Select verification codes
│  │  ├──SliderVerificationCode.ets            // Slider verification codes
│  │  └──TextBoxShowCursor.ets                 // Display the cursor in the text box.
│  └──viewmodel 
│     └──NavDestinationItem.ets                // Route type
└──entry/src/main/resources                    // App resource directory
```

### How to Implement
1. Display the cursor in the text box: Currently, **TextInput** cannot listen to the delete key. The **Text** component is used to subscribe to the insertion and deletion events of the input method to obtain the input content. When the visible area of the component changes, the cursor is bound or unbound as required. The cursor is displayed or hidden through attribute animations.
2. Add a horizontal bar at the bottom: **TextInput** is used to limit the maximum number of digits to input to **6**. Use **Divider** to add a horizontal bar below.
3. Background color change: The principle is the same as that for displaying the cursor in the text box. The background color is changed by checking whether a number is input. If a number is input, the background color changes.
4. Select a verification code: The **Stack** component is used to cover the image with a number. When a number is taped, the horizontal and vertical coordinates of the current tap position relative to the page and the taped text content are obtained, and the text is added to the array. The number that represents the tap sequence is moved through coordinates, tap **Submit** to check whether the text content and sequence in the array are correct.
5. Slide a verification code: The **onChange** method of the **Slider** component is used to obtain the interaction distance and move the slider on the image to stitch the image completely.

### Required Permissions
N/A

### Constraints

1. The sample app is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
