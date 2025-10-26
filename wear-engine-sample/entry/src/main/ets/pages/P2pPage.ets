/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { wearEngine } from '@kit.WearEngine';
import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height('45vp')
  .fontSize('13fp')
  .backgroundColor($r('app.color.background'))
  .width(STRING_PERCENT.MAX_PERCENT)
  .padding({ left: 10 })
  .margin({ top: "12vp" })
}

@Entry
@Component
struct P2pPage {
  // Obtain the DeviceClient instance, used to obtain connected devices
  @State deviceClient: wearEngine.DeviceClient = wearEngine.getDeviceClient(getContext(this));
  // Get P2pClient instance
  @State p2pClient: wearEngine.P2pClient = wearEngine.getP2pClient(getContext(this));
  // Array to store the list of connected devices
  @State deviceList: wearEngine.Device[] = [];
  // Save connected device selected on page
  @State changeItem: wearEngine.Device = {
    randomId: '',
    name: 'default',
    softwareVersion: '',
    model: '',
    isSmartWatch: false,
    isWearEngineCapabilitySupported: (): Promise<boolean> => {
      return Promise.resolve(false);
    },
    isDeviceCapabilitySupported: (): Promise<boolean> => {
      return Promise.resolve(false);
    },
    getSerialNumber: (): Promise<string> => {
      throw new Error('Function not implemented.');
    }
  };
  // Save the message content entered on the page
  @State messageContent: string = '';
  // Call result information displayed on the page
  @State printContent: string = '';
  // Device side application package name
  @State watchBundleName: string = '';
  // Device side application information
  private appInfo: wearEngine.AppInfo = {
    bundleName: this.watchBundleName,
    fingerprint: 'a'
  }
  private appParam: wearEngine.P2pAppParam = {
    remoteApp: this.appInfo
    // transformLocalAppInfo defaults to false when not entered
  }
  // Callback function for receiving files
  private fileCallback = (file: wearEngine.P2pFile) => {
    this.printContent += `receive file: ${file.file.name}` + '\n';
  }
  // Callback function for receiving messages
  private msgCallback = (msg: wearEngine.P2pMessage) => {
    let decoder: util.TextDecoder = util.TextDecoder.create();
    let str: string = decoder.decodeWithStream(msg.content);
    this.printContent += `receive message: ${str}` + '\n';
  }

  build() {
    Column() {
      Text($r("app.string.p2p_title"))
        .fontSize(STRING_MARGIN.TITLE_FONT_SIZE)
        .margin({
          top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
        })
      Text($r('app.string.select_device_tip'))
        .fontSize(STRING_MARGIN.TIP_FONT_SIZE)
        .margin({
          left: STRING_MARGIN.TITLE_TIP_LEFT_SIZE,
          top: STRING_MARGIN.TITLE_TIP_TOP_SIZE
        })
        .alignSelf(ItemAlign.Start)

      // Show all connected devices
      Column(){
        Scroll() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.Start,
            wrap: FlexWrap.Wrap
          }) {
            ForEach(this.deviceList, (item: wearEngine.Device, index: number | undefined) => {
              Row() {
                Radio({ value: item.name, group: "BOUND_DEVICES" })
                  .height(20)
                  .width(20)
                  .onChange(() => {
                    this.changeItem = item;
                    this.printContent += "Selected device information:" + '\n' +
                      "device name: " + '\t' + item.name + '\n' +
                      "device category: " + '\t' + wearEngine.DeviceCategory[item.category as number] + '\n' +
                      "software version: " + '\t' + item.softwareVersion + '\n' +
                      "device model: " + '\t' + item.model + '\n' +
                      "is smart watch: " + '\t' + item.isSmartWatch + '\n';
                  })
                Text(item.name).fontSize(14).opacity(Number.parseFloat('0.6'))
              }
              .margin({ left: 10, top: 8 })
            }, (item: number) => JSON.stringify(item))
          }
        }
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .width(STRING_PERCENT.MAX_PERCENT)
      .height(STRING_PERCENT.TEN_PERCENT)

