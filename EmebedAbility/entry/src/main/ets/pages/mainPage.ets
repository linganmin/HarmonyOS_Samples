/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { FullScreenLaunchComponent } from '@kit.ArkUI';

@Entry
@Component
struct MainPage {
  @State phoneRechageAppId: string = '5765880207853275489';
  @State utilityPaymentAppId: string = '5765880207854009843';
  @State parkingAppId: string = '5765880207853986683';

  build() {
    Navigation() {
      Row() {
        FullScreenLaunchComponent({
          content: PhoneRechageChild,
          appId: this.phoneRechageAppId,
          options: {}
        })

        FullScreenLaunchComponent({
          content: UtilityPaymentChild,
          appId: this.utilityPaymentAppId,
          options: {}
        })

        FullScreenLaunchComponent({
          content: ParkingChild,
          appId: this.parkingAppId,
          options: {}
        })
      }
      .width('100%')
      .margin({ top: 20 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .title('embedAbilityDemo')
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}

@Builder
function PhoneRechageChild() {
  Column() {
    Image($r('app.media.phonerecharge'))
      .width('36vp')
      .height('36vp')
    Text($r('app.string.PhoneRechageChild_label'))
      .fontSize(10)
  }
}

@Builder
function UtilityPaymentChild() {
  Column() {
    Image($r('app.media.utilityPayment'))
      .width('36vp')
      .height('36vp')
    Text($r('app.string.UtilityPaymentChild_label'))
      .fontSize(10)
  }
}

@Builder
function ParkingChild() {
  Column() {
    Image($r('app.media.parking'))
      .width('36vp')
      .height('36vp')
    Text($r('app.string.ParkingChild_label'))
      .fontSize(10)
  }
}