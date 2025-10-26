/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import gamePerformance from 'libentry.so';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State logText: string = 'to show log'

  build() {
    Column() {
      Row() {
        Row() {
          Text($r('app.string.title')).fontWeight(FontWeight.Bold).fontSize("30fp").width("100%").height("56vp")
        }.height("56vp").padding({ left: "16vp", top: "8vp", bottom: "8vp" })

      }.height("112vp").alignItems(VerticalAlign.Bottom)

      Column() {
        Row() {
          Button($r('app.string.init'), { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceInit()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.registerThermalLevelChangedCallback'), { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceRegisterThermalLevelChangedCallback();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.unregisterThermalLevelChangedCallback'),
            { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceUnregisterThermalLevelChangedCallback();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.unregisterAllThermalLevelChangedCallbacks'),
            { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceUnregisterAllThermalLevelChangedCallbacks();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.updateSceneInfo'), { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceUpdateSceneInfo();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.queryGpuInfo'), { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceQueryGpuInfo();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })

        Row() {
          Button($r('app.string.queryThermalInfo'), { type: ButtonType.Capsule, stateEffect: true })
            .fontSize('16fp')
            .stateStyles({
              pressed: {
                .backgroundColor(Color.Black)
              },
              normal: {
                .backgroundColor($r('app.color.main_button_background'))
              }
            })
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceQueryThermalInfo();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 16
        })

        Row() {
          Text(this.logText)
            .fontSize('16fp')
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              this.gamePerformanceQueryThermalInfo();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 16
        })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  gamePerformanceInit() {
    let code: number = gamePerformance.HMS_GamePerformance_Init();
    if (code === 0) {
      this.logText = 'Game scene perception successfully initialized.'
    } else {
      this.logText = `Failed to initialize game scene perception. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceRegisterThermalLevelChangedCallback() {
    let code: number = gamePerformance.HMS_GamePerformance_RegisterThermalLevelChangedCallback();
    if (code === 0) {
      this.logText = 'Thermal change callback successfully registered.'
    } else {
      this.logText = `Failed to register thermal change callback. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceUnregisterThermalLevelChangedCallback() {
    let code: number = gamePerformance.HMS_GamePerformance_UnregisterThermalLevelChangedCallback();
    if (code === 0) {
      this.logText = 'Thermal change callback successfully unregistered.'
    } else {
      this.logText = `Failed to unregister thermal change callback. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceUnregisterAllThermalLevelChangedCallbacks() {
    let code: number = gamePerformance.HMS_GamePerformance_UnregisterAllThermalLevelChangedCallbacks();
    if (code === 0) {
      this.logText = 'All thermal change callbacks successfully unregistered.'
    } else {
      this.logText = `Failed to unregister all thermal change callbacks. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceUpdateSceneInfo() {
    let code: number = gamePerformance.HMS_GamePerformance_UpdateSceneInfo();
    if (code === 0) {
      this.logText = 'Game scene information successfully updated.'
    } else {
      this.logText = `Failed to update game scene information. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceQueryGpuInfo() {
    let code: number = gamePerformance.HMS_GamePerformance_QueryGpuInfo();
    if (code === 0) {
      this.logText = 'GPU information successfully retrieved.'
    } else {
      this.logText = `Failed to retrieve GPU information. errCode is ${code}`
      console.error(this.logText);
    }
  }

  gamePerformanceQueryThermalInfo() {
    let code: number = gamePerformance.HMS_GamePerformance_QueryThermalInfo();
    if (code === 0) {
      this.logText = 'Temperature information successfully retrieved.'
    } else {
      this.logText = `Failed to query temperature information. errCode is ${code}`
      console.error(this.logText);
    }
  }

}
