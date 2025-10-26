/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import { common } from '@kit.AbilityKit';
import { appPicker } from '@kit.ScreenTimeGuardKit';
import { guardService } from '@kit.ScreenTimeGuardKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TitleTextModifier } from '../utils/TextModifier';
import { ControlStrategyMode } from '../common/ControlStrategyMode';
import Utils from '../utils/Utils';
import { StrategyGuardApps } from '../guard/StrategyGuardApps';
import { Constants } from '../common/Constants';

@Entry
@Component
struct ParentControlHomePage {
  private logTag: string = 'ParentControlHomePage';
  private domainId: number = 0x0000;
  private scroller: Scroller = new Scroller();
  private textModifier: AttributeModifier<TextAttribute> =
    new TitleTextModifier(this.getUIContext().getHostContext() as common.UIAbilityContext);
  private strategyGuardApps: StrategyGuardApps = new StrategyGuardApps();
  private lastChangeStrategyModeTime: number = 0;
  @State private appTokens: string[] = [];
  @State isSelectedAppsInPicker: boolean = false;
  @State strategyMode: ControlStrategyMode = ControlStrategyMode.NO_CONTROL_RULE;
  @State isCancelControlApps: boolean = false;

  aboutToAppear(): void {
    this.strategyGuardApps.setGuardStrategyName(Constants.STRATEGY_NAME);
    if (Utils.isCallerParentControl() && this.strategyGuardApps.isStartControlApps()) {
      this.isCancelControlApps = true;
    }
  }