      // Call the interface to obtain the list of connected devices
      Button($r('app.string.btn_get_Connected_devices'), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r("app.color.base_button_color"))
        .onClick(() => {
          this.deviceClient.getConnectedDevices().then(devices => {
            this.deviceList = devices;
            this.printContent += `Succeeded in getting devices, devices number is ${devices.length}` + '\n';
            console.info(`Succeeded in getting devices, devices number is ${devices.length}`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to get devices. Code is ${error.code}, message is ${error.message}` + '\n';
            console.error(`Failed to get devices. Code is ${error.code}, message is ${error.message}`);
          })
        })

      Row() {
        // Call the interface to detect whether the device-side App is installed.
        Button($r('app.string.btn_is_remote_app_installed'), { type: ButtonType.Capsule })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n';
              return;
            }
            this.p2pClient.isRemoteAppInstalled(this.changeItem.randomId, this.watchBundleName).then(isInstall => {
              this.printContent += `remote app ${this.watchBundleName} is ${isInstall ? '' : 'not'} installed` + '\n';
              console.info(`Succeeded in checking remote app install, result is ${isInstall}.`);
            }).catch((error: BusinessError) => {
              this.printContent += `Failed to check remote app install. Code is ${error.code}, message is ${error.message}.` + '\n';
              console.error(`Failed to check remote app install. Code is ${error.code}, message is ${error.message}.`);
            })
          })
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))

        // Call the interface to obtain the device side App version number
        Button($r("app.string.btn_get_remote_app_version"), { type: ButtonType.Capsule })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n';
              return;
            }
            this.p2pClient.getRemoteAppVersion(this.changeItem.randomId, this.watchBundleName).then((version) => {
              this.printContent += `remote app ${this.watchBundleName} version is ${version}` + '\n';
              console.info(`Succeeded in getting remote app version, version is ${version}.`);
            }).catch((error: BusinessError) => {
              this.printContent += `Failed to check get remote app version. Code is ${error.code}, message is ${error.message}.` + '\n';
              console.error(`Failed to check get remote app version. Code is ${error.code}, message is ${error.message}.`);
            })
          })
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))

        // Call the interface to launch the device-side App
        Button($r('app.string.btn_start_remote_app'), { type: ButtonType.Capsule })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n'
              return;
            }
            this.p2pClient.startRemoteApp(this.changeItem.randomId, this.watchBundleName).then((p2pResult) => {
              this.printContent += `Succeeded in starting remote app ${this.watchBundleName}, result is ${p2pResult.code}.` + '\n';
              console.info(`Succeeded in starting remote app, result is ${p2pResult.code}.`);
            }).catch((error: BusinessError) => {
              this.printContent += `Failed to start remote app. Code is ${error.code}, message is ${error.message}.` + '\n';
              console.error(`Failed to start remote app. Code is ${error.code}, message is ${error.message}.`);
            })
          })
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.BUTTONS_TOP_SIZE
      })

      // Enter message content through the page
      TextInput({ placeholder: $r('app.string.message_content') })
        .inputStyle()
        .onChange((value: string) => {
          this.messageContent = value;
        })
        .width(STRING_PERCENT.NINETY_PERCENT);


      // Call the interface to send messages to the device-side App
      Button($r("app.string.btn_send_message"), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r("app.color.base_button_color"))
        .margin({
          top: STRING_MARGIN.BUTTONS_TOP_SIZE
        })
        .onClick(() => {
          if (this.changeItem.name === 'default') {
            this.printContent += 'Please select target device.' + '\n';
            return;
          }
          let textEncoder = new util.TextEncoder;
          let message: wearEngine.P2pMessage = {
            content: textEncoder.encodeInto(this.messageContent)
          }
          if (this.appInfo.bundleName === '' || this.appInfo.fingerprint === '') {
            this.printContent += 'Please set app info in code.' + '\n';
            return;
          }
          this.p2pClient.sendMessage(this.changeItem.randomId, this.appParam, message).then((p2pResult) => {
            this.printContent += `Succeeded in sending message, result is ${p2pResult.code}.` + '\n';
            console.info(`Succeeded in sending message, result is ${p2pResult.code}.`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to send message. Code is ${error.code}, message is ${error.message}.` + '\n';
            console.error(`Failed to send message. Code is ${error.code}, message is ${error.message}.`);
          })
        })
        .backgroundColor($r("app.color.base_button_color"))

      Row() {
        Text($r("app.string.register_receiver"))
          .margin({ left: 10, right: 20 })

        Text("File")
        // Call the interface to subscribe to receive files sent from the device-side App
        Toggle({ type: ToggleType.Switch })
          .onChange((register: boolean) => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n';
              return;
            }
            if (this.appInfo.bundleName === '' || this.appInfo.fingerprint === '') {
              this.printContent += 'Please set app info in code.' + '\n';
              return;
            }
            if (register) {
              this.p2pClient.registerFileReceiver(this.changeItem.randomId, this.appParam, this.fileCallback)
                .then(() => {
                  this.printContent += `Succeeded in registering file receiver.` + '\n';
                  console.info(`Succeeded in registering file receiver.`);
                })
                .catch((error: BusinessError) => {
                  this.printContent += `Failed to register file receiver. Code is ${error.code}, message is ${error.message}.` + '\n';
                  console.error(`Failed to register file receiver. Code is ${error.code}, message is ${error.message}.`);
                })
            } else {
              this.p2pClient.unregisterFileReceiver(this.changeItem.randomId, this.appParam, this.fileCallback)
                .then(() => {
                  this.printContent += `Succeeded in unregistering file receiver.` + '\n';
                  console.info(`Succeeded in unregistering file receiver.`);
                })
                .catch((error: BusinessError) => {
                  this.printContent += `Failed to unregister file receiver. Code is ${error.code}, message is ${error.message}.` + '\n';
                  console.error(`Failed to unregister file receiver. Code is ${error.code}, message is ${error.message}.`);
                })
            }
          })
          .margin({ right: 10 })

