# Implementing Device Communication Using BLE

## Overview
Bluetooth Low Energy (BLE) is a wireless, low-power Bluetooth technology. Compared with classic Bluetooth, BLE allows for lower power consumption and is applicable to devices with long standby time, such as smart watches, healthcare devices, smart home devices. 
This sample describes the capabilities of connecting and communicating devices through Bluetooth. For example, the BLE server can transmit data after advertising is enabled, and the BLE client can search for connectable devices and receive advertising data after connection.

## Preview
![](/screenshots/device/mate60pro_en.png)

## Project Directory

``` 
├──entry/src/main/ets                                   // Full-screen login code 
│  ├──entryability 
│  │  └──EntryAbility.ets                               // Entry ability 
│  ├──model 
│  │  └──BluetoothDevice.ets                            // Bluetooth device model definition 
│  ├──pages                               
│  │  ├──BluetoothClient.ets                            // Bluetooth client 
│  │  ├──BluetoothServer.ets                            // Bluetooth server 
│  │  ├──HeartRate.ets                                  // Heart rate line graph 
│  │  └──Index.ets                                      // Home page 
│  ├──uicomponents                               
│  │  ├──EmptyPage.ets                                  // Empty page 
│  │  ├──HeartRateGraph.ets                             // UI component for the line graph 
│  │  └──NavigationBar.ets                              // Navigation bar style 
│  ├──utils                               
│  │  ├──ArrayBufferUtils.ets                           // Conversion utility 
│  │  ├──DateUtils.ets                                  // Date utility 
│  │  └──Logger.ets                                     // Log printing 
│  │  └──MathUtils.ets                                  // Number utility 
│  └──viewmodel 
│     ├──AdvertiseBluetoothViewModel.ets                // Definition page for Bluetooth device APIs 
│     └──BluetoothClientModel.ets                       // Definition page for Bluetooth client APIs 
└──entry/src/main/resources                             // Application resources

``` 

## How to Use
Two devices are required. One functions as the BLE server, and the other functions as the BLE client.
* BLE server

  Touch the heart rate advertising button to transmit data.
* BLE client

  Search for connectable Bluetooth devices, receive data after the connection is successful, and display the heart rate in a line graph.


## How to Implement
* BLE server
  
  Call startAdvertising to start advertising.
  
  Call stopAdvertising to stop advertising when the device is disconnected.
* BLE client

  Call startBLEScan to search for Bluetooth-enabled devices.

  Call connect to connect to the Bluetooth.

  Call on(type: 'BLECharacteristicChange') to subscribe to value changes of the BLE characteristics.
## Permissions

* ohos.permission.ACCESS_BLUETOOTH: allows an application to use Bluetooth capabilities, such as pairing and connecting to a peripheral device.

## Constraints

* The sample is only supported on Huawei phones with standard systems.

* The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

* The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

* The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
