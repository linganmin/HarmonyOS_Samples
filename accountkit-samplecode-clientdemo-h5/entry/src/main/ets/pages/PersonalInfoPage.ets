/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

const logTag: string = 'PersonalInfoPage';
const domainId: number = 0x0000;

@Component
export struct PersonalInfoPage {
  @Consume('pageInfos') pageInfos?: NavPathStack;
  @StorageProp('quickLoginAnonymousPhone') quickLoginAnonymousPhone: string = '';

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  // Sign out.
  logout() {
    hilog.info(domainId, logTag, 'Return to PrepareLoginPage.');
    this.pageInfos?.replacePathByName('PrepareLoginPage', null, true);
    // Clear app cache data.
    AppStorage.clear();
  }

  build() {
    NavDestination() {
      Column() {
        // Page title and back button.
        Row() {
          Text($r('app.string.personalInfo'))
            .fontSize($r('sys.float.ohos_id_text_size_headline8'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 8 })
        }.alignSelf(ItemAlign.Start)
        .height(56)

        Row() {
          Text($r('app.string.phone'))
            .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
            .fontWeight(FontWeight.Medium)
            .height('100%')
          Row() {
            Text(this.quickLoginAnonymousPhone)
              .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .height(19)
              .width(100)
              .padding({ left: 20 })
            Image($r('app.media.ic_public_arrow_right'))
              .fillColor($r('sys.color.ohos_id_color_foreground'))
              .opacity(0.2)
              .width(12)
              .height(24)
              .margin({ left: 4 })
              .draggable(false)
          }
          .width(115)
        }
        .width('100%')
        .height(56)
        .padding({
          left: 12,
          right: 12,
          top: 4,
          bottom: 4
        })
        .margin({ top: 8 })
        .border({
          width: 2,
          color: $r('sys.color.ohos_fa_list_card_bg'),
          radius: 20
        })
        .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
        .justifyContent(FlexAlign.SpaceBetween)
        .id('phoneRow')

        Blank().layoutWeight(1)

        Button({ type: ButtonType.Capsule }) {
          Text($r('app.string.logout'))
            .fontWeight(FontWeight.Medium)
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('app.color.activity_color'))
        .width('100%')
        .height(40)
        .constraintSize({
          maxWidth: 448
        })
        .id('logoutButton')
        .onClick(() => {
          this.logout();
        })
      }
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .padding({
        left: 16,
        right: 16
      })
    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .onBackPressed(() => true)
  }
}
