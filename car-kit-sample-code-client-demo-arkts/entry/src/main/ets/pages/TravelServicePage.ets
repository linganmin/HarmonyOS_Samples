/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { smartMobilityCommon } from '@kit.CarKit';
import { promptAction } from '@kit.ArkUI';
import CommonUtils from '../common/CommonUtils';
import { Logger } from '../common/Logger';

const TAG = 'TravelServicePage'

@CustomDialog
struct CustomDialogExample {
  @Link title: string | Resource;
  @Link message: string;
  controller?: CustomDialogController;
  uiContext: UIContext | undefined = undefined;

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
  }

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Scroll() {
      Column() {
        Text(this.title)
          .fontSize(CommonUtils.getCustomDialogTitleSize(this.uiContext))
          .fontWeight(700)
          .height(this.uiContext?.px2vp(196))
          .margin({ left: this.uiContext?.px2vp(84), right: this.uiContext?.px2vp(84), top: this.uiContext?.px2vp(42) })
          .textAlign(TextAlign.Center)
        Text(this.message)
          .fontSize(this.uiContext?.px2vp(56))
          .fontWeight(400)
          .textAlign(TextAlign.Start)
          .margin({ left: this.uiContext?.px2vp(84), right: this.uiContext?.px2vp(84), top: this.uiContext?.px2vp(28) })
          .width('90%')
        Button('OK', { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL })
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close();
            }
          })
          .stateEffect(false)
          .fontSize(this.uiContext?.px2vp(56))
          .fontWeight(500)
          .margin(this.uiContext?.px2vp(28))
      }
    }
  }
}

@Component
struct TravelServicePage {
  @State titleValue: string | Resource = '';
  @State messageValue: string = '';
  index: number = 0;
  state: boolean = false;
  uiContext: UIContext | undefined = undefined;

