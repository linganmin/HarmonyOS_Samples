/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection } from '@kit.NetworkKit';
import { AvoidReclick } from "./Utils/AvoidReclick";

// Define the data that uni-app sends back to the sign-in/sign-up page, which is used to control page redirection.
interface IsGetAnonymousPhoneOptions extends NativeEmbedBuilderOptions {
  isGetAnonymousPhone: boolean
}

// Define the data that the sign-in/sign-up page sends back to uni-app.
interface onGetAnonymousPhoneDetail {
  isGetAnonymousPhone: boolean
}

// Place all data that the component should return to uni-app within the specified field in detail.
interface onGetAnonymousPhoneData {
  detail: onGetAnonymousPhoneDetail
}

const logTag: string = 'HomePage';
const domainId: number = 0x0000;

@Component
export struct Home {
  cards: number[] = [72, 144, 88, 200];
  private isLogin: boolean = false;
  quickLoginAnonymousPhone?: string = undefined;
  getAnonymousPhoneCallBack?: Function;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  @Builder
  Unit(active: boolean = false) {
    Column() {
      Image(active ? $r('app.media.ic_me') : $r('app.media.ic_me_normal'))
        .width(24)
        .height(24)
        .borderRadius('50%')
        .draggable(false)

      Text('Tab')
        .fontSize(10)
        .lineHeight(13)
        .fontWeight(FontWeight.Regular)
        .fontColor(active ? $r('app.color.activity_color') : $r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
    .width('25%')
    .height(52)
    .padding({
      top: 5,
      bottom: 5
    })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  NavBar() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.Center
    }) {
      this.Unit()
      this.Unit()
      this.Unit()
      this.Unit(true)
    }
    .shadow({
      type: ShadowType.COLOR,
      color: '#ff807b7b',
      offsetX: 0,
      offsetY: 0,
      fill: true
    } as ShadowOptions)
    .width('100%')
    .height(80)
    .alignSelf(ItemAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Start
      }) {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.avatar'))
                .borderRadius(28)
                .width(56)
                .height(56)
                .margin(12)
                .draggable(false)
              Column() {
                Row() {
                  Text($r('app.string.login'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_sub_title1'))
                    .height(24)
                }

                Row() {
                  Text(this.isLogin ? $r('app.string.dear_user_good_morning') :
                  $r('app.string.login_for_enjoy_service'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .height(18)
                    .opacity(0.4)
                }
              }
              .alignItems(HorizontalAlign.Start)
            }
            .id('dearUserOrLoginRow')
            .onClick(() => {
              const hasNet: boolean = connection.hasDefaultNetSync();
              if (!hasNet) {
                this.getUIContext().showAlertDialog({
                  message: $r('app.string.hwid_no_internet_connect'),
                  offset: { dx: 0, dy: -12 },
                  alignment: DialogAlignment.Center,
                  autoCancel: false,
                  confirm: {
                    value: $r('app.string.hwid_text_button_known'),
                    action: () => {
                    }
                  }
                })
                return;
              }
              AvoidReclick.avoidRepeatClick(() => {
                if (this.getAnonymousPhoneCallBack) {
                  // Redirect to the one-tap sign-in page.
                  hilog.info(domainId, logTag, 'Go to QuickLoginPage');
                  this.getAnonymousPhoneCallBack({ detail: { isGetAnonymousPhone: true } } as onGetAnonymousPhoneData);
                }
              });
            })
          }
          .width('100%')
          .padding({
            top: 52,
            right: 16,
            bottom: 12,
            left: 16
          })

          Scroll() {
            Column() {
              ForEach(this.cards, (item: number) => {
                Card(item)
              }, (item: number, index: number) => `${item}_${index}`)
            }
            .height('100%')
            .constraintSize({
              minHeight: this.cards.reduce((p: number, c: number) => p + c + 12, 2),
              maxWidth: 1080
            })
            .width('100%')
          }
          .padding({
            left: 16,
            right: 16,
          })
          .width('100%')
        }
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

        this.NavBar()
      }
    }
    .backgroundColor(Color.Transparent)
  }
}

@Builder
function Card(cardHeight: number) {
  Row() {
  }
  .margin({ bottom: 12 })
  .padding({ left: 16, right: 16 })
  .height(cardHeight)
  .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
  .borderRadius(20)
  .width('100%')
}

@Builder
function HomeBuilder(homeparams: IsGetAnonymousPhoneOptions) {
  Home({
    getAnonymousPhoneCallBack: homeparams?.on?.get('on_get_anonymous_phone')
  })
    .width(homeparams.width)
    .height(homeparams.height)
}

// Declare the components that need to be embedded into uni-app.
defineNativeEmbed('homecomponent', {
  builder: HomeBuilder
})
