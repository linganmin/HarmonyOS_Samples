/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { STRING_MARGIN, STRING_PERCENT } from '../util/Constant';
import { wearEngine } from '@kit.WearEngine';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct MonitorPage {
  @State deviceClient: wearEngine.DeviceClient = wearEngine.getDeviceClient(getContext(this));
  @State monitorClient: wearEngine.MonitorClient = wearEngine.getMonitorClient(getContext(this));
  @State monitorItem: wearEngine.MonitorItem = wearEngine.MonitorItem.WEAR_STATUS;
  @State monitorEvent: wearEngine.MonitorEvent = wearEngine.MonitorEvent.EVENT_CONNECTION_STATUS_CHANGED;
  @State deviceList: wearEngine.Device[] = [];
  @State printContent: string = '';
  private callback = (data: wearEngine.MonitorEventData) => {
    this.printContent += JSON.stringify(data) + '\n';
  }
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
  @State devices: wearEngine.Device[] = [];

  build() {
    Column() {
      Text($r("app.string.monitor_title"))
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

      Scroll() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap
        }) {
          ForEach(Object.values(wearEngine.MonitorItem), (item: wearEngine.MonitorItem, index: number | undefined) => {
            Row() {
              Radio({ value: item, group: "monitorItems" })
                .height(20)
                .width(20)
                .onChange(() => {
                  this.monitorItem = item;
                })
                .checked(item === wearEngine.MonitorItem.WEAR_STATUS)
              Text(item).fontSize(14).opacity(Number.parseFloat('0.6'))
            }
            .margin({ left: 10, top: 8 })
          }, (item: number) => JSON.stringify(item))
        }
      }

      Button($r('app.string.btn_query_status'), { type: ButtonType.Capsule })
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
          this.monitorClient.queryStatus(this.changeItem.randomId, this.monitorItem).then((result) => {
            this.printContent += this.monitorItem + ' is ' + result.code + '.\n';
            console.info(`Succeeded in querying ${this.monitorItem}, result is ${result.code}.`);
          }).catch((error: BusinessError) => {
            this.printContent += `Failed to query wear status. Code is ${error.code}, message is ${error.message}.` + '\n';
            console.error(`Failed to query wear status. Code is ${error.code}, message is ${error.message}.`);
          })
        })

      Scroll() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap
        }) {
          ForEach(Object.values(wearEngine.MonitorEvent), (item: wearEngine.MonitorEvent, index: number | undefined) => {
            Row() {
              Radio({ value: item, group: "monitorEvents" })
                .height(20)
                .width(20)
                .onChange(() => {
                  this.monitorEvent = item;
                })
                .checked(item === wearEngine.MonitorEvent.EVENT_CONNECTION_STATUS_CHANGED)
              Text(item).fontSize(14).opacity(Number.parseFloat('0.6'))
            }
            .margin({ left: 10, top: 8 })
          }, (item: number) => JSON.stringify(item))
        }
      }

      Row() {
        Button($r('app.string.btn_subscribe_event'), { type: ButtonType.Capsule })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n'
              return;
            }
            this.monitorClient.subscribeEvent(this.changeItem.randomId, this.monitorEvent, this.callback).then(() => {
              this.printContent += 'Succeeded in subscribing ' + this.monitorEvent + '.\n';
              console.info(`Succeeded in subscribing wear status.`);
            }).catch((error: BusinessError) => {
              this.printContent += 'Failed to subscribe wear status. Code is ' + error.code + ', message is ' + error.message + '.\n';
              console.error(`Failed to subscribe wear status. Code is ${error.code}, message is ${error.message}.`);
            })
          })

        Button($r('app.string.btn_unsubscribe_event'), { type: ButtonType.Capsule })
          .margin({ left: STRING_MARGIN.BUTTON_LEFT_SIZE })
          .fontSize(STRING_MARGIN.BUTTON_FONT_SIZE)
          .layoutWeight(1)
          .backgroundColor($r("app.color.base_button_color"))
          .onClick(() => {
            if (this.changeItem.name === 'default') {
              this.printContent += 'Please select target device.' + '\n';
              return;
            }
            this.monitorClient.unsubscribeEvent(this.changeItem.randomId, this.monitorEvent, this.callback)
              .then(() => {
                this.printContent += 'Succeeded in unsubscribing ' + this.monitorEvent + '.\n';
                console.info(`Succeeded in unsubscribing wear status`);
              })
              .catch((error: BusinessError) => {
                this.printContent += 'Failed to unsubscribe wear status. Code is ' + error.code + ', message is ' + error.message + '.\n';
                console.error(`Failed to unsubscribe wear status. Code is ${error.code}, message is ${error.message}.`);
              })
          })

      }
      .width(STRING_PERCENT.NINETY_PERCENT)
      .margin({
        top: STRING_MARGIN.MARGIN_TOP_SIZE,
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
      .height(STRING_PERCENT.THIRTY_FIVE_PERCENT)
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