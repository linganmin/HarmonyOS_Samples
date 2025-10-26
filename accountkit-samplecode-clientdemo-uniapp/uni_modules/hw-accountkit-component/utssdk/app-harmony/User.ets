/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from "@kit.AbilityKit";

const logTag: string = 'PersonalInfoPage';
const domainId: number = 0x0000;

// Define the anonymous phone number that uni-app passes to the personal information page.
interface AnonymousPhoneOptions extends NativeEmbedBuilderOptions {
  quickLoginAnonymousPhone: string
}

// Define the sign-out data that the personal information page passes to uni-app.
interface onLogOutDetail {
  isLogOut: boolean
}

// Place all data that the component should return to uni-app within the specified field in detail.
interface onLogOutData {
  detail: onLogOutDetail
}

@Component
struct Phone {
  quickLoginAnonymousPhone?: string;

  onBackPress(): boolean | void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.moveAbilityToBackground();
  }

  build() {
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
    .border({
      width: 2,
      color: $r('sys.color.ohos_fa_list_card_bg'),
      radius: 20
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .id('phoneRow')
  }
}

@Component
export struct User {
  quickLoginAnonymousPhone?: string = '180******00';
  logout?: Function;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  build() {
    Column() {
      // Page title and back button.
      Row() {
        Text($r('app.string.personalInfo'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
          .padding({ left: 8 })
      }.alignSelf(ItemAlign.Start)
      .height(56)
      .margin({
        top: 36,
        left: 24,
        right: 24
      })

      Column() {
        List({ space: 12 }) {
          ListItem({ style: ListItemStyle.CARD }) {
            // Mobile number.
            Phone({
              quickLoginAnonymousPhone: this.quickLoginAnonymousPhone,
            })
          }
          .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
          .borderRadius(20)
          .height(undefined)
          .padding(0)
        }

        // Sign out.
        Row() {
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
            if (this.logout) {
              this.logout({ detail: { isLogOut: true } } as onLogOutData);
            }
          })
        }
        .padding({
          bottom: 44,
          top: 24
        })
        .margin({ top: 56 })
      }
      .padding({
        left: 16,
        right: 16
      })
      .height('90%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    }
  }
}


@Builder
function UserBuilder(userparams: AnonymousPhoneOptions) {
  User({
    quickLoginAnonymousPhone: userparams.quickLoginAnonymousPhone,
    logout: userparams?.on?.get('user_logout')
  })
    .width(userparams.width)
    .height(userparams.height)
}

// Declare the components that need to be embedded into uni-app.
defineNativeEmbed('usercomponent', {
  builder: UserBuilder
})