  onPageShow(): void {
    hilog.info(this.domainId, this.logTag, `onPageShow: ${Utils.getCallerBundleName()}`);
    if (Utils.isCallerParentControl() && this.strategyGuardApps.isStartControlApps()) {
      this.isCancelControlApps = true;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          Column() {
            Stack({ alignContent: Alignment.End }) {
              Scroll(this.scroller) {
                Flex({ direction: FlexDirection.Column }) {
                  this.setRestrictedAppsItem();
                  this.controlStrategyItem();
                  this.blankItem();
                  this.startButtonItem();
                }
              }
              .layoutWeight(1)
              .padding({
                left: $r('app.float.scroll_left_padding'),
                right: $r('app.float.scroll_right_padding'),
                bottom: $r('app.float.scroll_bottom_padding')
              })
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
              .width(Constants.MATCH_PARENT)
              .height(Constants.MATCH_PARENT)
              .align(Alignment.Top)
            }
            .layoutWeight(1)
          }
          .width(Constants.MATCH_PARENT)
          .height(Constants.MATCH_PARENT)
        }
        .width(Constants.MATCH_PARENT)
        .height(Constants.MATCH_PARENT)
      }
      .width(Constants.MATCH_PARENT)
      .height(Constants.MATCH_PARENT)
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding({ top: $r('app.float.nav_top_margin'), bottom: $r('app.float.nav_bottom_margin') })
    .mode(NavDestinationMode.STANDARD)
    .title(this.homepageNavigationTitle(), { backgroundColor: $r('sys.color.ohos_id_color_sub_background')
    })
  }

  @Builder
  homepageNavigationTitle() {
    Row() {
      Text($r('app.string.parent_control_demo'))
        .attributeModifier(this.textModifier)
        .margin({
          left: $r('app.float.page_title_left_margin'),
          top: $r('app.float.page_title_top_margin'),
          bottom: $r('app.float.page_title_bottom_margin')
        })
        .height('auto')
    }
    .alignItems(VerticalAlign.Center)
    .padding({ right: $r('app.float.page_title_right_padding') })
    .width(Constants.MATCH_PARENT)
    .height(Constants.MATCH_PARENT)
    .constraintSize({
      maxHeight: $r('app.float.list_item_height')
    })
    .layoutWeight(1)
  }

  @Builder
  blankItem() {
    Column() {
    }
    .layoutWeight(1)
  }

  @Builder
  setRestrictedAppsItem() {
    Column() {
      List() {
        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            SymbolGlyph($r('sys.symbol.square_grid_2x2_checkmark_topleft_filled'))
              .fontSize($r('app.float.symbol_font_size'))
              .fontColor([0x0A59F7])
              .backgroundColor(0x1A0A59F7)
              .borderRadius($r('sys.float.account_list_corner_radius'))
              .padding($r('sys.float.corner_radius_level3') )

            if (this.isSelectedAppsInPicker) {
              Column() {
                Text($r('app.string.app_restrict_title'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Bold)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.black'))

                Text(this.getRestrictedAppSubTitle())
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .opacity(0.4)
                  .fontColor($r('sys.color.black'))
                  .margin({ top: $r('app.float.text_margin_top') })
              }
              .margin({ left: $r('app.float.text_margin_left1') })
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            } else {
              Text($r('app.string.app_restrict_title'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                .fontWeight(FontWeight.Bold)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.black'))
                .margin({ left: $r('app.float.text_margin_left1') })
                .layoutWeight(1)
            }

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize($r('app.float.symbol_font_size'))
              .fontColor([$r('sys.color.icon_fourth')])
          }
          .alignItems(VerticalAlign.Center)
          .width(Constants.MATCH_PARENT)
          .onClick(() => {
            // Requests user authorization to call ScreenTimeGuard
            guardService.requestUserAuth(this.getUIContext().getHostContext() as common.UIAbilityContext).then(() => {
              appPicker.startAppPicker(this.getUIContext().getHostContext(), { appTokens: this.appTokens }).then((appTokens) => {
                this.appTokens = appTokens;
                this.isSelectedAppsInPicker = this.appTokens.length >= 1 ? true : false;
              }).catch((error: BusinessError) => {
                hilog.error(this.domainId, this.logTag,
                  `startAppPicker fail, errCode is ${error.code}, errMessage is ${error.message}`);
                Utils.dealAllError(error);
              })
            }).catch((error: BusinessError) => {
              hilog.error(this.domainId, this.logTag,
                `requestUserAuth fail, errCode is ${error.code}, errMessage is ${error.message}`);
            })
          })
        }
        .height($r('app.float.list_item_height'))
      }
      .padding($r('sys.float.menu_item_vertical_padding_token'))
      .borderRadius($r('sys.float.account_list_corner_radius'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .margin({ top: $r('app.float.list_item_margin_top') })
  }

  @Builder
  controlStrategyItem() {
    Column() {
      List() {
        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            SymbolGlyph($r('sys.symbol.exercise_records'))
              .fontSize($r('app.float.symbol_font_size'))
              .fontColor([0xFAA020])
              .backgroundColor(0x4DFFCDBD)
              .borderRadius($r('sys.float.account_list_corner_radius'))
              .padding($r('sys.float.corner_radius_level3'))

            Text($r('app.string.guard_strategy_title'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Bold)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.black'))
              .margin({ left: $r('app.float.text_margin_left1') })
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Center)
          .width(Constants.MATCH_PARENT)
        }

        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: this.strategyMode === ControlStrategyMode.EFFECTED_IMMEDIATELY })
              .padding($r('sys.float.corner_radius_level3'))
              .onChange((value: boolean) => {
                if (this.isSafeAssign()) {
                  this.strategyMode =
                    value ? ControlStrategyMode.EFFECTED_IMMEDIATELY : ControlStrategyMode.NO_CONTROL_RULE;
                }
              })

            Text($r('app.string.effective_immediately_title'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.black'))
              .alignSelf(ItemAlign.Center)
              .margin({ left: $r('app.float.text_margin_left2') })
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Center)
          .width(Constants.MATCH_PARENT)
        }

        ListItem({ style: ListItemStyle.CARD }) {
          Row() {
            Toggle({
              type: ToggleType.Checkbox,
              isOn: this.strategyMode === ControlStrategyMode.USER_DEFINED_CONTROL_RULE
            })
              .padding($r('sys.float.corner_radius_level3'))
              .onChange(async (value: boolean) => {
                if (this.isSafeAssign()) {
                  this.strategyMode =
                    value ? ControlStrategyMode.USER_DEFINED_CONTROL_RULE : ControlStrategyMode.NO_CONTROL_RULE;
                }

                this.strategyGuardApps.setTimeStrategy({
                  type: guardService.TimeStrategyType.START_END_TIME_TYPE,
                  startTime: Constants.GUARD_START_TIME,
                  endTime: Constants.GUARD_END_TIME,
                  repeat: Constants.REPEAT_DAILY
                });
              })

            Text(Constants.GUARD_PERIOD_TITLE)
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.black'))
              .alignSelf(ItemAlign.Center)
              .margin({ left: $r('app.float.text_margin_left2') })
              .layoutWeight(1)

            Text($r('app.string.strategy_repeat_title'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .opacity(0.4)
              .fontColor(0x000000)
              .alignSelf(ItemAlign.Center)
              .margin({ right: $r('app.float.text_margin_right') })

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize($r('app.float.symbol_font_size'))
              .fontColor([$r('sys.color.icon_fourth')])
          }
          .alignItems(VerticalAlign.Center)
          .width(Constants.MATCH_PARENT)
        }
      }
      .padding($r('sys.float.menu_item_vertical_padding_token'))
      .borderRadius($r('sys.float.account_list_corner_radius'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .divider({
        strokeWidth: $r('app.float.divider_stroke_width'),
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: $r('app.float.divider_start_margin'),
        endMargin: $r('app.float.divider_end_margin')
      })
    }
    .margin({ top:$r('app.float.list_item_margin_top') })
  }

  @Builder
  startButtonItem() {
    Column() {
      List() {
        ListItem() {
          Row() {
            Button({ type: ButtonType.Capsule }) {
              if (this.isCancelControlApps) {
                Text($r('app.string.delete_title'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(0xE84026)
                  .fontSize($r('sys.float.ohos_id_text_size_headline8'))
              } else {
                Text($r('app.string.start_title'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getStartButtonTitleColor())
                  .fontSize($r('sys.float.ohos_id_text_size_headline8'))
              }
            }
            .backgroundColor($r('sys.color.ohos_id_normalbtn_bg'))
            .height($r('app.float.button_height'))
            .layoutWeight(1)
            .onClick(() => {
              this.strategyGuardApps.setAppInfo({ appTokens: this.appTokens });
              if (this.isCancelControlApps) {
                this.strategyGuardApps.cancelControlApps();
                this.isCancelControlApps = false;
              } else {
                this.strategyGuardApps.controlApps(this.strategyMode);
              }
            })
          }
          .constraintSize({ minHeight: $r('sys.float.account_list_item_height') })
        }
      }
    }
    .margin({ top: $r('app.float.list_item_margin_top') })
  }

  private getStartButtonTitleColor(): ResourceColor {
    return this.strategyMode === ControlStrategyMode.NO_CONTROL_RULE ? 0x46B1E3 : 0x564AF7;
  }

  private getRestrictedAppSubTitle(): Resource {
    const restrictedAppsCnt = this.appTokens.length;
    return $r('app.string.selected_apps_desc', restrictedAppsCnt);
  }

  private isSafeAssign(): boolean {
    const now = Date.now();
    if (now - this.lastChangeStrategyModeTime >= Constants.SAFE_ASSIGN_TIME) {
      this.lastChangeStrategyModeTime = now;
      return true;
    }
    return false;
  }
}