  @Builder
  customButton(text: string | Resource, clickCall: (() => void)) {
    Row() {
      Button(text)
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.ohos_dialog_text_alert_dark'))
        .fontWeight(500)
        .fontSize(CommonUtils.getCustomButtonFontSize(this.uiContext))
        .align(Alignment.Start)
        .type(ButtonType.Capsule)
        .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56), top: this.uiContext?.px2vp(42) })
        .height(this.uiContext?.px2vp(168))
        .type(ButtonType.Normal)
        .borderRadius(this.uiContext?.px2vp(56))
        .layoutWeight(1)
        .onClick(() => {
          clickCall?.();
        })
    }
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        Logger.info(TAG, 'Callback when the first button is clicked');
      },
      confirm: () => {
        Logger.info(TAG, 'Callback when the second button is clicked');
      },
      title: this.titleValue,
      message: this.messageValue,
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    backgroundColor: Color.White,
  });

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
  }

  aboutToDisappear() {
    this.dialogController = null;
  }

  showAlertDialog(title: string | Resource, message: string) {
    this.titleValue = title;
    this.messageValue = message;
    if (this.dialogController != null) {
      this.dialogController.open();
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text($r('app.string.event_listening'))
            .fontSize(this.uiContext?.px2vp(49))
            .fontWeight(500)
            .textAlign(TextAlign.Start)
            .width('90%')
            .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56), top: this.uiContext?.px2vp(42) })

          this.customButton($r('app.string.register_mobility_service_event_listener'), () => {
            this.registerEventsListener();
          });

          this.customButton($r('app.string.unregister_mobility_service_event_listener'), () => {
            this.unregisterEventsListener();
          });

          this.customButton($r('app.string.obtain_mobility_service_event_information'), () => {
            this.getEvent();
          });

          Text($r('app.string.status_listening'))
            .fontSize(this.uiContext?.px2vp(49))
            .fontWeight(500)
            .textAlign(TextAlign.Start)
            .width('90%')
            .margin({ left: this.uiContext?.px2vp(56), right: this.uiContext?.px2vp(56), top: this.uiContext?.px2vp(84) })

          this.customButton($r('app.string.register_smart_mobility_connection_status_listener'), () => {
            this.registerStatusListener();
          });

          this.customButton($r('app.string.unregister_smart_mobility_connection_status_listener'), () => {
            this.unregisterStatusListener();
          });

          this.customButton($r('app.string.obtain_smart_mobility_connection_status'), () => {
            this.getStatus();
          });
        }
      }
      .align(Alignment.TopStart)
      .height('100%')
      .width('100%')
    }
    .title(CommonUtils.resourceToString($r('app.string.mobility_service_interaction_examples'), this.uiContext))
    .backgroundColor($r('app.color.start_window_background'))
  }

  registerEventsListener() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let types: smartMobilityCommon.SmartMobilityType[] = [smartMobilityCommon.SmartMobilityType.CAR_HOP];
      // smartMobility event callback
      const callBack = (event: smartMobilityCommon.SmartMobilityEvent) => {
        Logger.info(TAG, `Received smart mobility event: ${event}`);
        this.showAlertDialog($r('app.string.register_mobility_service_event_listener'),
          CommonUtils.getSmartMobilityEventString(event));
      };
      // Registers callback to smart mobility event.
      awareness.on('smartMobilityEvent', types, callBack);
      promptAction.openToast({ message: $r('app.string.register_mobility_service_event_listener') })
        .catch(() => {
          Logger.error(TAG, 'event open toast error');
      });
    } catch (err) {
      Logger.error(TAG, `registerEventsListener error ${err.code}`);
    }
  }

  unregisterEventsListener() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let types: smartMobilityCommon.SmartMobilityType[] = [smartMobilityCommon.SmartMobilityType.CAR_HOP];
      // UnRegisters callback to smart mobility event. example 1 : awareness.off('smartMobilityEvent', types);
      // UnRegisters callback to smart mobility event. example 2
      awareness.off('smartMobilityEvent', types);
      promptAction.openToast({ message: $r('app.string.unregister_mobility_service_event_listener') })
        .catch(() => {
          Logger.error(TAG, 'event open toast error');
      });
    } catch (err) {
      Logger.error(TAG, `unregisterEventsListener error ${err.code}`);
    }
  }

  getEvent() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let type = smartMobilityCommon.SmartMobilityType.CAR_HOP;
      // event name
      let eventName = 'CAR_HOP_EVENT';
      // Get SmartMobility event.
      let event: smartMobilityCommon.SmartMobilityEvent = awareness.getSmartMobilityEvent(type, eventName);
      Logger.info(TAG, `getEvent: ret = ${event.eventName}`);
      this.showAlertDialog($r('app.string.obtain_mobility_service_event_information'),
        CommonUtils.getSmartMobilityEventString(event));
    } catch (err) {
      Logger.error(TAG, `getEvent error ${err.code}`);
    }
  }

  registerStatusListener() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let types = [smartMobilityCommon.SmartMobilityType.HICAR, smartMobilityCommon.SmartMobilityType.SUPER_LAUNCHER];
      // smartMobility info callback
      const callBack = (info: smartMobilityCommon.SmartMobilityInfo) => {
        Logger.info(TAG, `Received smart mobility event: ${info}`);
        this.showAlertDialog($r('app.string.register_smart_mobility_connection_status_listener'),
          CommonUtils.getSmartMobilityStatusString(info));
      };
      // Registers callback to smart mobility status change.
      awareness.on('smartMobilityStatus', types, callBack);
      promptAction.openToast({ message: $r('app.string.register_smart_mobility_connection_status_listener') })
        .catch(() => {
          Logger.error(TAG, 'status open toast error');
        });
    } catch (err) {
      Logger.error(TAG, `registerStatusListener error ${err.code}`);
    }
  }

  unregisterStatusListener() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let types = [smartMobilityCommon.SmartMobilityType.HICAR, smartMobilityCommon.SmartMobilityType.SUPER_LAUNCHER];
      // Unregister a smart mobility connection status listener. example 1: awareness.off('smartMobilityStatus', types);
      // Unregister a smart mobility connection status listener. example 2
      awareness.off('smartMobilityStatus', types);
      promptAction.openToast({ message: $r('app.string.unregister_smart_mobility_connection_status_listener') })
        .catch(() => {
          Logger.error(TAG, 'status open toast error');
        });
    } catch (err) {
      Logger.error(TAG, `unregisterStatusListener error ${err.code}`);
    }
  }

  getStatus() {
    try {
      // Get single instance of SmartMobilityAwareness.
      let awareness: smartMobilityCommon.SmartMobilityAwareness = smartMobilityCommon.getSmartMobilityAwareness();
      // service type
      let type = smartMobilityCommon.SmartMobilityType.HICAR;
      let type1 = smartMobilityCommon.SmartMobilityType.SUPER_LAUNCHER;
      // Get SmartMobility status.
      let ret = awareness.getSmartMobilityStatus(type);
      let ret1 = awareness.getSmartMobilityStatus(type1);
      Logger.info(TAG, `ret = ${JSON.stringify(ret)}`);
      Logger.info(TAG, `ret = ${JSON.stringify(ret1)}`);
      let str = `HiCar:\n ${CommonUtils.getSmartMobilityStatusString(ret)}\n SuperLauncher:\n ${CommonUtils.getSmartMobilityStatusString(ret1)}`
      this.showAlertDialog($r('app.string.obtain_smart_mobility_connection_status'), str);
    } catch (err) {
      Logger.error(TAG, `registerStatusListener error ${err.code}`);
    }
  }
}

@Builder
export function TravelServicePageBuilder() {
  TravelServicePage();
}