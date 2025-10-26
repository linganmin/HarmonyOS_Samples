/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { gamePerformance } from '@kit.GameServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State logText: string = 'to show log'

  build() {
    Column() {
      Row() {
        Button($r('app.string.init'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize('16fp')
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Black)
            },
            normal: {
              .backgroundColor(Color.Blue)
            }
          })
          .fontWeight(500)
          .width('80%')
          .height(40)
          .onClick(() => {
            this.gamePerformanceInit()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })

      Row() {
        Button($r('app.string.subscribe'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize('16fp')
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Black)
            },
            normal: {
              .backgroundColor(Color.Blue)
            }
          })
          .fontWeight(500)
          .width('80%')
          .height(40)
          .onClick(() => {
            this.subscribeDeviceState();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })

      Row() {
        Button($r('app.string.unSubscribe'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize('16fp')
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Black)
            },
            normal: {
              .backgroundColor(Color.Blue)
            }
          })
          .fontWeight(500)
          .width('80%')
          .height(40)
          .onClick(() => {
            this.unSubscribeDeviceState();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })

      Row() {
        Button($r('app.string.update'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize('16fp')
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Black)
            },
            normal: {
              .backgroundColor(Color.Blue)
            }
          })
          .fontWeight(500)
          .width('80%')
          .height(40)
          .onClick(() => {
            this.updateGameSceneInfo();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })

      Row() {
        Button($r('app.string.query'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize('16fp')
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Black)
            },
            normal: {
              .backgroundColor(Color.Blue)
            }
          })
          .fontWeight(500)
          .width('80%')
          .height(40)
          .onClick(() => {
            this.queryDeviceInfo();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })

      Row() {
        Text(this.logText)
          .width(250)
          .textOverflow({ overflow: TextOverflow.None })
          .maxLines(30)
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }

  private subscribeDeviceState() {
    try {
      gamePerformance.on('deviceStateChanged', (data: gamePerformance.DeviceInfo) => {
        console.info(`Device temperature level change to ${data.tempLevel} .`);
        this.logText = `Device temperature level change to ${data.tempLevel}.`;
      });
      this.logText = `Subscribe device state event succeeded.`;
      console.info('Subscribe device state event succeeded.');
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Subscribe device state change failed. errCode is ${error.code}, errMessage is ${error.message}`);
      this.logText =
        `Failed to subscribe device state change event. errCode is ${error.code}, errMessage is ${error.message}`;
    }
  }

  private unSubscribeDeviceState() {
    try {
      gamePerformance.off('deviceStateChanged');
      this.logText = `UnSubscribe device state event succeeded.`;
      console.info('UnSubscribe device state event succeeded.');
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Unsubscribe device state change failed. errCode is ${error.code}, errMessage is ${error.message}`);
      this.logText =
        `Failed to unsubscribe device state change event. errCode is ${error.code}, errMessage is ${error.message}`;
    }
  }

  private queryDeviceInfo() {
    try {
      let gpuParam: gamePerformance.DeviceInfoParameter = {
        deviceInfoType: gamePerformance.DeviceInfoType.GPU
      }
      let thermalParam: gamePerformance.DeviceInfoParameter = {
        deviceInfoType: gamePerformance.DeviceInfoType.THERMAL
      }
      let gameInfos: Array<gamePerformance.DeviceInfoParameter> = [gpuParam, thermalParam];

      gamePerformance.getDeviceInfoByScope(gameInfos).then((deviceInfo: gamePerformance.DeviceInfo) => {
        console.info(`Query device info succeeded, tempLevel is ${deviceInfo.tempLevel}`);
        this.logText = 'Query device info succeeded.'
      });
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Query device info failed. errCode is ${error.code}, errMessage is ${error.message}`);
      this.logText = `Query device info failed. errCode is ${error.code}, errMessage is ${error.message}`;
    }
  }

  private updateGameSceneInfo() {
    try {
      let gameSceneInfo: gamePerformance.GameSceneInfo = {
        messageType: 2,
        extra: '',
        sceneID: 1111,
        importanceLevel: 1111
      };
      gamePerformance.updateGameInfo(gameSceneInfo).then(() => {
        console.info('Update game scene info succeeded.');
        this.logText = 'Update game scene info succeeded.'
      }).catch((error: BusinessError) => {
        console.error(`Update game scene info failed. errCode is ${error.code}, errMessage is ${error.message}`);
        this.logText = `Failed to update game scene info. errCode is ${error.code}, errMessage is ${error.message}`;
      });
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Update game scene info failed. errCode is ${error.code}, errMessage is ${error.message}`);
      this.logText = `Failed to update game scene info. errCode is ${error.code}, errMessage is ${error.message}`;
    }
  }

  aboutToAppear() {
  }

  gamePerformanceInit() {
    let gamePageInfo: gamePerformance.GamePackageInfo = {
      messageType: 0,
      extra: '',
      appVersion: '1.0',
      bundleName: 'com.xxx.xxx.huawei'
    }
    try {
      gamePerformance.init(gamePageInfo).then(() => {
        this.logText = 'gamePerformance initialized successfully.'
      })
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to initialize gamePerformance. errCode is ${error.code}, errMessage is ${error.message}`);
      this.logText = `Failed to initialize gamePerformance. errCode is ${error.code}, errMessage is ${error.message}`;
    }
  }
}