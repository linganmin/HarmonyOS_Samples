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

import { display, promptAction, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import bluetoothClientModel from '../viewmodel/BluetoothClientModel';
import NavigationBar from '../uicomponents/NavigationBar';
import HeartRateGraph from '../uicomponents/HeartRateGraph';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const HEIGHT_NAVIGATION_BAR = 64;
const HEIGHT_TOP_ROW = 40;
const MARGIN_HORIZONTAL = 60;
const HEART_RATE_TOO_LOW = 50;
const HEART_RATE_TOO_HIGH = 100;
const context: Context = uiContext!.getHostContext()!;

@Component
export struct HeartRate {
  @StorageLink('heartRate') @Watch('onHeartRate') heartRate: number = 0;
  @StorageLink('windowSize') @Watch('onWindowSizeChange') windowSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State heartRateTop: number = 0;
  @State heartRateBottom: number = 0;
  @State heartRateAverage: number = 0;
  @State graphWidth: number = this.windowSize.width - this.getUIContext().vp2px(MARGIN_HORIZONTAL) * 2;
  @State graphHeight: number = this.windowSize.height - this.getUIContext().vp2px(HEIGHT_NAVIGATION_BAR) -
  this.getUIContext().vp2px(HEIGHT_TOP_ROW * 3);
  @State isConnect: boolean = false;
  private windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();

  onHeartRate(): void {
    this.heartRateTop = this.heartRateTop < this.heartRate ? this.heartRate : this.heartRateTop;
    this.heartRateBottom = (this.heartRateBottom === 0) ? this.heartRate :
      (this.heartRateBottom > this.heartRate) ? this.heartRate : this.heartRateBottom;
    this.heartRateAverage = (this.heartRateAverage + this.heartRate) / 2;
  }

  onWindowSizeChange(): void {
    this.graphWidth = this.windowSize.width - this.getUIContext().vp2px(MARGIN_HORIZONTAL) * 2;
    this.graphHeight = this.windowSize.height - this.getUIContext().vp2px(HEIGHT_NAVIGATION_BAR) -
    this.getUIContext().vp2px(HEIGHT_TOP_ROW * 3);
  }

  showWarningReminder(): boolean {
    return this.tooHigh() || this.tooLow();
  }

  tooHigh(): boolean {
    return this.heartRate > HEART_RATE_TOO_HIGH;
  }

  tooLow(): boolean {
    return this.heartRate < HEART_RATE_TOO_LOW;
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      Logger.info('setWindowOrientation Succeeded');
    }).catch((err: BusinessError) => {
      Logger.error(`setWindowOrientation Failed. Cause:${JSON.stringify(err)}`);
    })
    try {
      this.windowClass.setWindowSystemBarEnable([]);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'HeartRate',
        `getMainWindowSync failed. code=${err.code}, message=${err.message}`);
    }
  }

  aboutToAppear() {
    this.setOrientation(window.Orientation.LANDSCAPE);
    let mWindow: window.Window | undefined;
    let windowStage: window.WindowStage | undefined;
    try {
      mWindow = windowStage?.getMainWindowSync();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'HeartRate',
        `getMainWindowSync failed. code=${err.code}, message=${err.message}`);
    }
    mWindow?.on('windowSizeChange', (size: window.Size) => {
      AppStorage.setOrCreate('windowSize', size);
    })

    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
        }
        display.on('change', callback);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'HeartRate',
        `isFoldable or getFoldStatus failed. code=${err.code}, message=${err.message}`);
    }
  }

  aboutToDisappear(): void {
    this.setOrientation(window.Orientation.PORTRAIT);
  }

  build() {
    NavDestination() {
      NavigationBar({
        title: $r('app.string.real_time_heart_rate_graph'),
        showIndicator: true,
        actions: [{
          id: 'btn_disconnect',
          event: () => {
            if (!this.isConnect) {
              bluetoothClientModel.offBLECharacteristicChange();
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.disconnected'),
                duration: 2000
              })
              bluetoothClientModel.changeConnectState();
            }
          }
        }]
      })
        .height(HEIGHT_NAVIGATION_BAR)

      Row() {
        Row() {
          Image($r('app.media.heart_fill'))
            .width(36)
            .aspectRatio(1)
            .margin({ left: 8 })
          Column() {
            Row() {
              Text(`${this.heartRateTop}`)
                .fontColor(Color.Black)
                .opacity(0.9)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
              Text($r('app.string.times_per_minute'))
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(90)

            Text($r('app.string.maximum_heart_rate'))
              .fontColor(Color.Black)
              .opacity(0.6)
              .width(90)
          }
          .margin({ left: 30, right: 50 })

          Column() {
            Row() {
              Text(`${this.heartRateBottom}`)
                .fontColor(Color.Black)
                .opacity(0.9)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
              Text($r('app.string.times_per_minute'))
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(90)

            Text($r('app.string.minimum_heart_rate'))
              .fontColor(Color.Black)
              .opacity(0.6)
              .width(90)
          }
        }
        .alignItems(VerticalAlign.Center)
        .width(this.isFoldAble && this.foldStatus === 2 ? 345 : 360)
        .height(90)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ right: 24 })

        Row() {
          Image($r('app.media.waveform_path_ecg_heart_fill'))
            .width(36)
            .aspectRatio(1)
            .margin({ left: 8 })
          Column() {
            Row() {
              Text(`${Math.floor(this.heartRateAverage)}`)
                .fontColor(Color.Black)
                .opacity(0.9)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
              Text($r('app.string.times_per_minute'))
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(90)

            Text($r('app.string.mean_heart_rate'))
              .fontColor(Color.Black)
              .opacity(0.6)
              .width(90)
          }
          .margin({ left: 30, right: 50 })

          Column() {
            Row() {
              Text(`${this.heartRate}`)
                .fontColor(Color.Black)
                .opacity(0.9)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
              Text($r('app.string.times_per_minute'))
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(90)

            Text($r('app.string.current_heart'))
              .fontColor(Color.Black)
              .opacity(0.6)
              .width(90)
          }
        }
        .alignItems(VerticalAlign.Center)
        .width(this.isFoldAble && this.foldStatus === 2 ? 345 : 360)
        .height(90)
        .backgroundColor(Color.White)
        .borderRadius(12)
      }
      .width('100%')
      .height(90)
      .padding({ left: 60, right: 60 })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 36 })

      HeartRateGraph({
        viewWidth: 756,
        viewHeight: 180
      })
    }
    .hideTitleBar(true)
    .backgroundColor('#F5F5F5')
  }
}