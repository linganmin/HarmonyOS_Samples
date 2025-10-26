/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.getUIContext().getHostContext() as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .catch((err: BusinessError) => {
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      })
  }

  build() {
    Navigation(this.pathStack) {
      Row() {
        Column() {
          Button() {
            Text('MapController').fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .margin({ top: 30 })
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.pathStack.pushPathByName('MapControllerDemo', null);
          });

          Button() {
            Text('Overlay').fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .margin({ top: 30 })
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.pathStack.pushPathByName('OverlayDemo', null);
          })

          Button() {
            Text('StaticMap').fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .margin({ top: 30 })
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.pathStack.pushPathByName('StaticMapDemo', null);
          })

          Button() {
            Text('NaviDemo').fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .margin({ top: 30 })
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.pathStack.pushPathByName('NaviDemo', null);
          })

          Button() {
            Text('AdvancedControls').fontSize(20).fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .margin({ top: 30 })
          .backgroundColor('#0D9FFB')
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.pathStack.pushPathByName('AdvancedControlsDemo', null);
          })
        }
        .width('100%')
      }
      .height('100%')
    }
    .mode(NavigationMode.Stack)
  }
}