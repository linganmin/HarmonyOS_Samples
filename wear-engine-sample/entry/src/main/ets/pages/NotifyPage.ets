/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { wearEngine } from '@kit.WearEngine';
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
struct NotifyPage {
  @State deviceClient: wearEngine.DeviceClient = wearEngine.getDeviceClient(getContext(this));
  @State notifyClient: wearEngine.NotifyClient = wearEngine.getNotifyClient(getContext(this));
  @State notificationType: wearEngine.NotificationType = wearEngine.NotificationType.NOTIFICATION_WITHOUT_BUTTONS;
  @State typeSelect: wearEngine.NotificationType = wearEngine.NotificationType.NOTIFICATION_WITHOUT_BUTTONS;
  @State bundleName: string = '';
  @State title: string = '';
  @State text: string = '';
  @State button1Content: string = '';
  @State button2Content: string = '';
  @State button3Content: string = '';
  @State deviceList: wearEngine.Device[] = [];
  @State typeStrList: string[] = ['NO_BUTTON', 'ONE_BUTTON', 'TWO_BUTTONS', 'THREE_BUTTONS'];
  @State printContent: string = '';
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

  build() {
    Column() {
      Text($r("app.string.notify_title"))
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
        Text("Type:")
        Scroll() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.Start,
            wrap: FlexWrap.Wrap
          }) {
            ForEach(this.typeStrList, (item: string, index: number | undefined) => {
              Row() {
                Radio({ value: item, group: "typeItems" })
                  .height(20)
                  .width(20)
                  .onChange(() => {
                    this.notificationType = Number(index) + 50;
                  })
                  .checked(item === 'NO_BUTTON')
                Text(item).fontSize(14).opacity(Number.parseFloat('0.6'))
              }
              .margin({ left: 10, top: 2 })
            }, (item: number) => JSON.stringify(item))
          }
        }
      }
      .width(STRING_PERCENT.NINETY_PERCENT)

      Row() {
        Text("BundleName:")
          .layoutWeight(1)
        TextInput({ placeholder: "BundleName" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.bundleName = value
          })
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Row() {
        Text("Title:")
          .layoutWeight(1)
        TextInput({ placeholder: "Title" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.title = value
          })
          .width(STRING_PERCENT.NINETY_PERCENT)
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Row() {
        Text("text:")
          .layoutWeight(1)
        TextInput({ placeholder: "text" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.text = value
          })
          .width(STRING_PERCENT.NINETY_PERCENT)
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Row() {
        Text("Button1:")
          .layoutWeight(1)
        TextInput({ placeholder: "ButtonContent" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.button1Content = value
          })
          .width(STRING_PERCENT.NINETY_PERCENT)
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Row() {
        Text("Button2:")
          .layoutWeight(1)
        TextInput({ placeholder: "ButtonContent" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.button2Content = value
          })
          .width(STRING_PERCENT.NINETY_PERCENT)
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Row() {
        Text("Button3:")
          .layoutWeight(1)
        TextInput({ placeholder: "ButtonContent" })
          .layoutWeight(2)
          .inputStyle()
          .onChange((value: string) => {
            this.button3Content = value
          })
          .width(STRING_PERCENT.NINETY_PERCENT)
          .height(STRING_MARGIN.INPUT_FONT_SIZE)
      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.NOTIFY_INPUT_TOP
      })

      Button("sendNotification", { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .margin({
          top: STRING_MARGIN.BUTTONS_TOP_SIZE
        })
        .backgroundColor($r("app.color.base_button_color"))
        .margin({
          top: STRING_MARGIN.BUTTONS_TOP_SIZE
        })
        .onClick(() => {
          if (this.changeItem.name === 'default') {
            this.printContent += 'Please select target device.' + '\n';
            return;
          }
          let inputButtons: wearEngine.NotificationButton[] = [];
          switch (this.notificationType) {
            case wearEngine.NotificationType.NOTIFICATION_WITH_THREE_BUTTONS:
              let button3: wearEngine.NotificationButton = {
                buttonId: wearEngine.ButtonId.THIRD_BUTTON,
                content: this.button3Content
              }
              inputButtons.push(button3);
            case wearEngine.NotificationType.NOTIFICATION_WITH_TWO_BUTTONS:
              let button2: wearEngine.NotificationButton = {
                buttonId: wearEngine.ButtonId.SECOND_BUTTON,
                content: this.button2Content
              }
              inputButtons.push(button2);
            case wearEngine.NotificationType.NOTIFICATION_WITH_ONE_BUTTON:
              let button1: wearEngine.NotificationButton = {
                buttonId: wearEngine.ButtonId.FIRST_BUTTON,
                content: this.button1Content
              }
              inputButtons.push(button1);
            case wearEngine.NotificationType.NOTIFICATION_WITHOUT_BUTTONS:
              break;
            default:
              break;
          }
          let notification: wearEngine.Notification = {
            type: this.notificationType,
            bundleName: this.bundleName,
            title: this.title,
            text: this.text,
            buttons: inputButtons
          }
          let notificationOptions: wearEngine.NotificationOptions = {
            notification: notification,
            onAction: (feedback: wearEngine.NotificationFeedback): void => {
              if (feedback.errorCode) {
                this.printContent += `get notification feedback errorcode number is ${feedback.action}, which title is ${notification.title}` + '\n';
                return;
              }
              this.printContent += `get notification feedback is ${feedback.action}, which title is ${notification.title}` + '\n';
            }
          }
          this.notifyClient.notify(this.changeItem.randomId, notificationOptions).then(() => {
            this.printContent += `Succeeded in sending notification.` + '\n';
            console.info(`Succeeded in sending notification.`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to send notification. Code is ${error.code}, message is ${error.message}` + '\n';
            console.error(`Failed to send notification. Code is ${error.code}, message is ${error.message}`);
          })
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
      .height(STRING_PERCENT.TWENTY_PERCENT)
      .align(Alignment.TopStart)

      Button($r("app.string.btn_clear_print"), { type: ButtonType.Capsule })
        .width(STRING_PERCENT.NINETY_PERCENT)
        .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
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