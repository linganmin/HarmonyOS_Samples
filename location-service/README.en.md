# Location Service

### Overview

This sample shows how to use the APIs provided by the **geoLocationManager** class of **@kit.LocationKit** to implement the following:
- Obtain the cached location, current location, and continuous location.
- Set the longitude and latitude as request parameters and use **map.Marker** to mark the location on the map.
- Perform reverse geocoding to obtain the address information and display the information on the app page.

### Preview
| Home                                             |
|--------------------------------------------------|
| ![](screenshots/devices/location_service.en.png) |

How to Use

Before you get started, configure app information by referring to the section "Configuring App Information in AppGallery Connect" in the *Map Kit Development Guide*, and [enable the MAP Kit](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/map-config-agc). Then, perform the following:
1. Launch the app, and tap the **Obtain Cached Location** button on the homepage. The cached location is displayed and marked on the map.
2. Tap the **Obtain Current Location** button on the homepage. The current location is displayed and marked on the map.
3. Tap the **Obtain Continuous Location** button on the homepage. The most recently updated location is displayed and marked on the map.

### Project Directory
```
├──entry/src/main/ets/                    // Core code
│  ├──common
│  │  └──CommonConstants.ets              // common class
│  ├──entryability
│  │  └──EntryAbility.ets                 // Ability class
│  ├──model
│  │  └──LocationInter.ets                // Location latitude and longitude information
│  └──pages
│     └──Index.ets                        // Homepage
└──entry/src/main/resources               // Static resources of the app
```

### How to Implement
+ When the user taps the **Obtain Cached Location** button, call the **geoLocationManager.getLastLocation** API to obtain the cached location, call the Marker API to mark the location on the map, and call the **geoLocationManager.getAddressesFromLocation** API to convert coordinates into geographical location information.
+ When the user taps the **Obtain Current Location** button, call the **geoLocationManager.getCurrentLocation** API to obtain the current location, call the Marker API to mark the location on the map, and call the **geoLocationManager.getAddressesFromLocation** API to convert coordinates into geographical location information.
+ When the user taps the **Obtain Continuous Location** button, call the **geoLocationManager.on** API to enable the continuous location function, call the Marker API to mark the most recently updated location on the map, and call the **geoLocationManager.getAddressesFromLocation** API to convert coordinates into geographical location information.
     
### Required Permissions
ohos.permission.LOCATION: Allows an application to obtain the device location.

ohos.permission.APPROXIMATELY_LOCATION: Allows an application to obtain the approximate location information of a device.

ohos.permission.LOCATION_IN_BACKGROUND: Allows an application running in the background to obtain the device location.

ohos.permission.KEEP_BACKGROUND_RUNNING: Allows a Service ability to keep running in the background.

ohos.permission.GET_NETWORK_INFO: Allows an application to obtain network information.

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
