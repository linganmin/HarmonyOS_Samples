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

import { SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { NotesData } from '../viewmodel/NotesData';
import { SideBarContentView } from '../view/SideBarContentView';
import { NotesPageC } from '../view/NotesPageC';

@Component
struct Item {
  @StorageLink('secondBreakPoint') breakPoint: string = '';
  @StorageLink('notesPageInfos') notesPageInfos: NavPathStack = new NavPathStack();
  @StorageLink('listItemSelect') listItemSelect: string = CommonConstants.NOTES_SCHEDULE[0][0].title;
  listDate: Array<NotesData> = [];

  build() {
    Column() {
      ForEach(this.listDate, (item: NotesData) => {
        Row() {
          Column() {
            Row()
              .width($r('app.float.notes_list_icon'))
              .height($r('app.float.position_x'))
              .backgroundColor(item.color)
              .margin({ top: $r('app.float.common_line_height') })
          }
          .width($r('app.float.width_or_margin'))
          .margin({
            left: $r('app.float.width_or_margin'),
            right: $r('app.float.notes_c_margin')
          })
          .height(CommonConstants.FULL_PERCENT)

          Column() {
            Row() {
              Text(item.title)
                .fontSize($r('app.float.common_font_size'))
                .lineHeight($r('app.float.common_height_line_height'))
                .fontWeight(FontWeight.Medium)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.common_height_line_height'))
            .margin({
              top: $r('app.float.position_x'),
              bottom: $r('app.float.common_margin_width')
            })

            Row() {
              Text(item.time)
                .fontSize($r('app.float.font_size_common'))
                .lineHeight($r('app.float.common_line_height'))
                .fontWeight(FontWeight.Regular)
              SymbolGlyph(item.iconSrc)
                .fontSize($r('app.float.common_font_size'))
                .margin($r('app.float.common_margin_width'))
              Text(item.descriptions)
                .fontSize($r('app.float.font_size_common'))
                .lineHeight($r('app.float.common_line_height'))
                .fontWeight(FontWeight.Regular)
                .width(this.breakPoint === CommonConstants.BREAK_POINT_MD ? (item.imageSrc ?
                $r('app.float.notes_descriptions_md') : $r('app.float.width_descriptions')) :
                $r('app.float.width_descriptions'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
          }
          .width(this.breakPoint === CommonConstants.BREAK_POINT_MD ? $r('app.float.notes_list_content_md_width') :
          $r('app.float.width_note_list'))
          .height(CommonConstants.FULL_PERCENT)

          Column() {
            Image(item.imageSrc)
              .width($r('app.float.notes_list_image'))
              .height($r('app.float.notes_list_image'))
              .borderRadius($r('app.float.day_button_radius'))
              .margin({ top: $r('app.float.margin_common') })
          }
          .width($r('app.float.notes_list_image'))
          .height(CommonConstants.FULL_PERCENT)
          .margin({ left: CommonConstants.COMMON_MARGIN })
        }
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius($r('app.float.border_radius_common'))
        .margin({ bottom: $r('app.float.margin_top') })
        .width(this.breakPoint === CommonConstants.BREAK_POINT_MD ? $r('app.float.notes_list_md_width') :
        $r('app.float.navigation_width'))
        .height($r('app.float.notes_list_height'))
        .onClick(() => {
          if (this.listItemSelect !== item.title || this.breakPoint === CommonConstants.BREAK_POINT_SM) {
            this.notesPageInfos.replacePath({ name: item.title }, false);
          }
          this.listItemSelect = item.title;
        })
      }, (item: NotesData) => JSON.stringify(item))
    }
  }
}

@Entry
@Component
struct NotesPage {
  @StorageLink('secondBreakPoint') breakPoint: string = '';
  @StorageLink('deviceType') deviceType: string = '';
  @StorageLink('notesNavMode') notesNavMode: NavigationMode = NavigationMode.Split;
  @StorageLink('arrowStatus') arrowStatus: boolean = true;
  @StorageLink('sideBarIsShown') sideBarIsShown: boolean = true;
  @StorageLink('sideBarStatus') sideBarStatus: boolean = this.deviceType === '2in1' ? true : false;
  @StorageLink('secondWindowSizeHeight') windowSizeHeight: number = CommonConstants.COMMON_ZERO;
  @StorageLink('notesPageInfos') notesPageInfos: NavPathStack = new NavPathStack();
  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [{ text: $r('app.string.memo') }, { text: $r('app.string.need_to_do') }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: $r('app.float.font_size_common'),
    fontWeight: FontWeight.Medium,
    fontColor: $r('sys.color.font_secondary'),
    selectedFontColor: $r('app.color.notes_sidebar_color'),
    selectedBackgroundColor: $r('app.color.start_window_background'),
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK
  });
  @State singleSelectCapsuleSelectedIndexes: number[] = [0];

  @Builder
  pageMap(name: string) {
    NavDestination() {
      NotesPageC({ itemsTitle: name })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.notesNavMode === NavigationMode.Split) {
        this.sideBarIsShown = true;
        return false;
      } else {
        if (this.breakPoint === CommonConstants.BREAK_POINT_SM) {
          this.notesPageInfos.pop();
        } else {
          this.notesNavMode = NavigationMode.Split;
          this.arrowStatus = true;
        }
        this.sideBarIsShown = true;
        if (this.breakPoint === CommonConstants.BREAK_POINT_LG) {
          this.sideBarStatus = true;
        }
        return true;
      }
    })
  }

  aboutToAppear(): void {
    if (this.breakPoint !== CommonConstants.BREAK_POINT_SM) {
      this.notesPageInfos.pushPath(({ name: CommonConstants.NOTES_SCHEDULE[0][0].title }));
    }
  }

  build() {
    if (this.sideBarIsShown) {
      // [Start side_bar_container]
      SideBarContainer(this.breakPoint === CommonConstants.BREAK_POINT_LG ? SideBarContainerType.Embed :
      SideBarContainerType.Overlay) {
        // [StartExclude side_bar_container]
        SideBarContentView()

        Stack() {
          if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
            Column()
              .height(CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
              .backgroundColor($r('app.color.sidebar_stack'))
              .zIndex(1)
              .visibility(this.sideBarStatus ? Visibility.Visible : Visibility.Hidden)
          }
          // [Start change_navigation_mode]
          Navigation(this.notesPageInfos) {
            // [StartExclude change_navigation_mode]
            Column() {
              if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
                Row() {
                  Column() {
                    SegmentButton({
                      options: this.singleSelectCapsuleOptions,
                      selectedIndexes: $singleSelectCapsuleSelectedIndexes
                    })
                  }
                  .justifyContent(FlexAlign.Center)
                  .margin({
                    left: this.breakPoint === CommonConstants.BREAK_POINT_MD ?
                    $r('app.float.notes_descriptions_md') : $r('app.float.segment_button_margin')
                  })
                  .width($r('app.float.segment_button_width'))
                  .height($r('app.float.image_size'))

                  Column() {
                    Image($r('app.media.more'))
                      .width($r('app.float.button_image_size'))
                      .height($r('app.float.button_image_size'))
                      .margin($r('app.float.margin_common'))
                  }
                  .width($r('app.float.image_size'))
                  .height($r('app.float.image_size'))
                  .borderRadius($r('app.float.border_radius_common'))
                  .backgroundColor($r('app.color.background_gray'))
                  .margin({ right: CommonConstants.COMMON_MARGIN })
                }
                .margin({ top: $r('app.float.margin_top') })
                .justifyContent(FlexAlign.SpaceBetween)
                .width(CommonConstants.FULL_PERCENT)
              } else {
                Row() {
                  Column() {
                    SymbolGlyph($r('sys.symbol.plus'))
                      .fontSize($r('app.float.symbol_font_size'))
                      .margin($r('app.float.margin_common'))
                  }
                  .width($r('app.float.image_size'))
                  .height($r('app.float.image_size'))
                  .borderRadius($r('app.float.border_radius_common'))
                  .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                  $r('app.color.background_gray'))
                  .margin({ right: $r('app.float.margin_common') })

                  Column() {
                    SymbolGlyph($r('sys.symbol.square_grid_2x2'))
                      .fontSize($r('app.float.symbol_font_size'))
                      .margin($r('app.float.margin_common'))
                  }
                  .width($r('app.float.image_size'))
                  .height($r('app.float.image_size'))
                  .borderRadius($r('app.float.border_radius_common'))
                  .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                  $r('app.color.background_gray'))
                  .margin({ right: $r('app.float.margin_common') })

                  Column() {
                    SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                      .fontSize($r('app.float.symbol_font_size'))
                      .margin($r('app.float.margin_common'))
                  }
                  .width($r('app.float.image_size'))
                  .height($r('app.float.image_size'))
                  .borderRadius($r('app.float.border_radius_common'))
                  .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                  $r('app.color.background_gray'))
                  .margin({ right: CommonConstants.COMMON_MARGIN })
                }
                .margin({
                  top: $r('app.float.margin_top'),
                  bottom: $r('app.float.margin_top')
                })
                .justifyContent(FlexAlign.End)
                .width(CommonConstants.FULL_PERCENT)
              }

              if (this.deviceType !== CommonConstants.DEVICE_TYPE_2IN1) {
                Column() {
                  Text(CommonConstants.NOTES_LIST[0])
                    .fontSize($r('app.float.font_size_title'))
                    .lineHeight($r('app.float.title_line_height'))
                    .fontWeight(FontWeight.Bold)
                    .width(CommonConstants.FULL_PERCENT)
                    .margin({ top: CommonConstants.COMMON_MARGIN })
                  Text(CommonConstants.NOTES_LIST[1])
                    .fontSize($r('app.float.font_size_common'))
                    .width(CommonConstants.FULL_PERCENT)
                    .fontWeight(FontWeight.Regular)
                    .lineHeight($r('app.float.common_line_height'))
                    .margin({ top: $r('app.float.common_margin_width') })
                }
                .width(CommonConstants.FULL_PERCENT)
                .margin({ left: CommonConstants.COMMON_MARGIN })
              }

              Search({ value: '', placeholder: CommonConstants.NOTES_LIST[2] })
                .placeholderColor($r('app.color.search_color'))
                .placeholderFont({
                  size: $r('app.float.common_font_size'),
                  weight: FontWeight.Regular
                })
                .textFont({
                  size: $r('app.float.common_font_size'),
                  weight: FontWeight.Regular
                })
                .backgroundColor($r('app.color.background_gray'))
                .width(this.breakPoint === CommonConstants.BREAK_POINT_MD ? $r('app.float.notes_list_md_width') :
                $r('app.float.navigation_width'))
                .height($r('app.float.title_line_height'))
                .margin({
                  top: $r('app.float.margin_common_top'),
                  left: CommonConstants.COMMON_MARGIN,
                  right: CommonConstants.COMMON_MARGIN
                })

              Scroll() {
                Column() {
                  Row() {
                    Text(CommonConstants.NOTES_LIST[3])
                      .fontSize($r('app.float.sub_title_font'))
                      .lineHeight($r('app.float.sub_title_line_height'))
                      .width(CommonConstants.FULL_PERCENT)
                      .fontWeight(FontWeight.Bold)
                  }
                  .width(CommonConstants.FULL_PERCENT)
                  .margin({
                    top: $r('app.float.line_height_or_top'),
                    left: CommonConstants.COMMON_MARGIN,
                    bottom: $r('app.float.margin_common')
                  })

                  Item({ listDate: CommonConstants.NOTES_SCHEDULE[CommonConstants.COMMON_ZERO] })

                  Row() {
                    Text(CommonConstants.NOTES_LIST[4])
                      .fontSize($r('app.float.sub_title_font'))
                      .lineHeight($r('app.float.sub_title_line_height'))
                      .width(CommonConstants.FULL_PERCENT)
                      .fontWeight(FontWeight.Bold)
                  }
                  .width(CommonConstants.FULL_PERCENT)
                  .margin({
                    top: $r('app.float.margin_top'),
                    left: CommonConstants.COMMON_MARGIN,
                    bottom: $r('app.float.margin_common')
                  })

                  Item({ listDate: CommonConstants.NOTES_SCHEDULE[1] })
                }
                .height($r('app.float.sub_scroll_height'))
              }
              .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? this.windowSizeHeight -
              CommonConstants.NOTES_TITLE_2IN1 : this.windowSizeHeight - CommonConstants.NOTES_TITLE_HEIGHT)
              .align(Alignment.Top)
              .scrollBar(BarState.Off)
            }
            .padding({
              top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_ZERO :
              $r('app.float.navigation_margin_top')
            })
            .justifyContent(FlexAlign.Start)
            .height(CommonConstants.FULL_PERCENT)
            .width(CommonConstants.FULL_PERCENT)

            // [EndExclude change_navigation_mode]
          }
          .navDestination(this.pageMap)
          .mode(this.breakPoint === CommonConstants.BREAK_POINT_SM ? NavigationMode.Stack : this.notesNavMode)
          // [End change_navigation_mode]
          .backgroundColor($r('app.color.window_background'))
          .navBarWidth(this.breakPoint === CommonConstants.BREAK_POINT_MD ? $r('app.float.notes_nav_md_width') :
          $r('app.float.notes_nav_bar_width'))
          .hideTitleBar(true)
          .onNavBarStateChange((isVisible: boolean) => {
            this.sideBarIsShown = isVisible;
          })
        }

        // [EndExclude side_bar_container]
      }
      // [End side_bar_container]
      .controlButton({
        icons: {
          hidden: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.close_sidebar') :
          $r('app.media.close_sidebar_bg'),
          shown: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.open_sidebar') :
          $r('app.media.open_sidebar_bg'),
          switching: this.sideBarStatus ?
            (CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.open_sidebar') : $r('app.media.open_sidebar_bg')) :
            (CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.close_sidebar') : $r('app.media.close_sidebar_bg'))
        },
        top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.CONTROL_NOTES_BUTTON_TOP :
        CommonConstants.CONTROL_BUTTON_TOP,
        left: (this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 && this.sideBarStatus) ?
        CommonConstants.CONTROL_BUTTON_LEFT : CommonConstants.COMMON_MARGIN,
        width: CommonConstants.CONTROL_BUTTON,
        height: CommonConstants.CONTROL_BUTTON
      })
      // [Start set_show_side_bar]
      .showSideBar(this.breakPoint === CommonConstants.BREAK_POINT_LG ? this.arrowStatus : false)
      // [End set_show_side_bar]
      .sideBarWidth(this.breakPoint === CommonConstants.BREAK_POINT_LG ? CommonConstants.SIDEBAR_WIDTH :
      CommonConstants.NOTES_SIDEBAR_WIDTH)
      .onChange((value: boolean) => {
        this.sideBarStatus = value;
      })
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
    } else {
      Stack() {
        if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
          Column()
            .height(CommonConstants.FULL_PERCENT)
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('app.color.sidebar_stack'))
            .zIndex(1)
            .visibility(this.sideBarStatus ? Visibility.Visible : Visibility.Hidden)
        }

        // [Start navigation_mode_change]
        Navigation(this.notesPageInfos) {
          // [StartExclude navigation_mode_change]
          Column() {
            if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
              Row() {
                Column() {
                  SegmentButton({
                    options: this.singleSelectCapsuleOptions,
                    selectedIndexes: $singleSelectCapsuleSelectedIndexes
                  })
                }
                .justifyContent(FlexAlign.Center)
                .margin({ left: $r('app.float.segment_button_margin') })
                .width($r('app.float.segment_button_width'))
                .height($r('app.float.image_size'))

                Column() {
                  Image($r('app.media.more'))
                    .width($r('app.float.button_image_size'))
                    .height($r('app.float.button_image_size'))
                    .margin($r('app.float.margin_common'))
                }
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .borderRadius($r('app.float.border_radius_common'))
                .backgroundColor($r('app.color.background_gray'))
                .margin({ right: CommonConstants.COMMON_MARGIN })
              }
              .margin({ top: $r('app.float.margin_top') })
              .justifyContent(FlexAlign.SpaceBetween)
              .width(CommonConstants.FULL_PERCENT)
            } else {
              Row() {
                Column() {
                  SymbolGlyph($r('sys.symbol.plus'))
                    .fontSize($r('app.float.symbol_font_size'))
                    .margin($r('app.float.margin_common'))
                }
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .borderRadius($r('app.float.border_radius_common'))
                .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                $r('app.color.background_gray'))
                .margin({ right: $r('app.float.margin_common') })

                Column() {
                  SymbolGlyph($r('sys.symbol.square_grid_2x2'))
                    .fontSize($r('app.float.symbol_font_size'))
                    .margin($r('app.float.margin_common'))
                }
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .borderRadius($r('app.float.border_radius_common'))
                .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                $r('app.color.background_gray'))
                .margin({ right: $r('app.float.margin_common') })

                Column() {
                  SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                    .fontSize($r('app.float.symbol_font_size'))
                    .margin($r('app.float.margin_common'))
                }
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .borderRadius($r('app.float.border_radius_common'))
                .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
                $r('app.color.background_gray'))
                .margin({ right: CommonConstants.COMMON_MARGIN })
              }
              .margin({ top: $r('app.float.margin_top'), bottom: $r('app.float.margin_top') })
              .justifyContent(FlexAlign.End)
              .width(CommonConstants.FULL_PERCENT)
            }

            if (this.deviceType !== CommonConstants.DEVICE_TYPE_2IN1) {
              Column() {
                Text(CommonConstants.NOTES_LIST[0])
                  .fontSize($r('app.float.font_size_title'))
                  .lineHeight($r('app.float.title_line_height'))
                  .fontWeight(FontWeight.Bold)
                  .width(CommonConstants.FULL_PERCENT)
                  .margin({ top: CommonConstants.COMMON_MARGIN })
                Text(CommonConstants.NOTES_LIST[1])
                  .fontSize($r('app.float.font_size_common'))
                  .width(CommonConstants.FULL_PERCENT)
                  .fontWeight(FontWeight.Regular)
                  .lineHeight($r('app.float.common_line_height'))
                  .margin({ top: $r('app.float.common_margin_width') })
              }
              .width(CommonConstants.FULL_PERCENT)
              .margin({ left: CommonConstants.COMMON_MARGIN })
            }

            Search({ value: '', placeholder: CommonConstants.NOTES_LIST[2] })
              .placeholderColor($r('app.color.search_color'))
              .placeholderFont({
                size: $r('app.float.common_font_size'),
                weight: FontWeight.Regular
              })
              .textFont({
                size: $r('app.float.common_font_size'),
                weight: FontWeight.Regular
              })
              .backgroundColor($r('app.color.background_gray'))
              .width($r('app.float.navigation_width'))
              .height($r('app.float.title_line_height'))
              .margin({
                top: $r('app.float.margin_common_top'),
                left: CommonConstants.COMMON_MARGIN,
                right: CommonConstants.COMMON_MARGIN
              })

            Scroll() {
              Column() {
                Row() {
                  Text(CommonConstants.NOTES_LIST[3])
                    .fontSize($r('app.float.sub_title_font'))
                    .lineHeight($r('app.float.sub_title_line_height'))
                    .width(CommonConstants.FULL_PERCENT)
                    .fontWeight(FontWeight.Bold)
                }
                .width(CommonConstants.FULL_PERCENT)
                .margin({
                  top: $r('app.float.line_height_or_top'),
                  left: CommonConstants.COMMON_MARGIN,
                  bottom: $r('app.float.margin_common')
                })

                Item({ listDate: CommonConstants.NOTES_SCHEDULE[CommonConstants.COMMON_ZERO] })

                Row() {
                  Text(CommonConstants.NOTES_LIST[4])
                    .fontSize($r('app.float.sub_title_font'))
                    .lineHeight($r('app.float.sub_title_line_height'))
                    .width(CommonConstants.FULL_PERCENT)
                    .fontWeight(FontWeight.Bold)
                }
                .width(CommonConstants.FULL_PERCENT)
                .margin({
                  top: $r('app.float.margin_top'),
                  left: CommonConstants.COMMON_MARGIN,
                  bottom: $r('app.float.margin_common')
                })

                Item({ listDate: CommonConstants.NOTES_SCHEDULE[1] })
              }
              .height($r('app.float.sub_scroll_height'))
            }
            .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? this.windowSizeHeight -
            CommonConstants.NOTES_TITLE_2IN1 : this.windowSizeHeight - CommonConstants.NOTES_TITLE_HEIGHT)
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
          }
          .padding({
            top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_ZERO :
            $r('app.float.navigation_margin_top')
          })
          .justifyContent(FlexAlign.Start)
          .height(CommonConstants.FULL_PERCENT)
          .width(CommonConstants.FULL_PERCENT)

          // [EndExclude navigation_mode_change]
        }
        .mode(this.breakPoint === CommonConstants.BREAK_POINT_SM ? NavigationMode.Stack : this.notesNavMode)
        // [End navigation_mode_change]
        .navDestination(this.pageMap)
        .backgroundColor($r('app.color.window_background'))
        .navBarWidth($r('app.float.notes_nav_bar_width'))
        .hideTitleBar(true)
      }
    }
  }
}