        Text("Message")
        // Call the interface to subscribe to receive messages sent from the device-side App
        Toggle({ type: ToggleType.Switch })
          .onChange((register: boolean) => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n';
              return;
            }
            if (this.appInfo.bundleName === '' || this.appInfo.fingerprint === '') {
              this.printContent += 'Please set app info in code.' + '\n';
              return;
            }
            if (register) {
              this.p2pClient.registerMessageReceiver(this.changeItem.randomId, this.appParam, this.msgCallback)
                .then(() => {
                  this.printContent += `Succeeded in registering message receiver.` + '\n';;
                  console.info(`Succeeded in registering message receiver.`);
                })
                .catch((error: BusinessError) => {
                  this.printContent += `Failed to register message receiver. Code is ${error.code}, message is ${error.message}.` + '\n';
                  console.error(`Failed to register message receiver. Code is ${error.code}, message is ${error.message}.`);
                })
            } else {
              this.p2pClient.unregisterMessageReceiver(this.changeItem.randomId, this.appParam, this.msgCallback)
                .then(() => {
                  this.printContent += `Succeeded in unregistering message receiver.` + '\n';
                  console.info(`Succeeded in unregistering message receiver.`);
                })
                .catch((error: BusinessError) => {
                  this.printContent += `Failed to unregister message receiver. Code is ${error.code}, message is ${error.message}.` + '\n';
                  console.error(`Failed to unregister message receiver. Code is ${error.code}, message is ${error.message}.`);
                })
            }
          })
      }
      .margin({
        top: STRING_MARGIN.BUTTONS_TOP_SIZE
      })
      .width(STRING_PERCENT.NINETY_PERCENT)

      Scroll() {
        Text(this.printContent)
          .fontSize(STRING_MARGIN.TEXT_FONT_SIZE)
          .textAlign(TextAlign.Start)
          .width(STRING_PERCENT.MAX_PERCENT)
      }
      .margin({
        left: STRING_MARGIN.TIP_FONT_SIZE,
        right: STRING_MARGIN.TIP_FONT_SIZE,
        top: STRING_MARGIN.TIP_FONT_SIZE
      })
      .width(STRING_PERCENT.MAX_PERCENT)
      .height(STRING_PERCENT.FORTY_PERCENT)
      .align(Alignment.TopStart)

      Button($r('app.string.btn_clear_print'), { type: ButtonType.Capsule })
        .backgroundColor($r("app.color.clear_button_color"))
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .margin({
          top: STRING_MARGIN.MARGIN_TOP_SIZE
        })
        .onClick(() => {
          this.printContent = '';
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width(STRING_PERCENT.MAX_PERCENT)
  }
}