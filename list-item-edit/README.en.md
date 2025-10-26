# List Editing

### Overview

This sample uses the List component to implement the list editing effects in scenarios such as to-do list management, file management, and notepad.

### Preview

![](./screenshots/device/listitem_edit.en.gif)

##### How to Use

- Tap the add button and select the to-do items to be added.
- Tap the check box of the to-do item. The item is automatically moved to **Completed**.
- Swipe left on a to-do item and touch the delete button to delete it.

### Project Directory

```

├──entry/src/main/ets/
│  ├──common
│  │  └──Constants.ets               // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets           // Entry point class
│  ├──model
│  │  └──ToDo.ets                    // To-do list data
│  ├──pages
│  │  └──Index.ets                   // Home page
│  └──view
│     └──TodoListItem.ets            // To-do list item
└──entry/src/main/resources          // Static resources of the app
```

### How to Implement

1. Bind the List component to the @State-decorated array variable **toDoData**.

2. Set the **swipeAction** attribute for the ListItem component so that a single list item can be swiped leftward or rightward and the customized UIBuilder is displayed.

3. Add or delete a list item, update the array variable **toDoData**, and update the UI of the List component.

### Required Permissions

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
