/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { wearEngine } from '@kit.WearEngine';
import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { BusinessError } from '@kit.BasicServicesKit';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height('30vp')
  .fontSize('12fp')
  .backgroundColor($r('app.color.background'))
  .width(STRING_PERCENT.MAX_PERCENT)
  .padding({ left: 10 })
  .style(TextInputStyle.Default)
}

@Entry
@Component
struct DevicePage {
  // Get DeviceClient instance
  @State deviceClient: wearEngine.DeviceClient = wearEngine.getDeviceClient(getContext(this));
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
  }
  // Call result information displayed on the page
  @State printContent: string = '';
  // Save the WearEngine capability ID entered on the page
  @State wearengineCapabilityId: number = -1;
  // Save the Device capability ID entered on the page
  @State deviceCapabilityId: number = -1;
  build() {
    Column() {
      Text($r("app.string.device_title"))
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

      // Query the Device capability support status of the specified device
      Row() {
        TextInput({ placeholder: 'device capability id' })
          .layoutWeight(3)
          .inputStyle()
          .onChange((value: string) => {
            this.deviceCapabilityId = Number(value);
          })
          .height(STRING_MARGIN.INPUT_FONT_SIZE)

        Button($r("app.string.btn_is_capability_support"), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(2)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n'
              return;
            }
            this.changeItem.isDeviceCapabilitySupported(this.deviceCapabilityId).then(value => {
              this.printContent += value + '\n';
              console.info(`Succeeded in checking device capability: ${this.deviceCapabilityId}, result is ${value}`);
            }).catch((error: BusinessError) => {
              console.error(`Failed to check device capability. Code is ${error.code}, message is ${error.message}`);
            })
          })
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE
      })

      // Query the WearEngine capability support status of the specified device
      Row() {
        TextInput({ placeholder: 'wearengine capability id' })
          .layoutWeight(3)
          .inputStyle()
          .onChange((value: string) => {
            this.wearengineCapabilityId = Number(value);
          })
          .height(STRING_MARGIN.INPUT_FONT_SIZE)

        Button($r("app.string.btn_is_capability_support"), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(2)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n'
              return;
            }
            this.changeItem.isWearEngineCapabilitySupported(this.wearengineCapabilityId).then(value => {
              this.printContent += value + '\n';
              console.info(`Succeeded in checking wear engine capability: ${this.wearengineCapabilityId}, result is ${value}`);
            }).catch((error: BusinessError) => {
              console.error(`Failed to check wear engine capability. Code is ${error.code}, message is ${error.message}`);
            })
          })
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE
      })

      Scroll() {
        Text(this.printContent)
          .fontSize(STRING_MARGIN.TEXT_FONT_SIZE)
          .textAlign(TextAlign.Start)
          .width(STRING_PERCENT.NINETY_PERCENT)
      }
      .margin({
        left: STRING_MARGIN.PRINT_SCROLL_SIZE,
        right: STRING_MARGIN.PRINT_SCROLL_SIZE,
        top: STRING_MARGIN.PRINT_SCROLL_SIZE
      })
      .width(STRING_PERCENT.MAX_PERCENT)
      .height(STRING_PERCENT.FIFTY_PERCENT)
      .align(Alignment.TopStart)

      Button($r("app.string.btn_clear_print"), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .backgroundColor($r("app.color.clear_button_color"))
        .onClick(() => {
          this.printContent = '';
        })
        .margin({
          top: STRING_MARGIN.MARGIN_TOP_SIZE
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width(STRING_PERCENT.MAX_PERCENT)
  }
}