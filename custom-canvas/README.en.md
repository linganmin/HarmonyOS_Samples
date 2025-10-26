# Custom Canvas

### Overview

This sample demonstrates a custom canvas created with the **Canvas** component, featuring capabilities for selecting pen thickness, color, and opacity, as well as for drawing, zooming, and clearing.

### Preview

![](./screenshots/device/canvas_en.gif)

### How to Use

1. On the home page, there are five icons at the bottom. The pen is selected by default, allowing you to draw in the empty space at the top. The pen starts with a thickness of 3 and is set to black color.
2. Once you've made a drawing, the undo icon is highlighted. You can touch it to undo your drawing. Following this, the redo icon is highlighted, and you can touch it to reverse the undo action.
3. Touch the eraser icon. The drawing is erased, and the pen icon is no longer highlighted.
4. Touch the clear icon. All the drawings on the canvas are cleared, and the clear icon is highlighted.
5. When you touch the pen icon, a semi-modal menu is displayed. In the menu, you can choose the pen type, color, opacity, and thickness.
6. In this sample, only the ballpoint pen (which is the default) and the marker are displayed. If you select the marker, close the menu, and draw again, the marker will be used for your drawing.
7. Touch the pen icon again to display the menu, where you ca change the color, opacity, and thickness. Note that opacity adjustment is available only for the marker.
8. To zoom in or out, use a pinch gesture with two fingers on the canvas. While zooming, the pen icon is not highlighted. Once the canvas is adjusted to your desired zoom level, you can touch the pen icon to continue drawing.

### Project Directory

```
├──entry/src/main/ets/
│  ├──common
│  │  └──CommonConstants.ets         // Common constants
│  ├──entryability
│  │  └──EntryAbility.ets            // Entry ability
│  ├──pages                  
│  │  └──Index.ets                   // Home page
│  ├──view   
│  │  └──myPaintSheet.ets            // Semi-modal page
│  └──viewmodel
│     ├──DrawInvoker.ets             // Drawing method
│     ├──IBrush.ets                  // Brush APIs
│     ├──IDraw.ets                   // Drawing class
│     └──Paint.ets                   // Drawing property class
└──entry/src/main/resources          // Static resources
```

### How to Implement

1. To implement drawing, bind the **onTouch** event to the **Canvas** component to obtain the X and Y coordinates of a touch point relative to the canvas, and pass in the coordinates to the **moveTo** and **lineTo** methods of the **Path2D** object.
2. To enable erasing, set the **strokeStyle** attribute of **CanvasRenderingContext2D** to white.
3. Use the **add** method to save each drawing path in the **drawPathList** array. The undo operation removes the most recent path from **drawPathList** and places it into the **redoList** array, whereas the redo operation clears the last item in **redoList** and puts it back to **drawPathList**.
4. To implement the clear capability, clear the **drawPathList** and **redoList** arrays and redraw the canvas.
5. Set the default value of the **globalAlpha** attribute to 1 for the ballpoint pen, and make it unchangeable. Set the default value of the **globalAlpha** attribute to 0.5 for the marker, and allow adjustments using the **Slider** component.
6. To modify the color and thickness, use the **strokeStyle** and **lineWidth** attributes of **CanvasRenderingContext2D**.

### Required Permissions

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio HarmonyOS 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
