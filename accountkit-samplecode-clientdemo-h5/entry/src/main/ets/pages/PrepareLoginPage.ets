/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { dealAllError, getQuickLoginAnonymousPhone } from '../common/Utils';

const logTag: string = 'PrepareLoginPage';
const domainId: number = 0x0000;

@Component
export struct PrepareLoginPage {
  cards: number[] = [72, 144, 88, 192];
  loginData?: Record<string, Object>;
  @Consume('pageInfos') pageInfos: NavPathStack;
  loading: boolean = false; // Indicate whether the mobile number is being obtained.

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  // Redirect to LoginPage.
  private async jumpToLoginPage() {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const quickLoginAnonymousPhone = await getQuickLoginAnonymousPhone();
      if (quickLoginAnonymousPhone !== '') {
        hilog.info(domainId, logTag, `quickLoginAnonymousPhone is ${quickLoginAnonymousPhone}.`);
        hilog.info(domainId, logTag, 'Go to LoginPage.');
        this.pageInfos?.pushPathByName('LoginPage', null, true);
      } else {
        throw new Error('Failed to get quickLoginAnonymousPhone.');
      }
    } catch (err) {
      dealAllError(err, this.getUIContext());
    } finally {
      const timer = setTimeout(() => {
        this.loading = false;
        clearTimeout(timer);
      }, 300);
    }
  }

  @Builder
  Unit(active: boolean = false) {
    Column() {
      Image(active ? $r('app.media.ic_me') : $r('app.media.ic_me_normal'))
        .width(21)
        .height(21)
        .borderRadius('50%')
        .draggable(false)

      Text('Tab')
        .fontSize(10)
        .lineHeight(13)
        .fontWeight(FontWeight.Regular)
        .fontColor(active ? '#' : $r('sys.color.ohos_id_color_text_secondary'))
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
    .height(52)
    .alignSelf(ItemAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceAround,
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
                    Text($r('app.string.login_for_enjoy_service'))
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
                this.jumpToLoginPage();
              })
            }
            .width('100%')
            .padding({
              top: 12,
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
              })
              .width('100%')
            }
            .padding({
              left: 16,
              right: 16
            })
            .width('100%')
            .layoutWeight(1)
          }
          .layoutWeight(1)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

          this.NavBar()
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onBackPressed(() => {
      // Directly exit the app after a gesture is performed.
      hilog.info(domainId, logTag, 'PrepareLoginPage onBackPressed');
      try {
        (this.getUIContext().getHostContext() as common.UIAbilityContext).terminateSelf();
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to terminateSelf. errCode: ${error.code}, errMessage: ${error.message}`);
      }
      return true;
    })
  }
}

@Builder
function Card(cardHeight: number) {
  Row()
    .margin({ bottom: 12 })
    .padding({ left: 16, right: 16 })
    .height(cardHeight)
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .borderRadius(20)
    .width('100%')
}
