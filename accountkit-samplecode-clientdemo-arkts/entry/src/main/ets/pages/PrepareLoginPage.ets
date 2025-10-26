/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserInfo } from '../common/UserInfo';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { getWhiteSpaceWidthByDisplayWidth } from '../common/Utils';
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

const logTag: string = 'PrepareLoginPage';
const domainId: number = 0x0000;

@Component
export struct PrepareLoginPage {
  cards: number[] = [72, 144, 88, 192];
  @State show: Resource | string = $r('app.string.login'); // Sign in/Sign up; Dear user; and nickname.
  // Enjoy more services after signing in; Good morning, dear user.
  @State hint: Resource | string = $r('app.string.login_for_enjoy_service');
  @LocalStorageLink('isLogin') isLogin: boolean = false;
  @LocalStorageProp('avatar') avatar?: string = undefined;
  @LocalStorageProp('nickName') nickName?: string = undefined;
  @LocalStorageLink('quickLoginAnonymousPhone') quickLoginAnonymousPhone?: string = undefined;
  loginData?: Record<string, Object>;
  pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>();
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;
  @LocalStorageProp('isPad') isPad: boolean = false;
  @LocalStorageProp('isDevice2in1') isDevice2in1: boolean = false

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  // Redirect to PersonalInfoPage.
  private jumpPersonalInfo() {
    hilog.info(domainId, logTag, 'Go to PersonalInfoPage');
    this.pageInfos?.pushPathByName('PersonalInfoPage', null, true);
  }

  @Builder
  Unit(active: boolean = false) {
    Column() {
      Image(active ? $r('app.media.ic_me') : $r('app.media.ic_me_normal'))
        .width(this.isLandScape && this.isPad ? 24 : 21)
        .height(this.isLandScape && this.isPad ? 24 : 21)
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
    .width(this.isLandScape && this.isPad ? '100%' : '25%')
    .height(this.isLandScape && this.isPad ? 100 : 52)
    .padding({
      top: 5,
      bottom: 5
    })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  NavBar() {
    Flex({
      direction: this.isPad && this.isLandScape ? FlexDirection.Column : FlexDirection.Row,
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
    .width(this.isPad && this.isLandScape ? 96 : '100%')
    .height(this.isPad && this.isLandScape ? '100%' : 80)
    .alignSelf(ItemAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  @Builder
  Unit2in1(active?: boolean) {
    Row() {
      Image(active ? $r('app.media.ic_me_2in1') : $r('app.media.ic_me_normal'))
        .width(24)
        .height(24)
        .borderRadius('50%')
        .margin({ left: 8 })
        .draggable(false)

      Text('Tab')
        .fontSize(16)
        .lineHeight(24)
        .fontWeight(FontWeight.Regular)
        .fontColor(active ? $r('sys.color.ohos_id_color_primary') : $r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ left: 8 })
        .fontWeight(FontWeight.Medium)
    }
    .height(40)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .borderRadius(8)
    .backgroundColor(active ? '#29CE0E2D' : Color.Transparent)
    .margin({ bottom: 2 })
  }

  @Builder
  NavBar2in1() {
    Column() {
      Row() {
        Image($r('app.media.appmarket'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .draggable(false)

        Text($r('app.string.app_name'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
      }
      .height(56)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .backgroundColor(Color.Transparent)
      .margin({ bottom: 8 })

      this.Unit2in1()
      this.Unit2in1()
      this.Unit2in1()
      this.Unit2in1(true)
    }
    .width(240)
    .padding({
      left: 16,
      right: 16
    })
    .backgroundColor(Color.Transparent)
    .border({
      width: { right: 1 },
      color: $r('sys.color.ohos_id_color_button_normal')
    })
    .height('100%')
    .backgroundEffect({ radius: 50 })
    .shadow({ radius: 20, offsetX: -20 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Flex({
          direction: this.isLandScape && this.isPad ? FlexDirection.RowReverse : FlexDirection.Column,
          justifyContent: FlexAlign.SpaceAround,
          alignItems: this.isLandScape && this.isPad ? ItemAlign.Center : ItemAlign.Start
        }) {
          Column() {
            Row() {
              Row() {
                Image((this.isLogin ? this.avatar ?? $r('app.media.dear_user') : $r('app.media.avatar')))
                  .borderRadius(28)
                  .width(56)
                  .height(56)
                  .margin(12)
                  .draggable(false)
                Column() {
                  Row() {
                    Text(this.isLogin ? this.nickName ?? $r('app.string.dearUser') : $r('app.string.login'))
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
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .id('dearUserOrLoginRow')
              .onClick(() => {
                AvoidRepeatClick.avoidRepeatClick(() => {
                  if (this.isLogin) {
                    // Redirect to PersonalInfoPage.
                    this.jumpPersonalInfo();
                  } else {
                    try {
                      const hasNet: boolean = connection.hasDefaultNetSync();
                      if (!hasNet) {
                        this.getUIContext().showAlertDialog({
                          message: $r('app.string.hwid_no_internet_connect'),
                          textStyle: { wordBreak: WordBreak.BREAK_WORD },
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

                      // Show the one-tap sign-in screen.
                      hilog.info(domainId, logTag, 'Go to QuickLoginPage');
                      this.pageInfos?.pushPathByName('QuickLoginPage', null, true);
                    } catch (error) {
                      hilog.error(domainId, logTag,
                        `Show the one-tap sign-in screen failed. ErrCode: ${error.code}, errMessage: ${error.message}`);
                    }
                  }
                })
              })
            }
            .width('100%')
            .padding({
              top: 12,
              right: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
              bottom: 12,
              left: getWhiteSpaceWidthByDisplayWidth(this.displayWidth)
            })
            .margin({
              /*
               * There is no need to avoid the top status bar
               * when the device is a phone in landscape mode or 2-in-1 device.
               * */
              top: this.isLandScape && this.isPhone || this.isDevice2in1 ? 0 :
                this.getUIContext().px2vp(this.statusBarHeight)
            })
            .constraintSize({
              maxWidth: 1080 + 2 * getWhiteSpaceWidthByDisplayWidth(this.displayWidth)
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
              left: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
              right: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
              bottom: this.isLandScape && this.isPad ? 28 : 0
            })
            .width('100%')
            .layoutWeight(1)
          }
          .layoutWeight(1)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

          if (this.isDevice2in1) {
            this.NavBar2in1()
          } else {
            this.NavBar()
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onBackPressed(() => {
      // Directly exit the app after a gesture is performed.
      hilog.info(domainId, logTag, 'PrepareLoginPage onBackPressed');
      (this.getUIContext().getHostContext() as common.UIAbilityContext).terminateSelf()
        .catch((error: BusinessError) => {
          hilog.error(domainId, logTag,
            `Failed to terminateSelf. errCode: ${error.code}, errMessage: ${error.message}`);
        })
      return true;
    })
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
