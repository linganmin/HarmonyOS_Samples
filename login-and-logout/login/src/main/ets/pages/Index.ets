/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { Logout } from './Logout';
import { Login } from './Login';
import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @StorageLink('isModalLogin') loginStatus: boolean = false;
  @State currentIndex: number = CommonConstants.CURRENT_INDEX;
  @State isLg: boolean = false;
  @State center: boolean = false;
  @Provide isShowSheet: boolean = false;
  @Provide isLoginShowSheet: boolean = false;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    if (this.curBp === 'lg') {
      this.isLg = true;
    }
    if (this.curBp === 'lg' || this.curBp === 'md') {
      console.log('testtest',this.curBp)
      this.center = true;
    }
    this.controller.changeIndex(CommonConstants.IMAGE_LIST.length - 1);
  }

  @Builder
  mySheet() {
    Column() {
      Row() {
        Text($r('app.string.sheet_settings'))
          .fontSize($r('app.float.mySheet_title_text_font_size'))
          .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
      }
      .width(CommonConstants.FULL_SCREEN)
      .height($r('app.float.mySheet_row_height'))

      Column() {
        Column() {
          Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
            Text($r('app.string.apply_network_settings'))
              .fontSize($r('app.float.mySheet_text_font_size'))
            Image($r('app.media.arrow_right'))
              .width($r('app.float.symbol_width'))
              .height($r('app.float.symbol_height'))
          }
          .width(CommonConstants.FULL_SCREEN)
          .height($r('app.float.mySheet_row_height'))
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .padding($r('app.float.mySheet_row_padding'))
          .margin({ top: $r('app.float.grid_row_margin') })

          Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
            Text($r('app.string.message_notification'))
              .fontSize($r('app.float.mySheet_text_font_size'))
            Image($r('app.media.arrow_right'))
              .width($r('app.float.symbol_width'))
              .height($r('app.float.symbol_height'))
          }
          .width(CommonConstants.FULL_SCREEN)
          .height($r('app.float.mySheet_row_height'))
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .padding($r('app.float.mySheet_row_padding'))
          .margin({ top: $r('app.float.grid_row_margin') })
        }
        .height($r('app.float.mySheet_column_height'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.mySheet_column_borderRadius'))

        Logout()
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_SCREEN)
      .height(this.curBp === 'sm' ? CommonConstants.NINETY_SCREEN : $r('app.float.mySheet_column_wrap_height'))
      .margin({ bottom: $r('app.float.mySheet_margin_bottom') })
    }
    .width(CommonConstants.FULL_SCREEN)
    .height(CommonConstants.FULL_SCREEN)
    .backgroundColor($r('app.color.login_page_background'))
    .padding($r('app.float.padding'))
  }

  @Builder
  LoginSheet() {
    Column() {
      Login()
    }
  }

  @Builder
  tabBuilder(title: ResourceStr, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column({ space: CommonConstants.TAB_BUILDER_COLUMN_SPACE }) {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: $r('app.float.tabBuilder_image_width'), height: $r('app.float.tabBuilder_image_height') })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.text_selected_color') :
        $r('app.color.text_normal_color'))
        .fontSize($r('app.float.tabBuilder_font_size'))
    }
    .width(CommonConstants.FULL_SCREEN)
    .height($r('app.float.tabBuilder_column_height'))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = 3;
      this.controller.changeIndex(this.currentIndex);
    })
  }

  build() {
    Navigation() {
      Column() {
        Tabs({
          barPosition: this.isLg ? BarPosition.Start : BarPosition.End,
          controller: this.controller,
          index: 3
        }) {
          TabContent() {
            Column()
          }
          .tabBar(this.tabBuilder($r('app.string.tab'), 0, $r('app.media.user_active'),
            $r('app.media.user_not_active')))

          TabContent() {
            Column()
          }
          .tabBar(this.tabBuilder($r('app.string.tab'), 1, $r('app.media.user_active'),
            $r('app.media.user_not_active')))

          TabContent() {
            Column()
          }
          .tabBar(this.tabBuilder($r('app.string.tab'), 2, $r('app.media.user_active'),
            $r('app.media.user_not_active')))

          TabContent() {
            Column() {
              Row() {
                Text($r('app.string.mine'))
                  .fontSize($r('app.float.tabContent_text_font_size'))
                  .fontWeight(CommonConstants.TITLE_FONT_WEIGHT)
                Row() {
                  Image($r('app.media.email'))
                    .width($r('app.float.tabContent_image_width'))
                    .height($r('app.float.tabContent_image_height'))
                }
                .width($r('app.float.tabContent_row_width'))
                .height($r('app.float.tabContent_row_height'))
                .borderRadius($r('app.float.tabContent_row_borderRadius'))
                .justifyContent(FlexAlign.Center)
                .backgroundColor($r('app.color.tabContent_row_background'))
              }
              .width(CommonConstants.FULL_SCREEN)
              .height($r('app.float.tabContent_row_wrap_height'))
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)

              GridRow({
                columns: {
                  sm: CommonConstants.COLUMN_SM,
                  md: CommonConstants.COLUMN_MD,
                  lg: CommonConstants.COLUMN_LG
                },
                gutter: {
                  x: { sm: CommonConstants.OFFSET_SM, md: CommonConstants.OFFSET_MD, lg: CommonConstants.OFFSET_LG },
                  y: { sm: CommonConstants.OFFSET_SM, md: CommonConstants.OFFSET_MD, lg: CommonConstants.OFFSET_LG }
                }
              }) {
                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                    Image(this.loginStatus ? $r('app.media.user_name') : $r('app.media.user_none'))
                      .width($r('app.float.grid_image_width'))
                      .height($r('app.float.grid_image_height'))
                    Text(this.loginStatus ? $r('app.string.username') : $r('app.string.login_account'))
                      .fontSize($r('app.float.grid_row_font_size'))
                  }
                  .alignItems(VerticalAlign.Center)
                  .backgroundColor(Color.White)
                  .borderRadius($r('app.float.grid_row_borderRadius'))
                  .height(this.curBp === 'sm' ? $r('app.float.grid_row_sm_height') : $r('app.float.grid_row_md_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .onClick(() => {
                    if (!this.loginStatus) {
                      this.isLoginShowSheet = true;
                    }
                  })
                  .bindSheet(this.isLoginShowSheet, this.LoginSheet(), {
                    height: this.center ? $r('app.float.bindSheet_height_Login') : $r('app.float.bindSheet_height'),
                    dragBar: false,
                    preferType: this.center ? SheetType.CENTER : SheetType.BOTTOM,
                    onDisappear: () => {
                      this.isLoginShowSheet = false;
                    }
                  })
                }

                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    ForEach(CommonConstants.IMAGE_LIST, (item: number) => {
                      Column({ space: CommonConstants.GRID_COLUMN_SPACE }) {
                        Image($r('app.media.collection'))
                          .width($r('app.float.collection_image_height'))
                          .height($r('app.float.collection_image_height'))
                        Text($r('app.string.collection_text_top'))
                          .fontSize($r('app.float.grid_tow_row_font_size_12'))
                          .fontWeight(CommonConstants.LIST_TITLE_FONT_WEIGHT)
                        Text($r('app.string.collection_text_bottom'))
                          .fontSize($r('app.float.grid_tow_row_font_size_8'))
                      }
                      .height($r('app.float.grid_tow_column_height'))
                      .width(CommonConstants.TWENTY_FIVE_SCREEN)
                    }, (item: number) => item.toString())
                  }
                  .backgroundColor(Color.White)
                  .borderRadius($r('app.float.grid_row_borderRadius'))
                  .height(this.curBp === 'sm' ? $r('app.float.grid_tow_row_sm_height') :
                  $r('app.float.grid_tow_row_md_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .margin({ top: this.curBp === 'sm' ? $r('app.float.grid_row_margin') : 0 })
                }
              }
              .margin({ bottom: $r('app.float.grid_margin_bottom') })

              GridRow({
                columns: {
                  sm: CommonConstants.COLUMN_SM,
                  md: CommonConstants.COLUMN_MD,
                  lg: CommonConstants.COLUMN_LG
                }
              }) {
                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                      Image($r('app.media.asset'))
                        .width($r('app.float.grid_tow_image_width'))
                        .height($r('app.float.grid_tow_image_height'))
                      Text($r('app.string.my_assets'))
                        .fontSize($r('app.float.grid_there_row_font_size'))
                    }

                    Row() {
                      Image($r('app.media.arrow_right'))
                        .width($r('app.float.symbol_width'))
                        .height($r('app.float.symbol_height'))
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .height($r('app.float.grid_there_row_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .margin({ top: $r('app.float.grid_row_margin') })
                }

                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                      Image($r('app.media.swap_coupon'))
                        .width($r('app.float.grid_tow_image_width'))
                        .height($r('app.float.grid_tow_image_height'))
                      Text($r('app.string.equity_redemption'))
                        .fontSize($r('app.float.grid_there_row_font_size'))
                    }

                    Row() {
                      Image($r('app.media.arrow_right'))
                        .width($r('app.float.symbol_width'))
                        .height($r('app.float.symbol_height'))
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .height($r('app.float.grid_there_row_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .margin({ top: $r('app.float.grid_row_margin') })
                }

                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                      Image($r('app.media.record'))
                        .width($r('app.float.grid_tow_image_width'))
                        .height($r('app.float.grid_tow_image_height'))
                      Text($r('app.string.consumption_record'))
                        .fontSize($r('app.float.grid_there_row_font_size'))
                    }

                    Row() {
                      Image($r('app.media.arrow_right'))
                        .width($r('app.float.symbol_width'))
                        .height($r('app.float.symbol_height'))
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .height($r('app.float.grid_there_row_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .margin({ top: $r('app.float.grid_row_margin') })
                }
              }
              .backgroundColor(Color.White)
              .borderRadius($r('app.float.grid_row_borderRadius'))
              .height(this.curBp === 'sm' ? $r('app.float.grid_there_row_sm_height') :
              $r('app.float.grid_there_row_md_height'))
              .width(CommonConstants.FULL_SCREEN)
              .margin({ bottom: $r('app.float.grid_margin_bottom') })

              GridRow({
                columns: {
                  sm: CommonConstants.COLUMN_SM,
                  md: CommonConstants.COLUMN_MD,
                  lg: CommonConstants.COLUMN_LG
                }
              }) {
                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                      Image($r('app.media.settings'))
                        .width($r('app.float.grid_tow_image_width'))
                        .height($r('app.float.grid_tow_image_height'))
                      Text($r('app.string.settings'))
                        .fontSize($r('app.float.grid_there_row_font_size'))
                    }

                    Row() {
                      Image($r('app.media.arrow_right'))
                        .width($r('app.float.symbol_width'))
                        .height($r('app.float.symbol_height'))
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .height($r('app.float.grid_there_row_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .onClick(() => {
                    if (this.loginStatus) {
                      this.isShowSheet = !this.isShowSheet;
                    }
                  })
                  .bindSheet(this.isShowSheet, this.mySheet(), {
                    height: this.center ? $r('app.float.bindSheet_height_widescreen') :
                    $r('app.float.bindSheet_height'),
                    dragBar: false,
                    preferType: this.center ? SheetType.CENTER : SheetType.BOTTOM,
                    onDisappear: () => {
                      this.isShowSheet = false;
                    }
                  })
                }

                GridCol({
                  span: {
                    sm: CommonConstants.SPAN_SM,
                    md: CommonConstants.SPAN_MD,
                    lg: CommonConstants.SPAN_LG
                  }
                }) {
                  Row() {
                    Row({ space: CommonConstants.SHEET_ROW_SPACE }) {
                      Image($r('app.media.help'))
                        .width($r('app.float.grid_tow_image_width'))
                        .height($r('app.float.grid_tow_image_height'))
                      Text($r('app.string.help_and_customer_service'))
                        .fontSize($r('app.float.grid_there_row_font_size'))
                    }

                    Row() {
                      Image($r('app.media.arrow_right'))
                        .width($r('app.float.symbol_width'))
                        .height($r('app.float.symbol_height'))
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .height($r('app.float.grid_there_row_height'))
                  .width(CommonConstants.FULL_SCREEN)
                  .padding($r('app.float.grid_row_padding'))
                  .margin({ top: $r('app.float.grid_row_margin') })
                }
              }
              .backgroundColor(Color.White)
              .borderRadius($r('app.float.grid_row_borderRadius'))
              .height(this.curBp === 'sm' ? $r('app.float.grid_four_row_sm_height') :
              $r('app.float.grid_four_row_md_height'))
              .width(CommonConstants.FULL_SCREEN)
              .margin({ bottom: $r('app.float.grid_margin_bottom') })
            }
            .height(CommonConstants.FULL_SCREEN)
            .justifyContent(FlexAlign.Start)
          }
          .tabBar(this.tabBuilder($r('app.string.mine'), 3, $r('app.media.user_active'),
            $r('app.media.user_not_active')))
        }
        .scrollable(false)
        .vertical(this.isLg ? true : false)
        .barWidth(this.isLg ? $r('app.float.index_bar_width') : CommonConstants.FULL_SCREEN)
        .barHeight(this.isLg ? CommonConstants.FULL_SCREEN : $r('app.float.index_bar_height'))
        .height(CommonConstants.FULL_SCREEN)
        .width(CommonConstants.FULL_SCREEN)
        .backgroundColor($r('app.color.tabs_background'))
      }
      .backgroundColor($r('app.color.tabs_background'))
      .padding({
        left: $r('app.float.index_padding_left'),
        right: $r('app.float.index_padding_right'),
        top: $r('app.float.index_padding_top'),
        bottom: $r('app.float.index_padding_bottom')
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .height(CommonConstants.FULL_SCREEN)
    .width(CommonConstants.FULL_SCREEN)
  }
}