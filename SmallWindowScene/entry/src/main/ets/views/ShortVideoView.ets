/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../constants/CommonConstants';
import { SideIcon, SideIconViewModel } from '../viewmodels/SideIconViewModel';
import { ShareDialog } from './ShareDialog';

@Component
export struct ShortVideoView {
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 0;
  @StorageLink('bottomAvoidHeight') @Watch('bottomBarHeightChange') bottomAvoidHeight: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = WidthBreakpoint.WIDTH_SM;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = HeightBreakpoint.HEIGHT_SM;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @State currentBottomIndex: number = 0;
  @State currentTopIndex: number = 0;
  @State topBarHeight: number = CommonConstants.TOP_TAB_HEIGHT + this.topAvoidHeight;
  @State bottomBarHeight: number = CommonConstants.BOTTOM_TAB_HEIGHT + this.bottomAvoidHeight;
  private sideIconList: SideIcon[] = new SideIconViewModel().getSideIconList();
  private dialogController?: CustomDialogController;

  bottomBarHeightChange(): void {
    this.bottomBarHeight = CommonConstants.BOTTOM_TAB_HEIGHT + this.bottomAvoidHeight;
  };

  build() {
    NavDestination() {
      // [Start short_video]
      Stack({ alignContent: Alignment.BottomEnd }) {
        // Background image.
        Row() {
          Image($r('app.media.background_image'))
            .height('100%')
            .objectFit(ImageFit.Cover)
            .aspectRatio(0.6)
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // Bottom tabs.
        List() {
          // [StartExclude short_video]
          ForEach(CommonConstants.SHORT_VIDEO_TABS, (item: Resource, index: number) => {
            ListItem() {
              Column() {
                Text(item)
                  .fontSize($r('app.float.font_size_lg'))
                  .fontWeight(CommonConstants.FONT_WEIGHTS[0])
                  .fontColor(Color.White)
                  .margin({ top: $r('app.float.margin_sm') })
                  .opacity(index === this.currentBottomIndex ? 1 : CommonConstants.OPACITY)
              }
              .height(CommonConstants.HUNDRED_PERCENT)
              .width(CommonConstants.TWENTY_FIVE_PERCENT)
              .justifyContent(FlexAlign.Center)
            }
          }, (item: Resource, index: number) => JSON.stringify(item) + index)
          // [EndExclude short_video]
        }
        .backgroundColor($r('sys.color.mask_secondary'))
        .listDirection(Axis.Horizontal)
        .height(this.bottomBarHeight)
        .padding({ bottom: this.bottomAvoidHeight })
        // [StartExclude short_video]
        .width(CommonConstants.HUNDRED_PERCENT)
        .visibility(Visibility.Visible)

        // [EndExclude short_video]

        // Video description.
        Column() {
          // [StartExclude short_video]
          Row() {
            Text($r('app.string.video_title'))
              .fontSize($r('app.float.font_size_lg'))
              .fontColor(Color.White)
            Text($r('app.string.video_time'))
              .fontSize($r('app.float.font_size_lg'))
              .fontColor(Color.White)
              .opacity(CommonConstants.OPACITY)
          }
          .width(CommonConstants.HUNDRED_PERCENT)
          .margin({ bottom: $r('app.float.margin_md') })

          Text($r('app.string.video_content'))
            .fontSize($r('app.float.font_size_lg'))
            .fontColor(Color.White)
            .opacity(CommonConstants.OPACITY)
            .margin({ bottom: $r('app.float.margin_md') })
            .maxLines(2)

          Row() {
            Image($r('app.media.icon_music'))
              .height($r('app.float.image_size_xs'))
              .width($r('app.float.image_size_xs'))
              .margin({ right: $r('app.float.margin_sm') })
            Text($r('app.string.video_music'))
              .fontSize($r('app.float.font_size_lg'))
              .fontColor(Color.White)
              .opacity(CommonConstants.OPACITY)
          }
          .width(CommonConstants.HUNDRED_PERCENT)
          .margin({ bottom: $r('app.float.margin_lg') })

          // [EndExclude short_video]
        }
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: $r('app.float.margin_md'),
          right: $r('app.float.margin_md')
        })
        // [StartExclude short_video]
        .margin({
          right: '56vp',
          bottom: this.bottomBarHeight
        })

        // [EndExclude short_video]

        // Sidebar buttons.
        Scroll() {
          Column() {
            Blank()
              .layoutWeight(3)
              .displayPriority(1)
            // [StartExclude short_video]
            Image($r('app.media.user_profile'))
              .width($r('app.float.image_size_lg'))
              .height($r('app.float.image_size_lg'))
              .borderRadius($r('app.float.image_size_sm'))
              .margin({ bottom: $r('app.float.margin_lg') })
            List({ space: CommonConstants.LIST_SPACE[1] }) {
              ForEach(this.sideIconList, (item: SideIcon, index: number) => {
                ListItem() {
                  Column() {
                    Image(item.getIcon())
                      .width($r('app.float.image_size_md'))
                      .height($r('app.float.image_size_md'))
                    Text(JSON.stringify(item.getTotalNumber()))
                      .fontWeight(CommonConstants.FONT_WEIGHTS[0])
                      .fontSize($r('app.float.tab_font_size'))
                      .fontColor(Color.White)
                  }
                  .onClick(() => {
                    if (index === 3) {
                      this.dialogController = new CustomDialogController({
                        builder: ShareDialog(),
                        autoCancel: true,
                        customStyle: true,
                        maskColor: $r('app.color.mask_color')
                      });
                      this.dialogController.open();
                    }
                  })
                }
              }, (item: SideIcon, index: number) => JSON.stringify(item) + index)
            }
            .alignListItem(ListItemAlign.Center)

            // [EndExclude short_video]
            Blank()
              .layoutWeight(1)
              .displayPriority(1)
          }
          // [StartExclude short_video]
          .padding({
            top: $r('app.float.margin_lg'),
            bottom: $r('app.float.margin_lg')
          })

          // [EndExclude short_video]
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .width('56vp')
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Bottom)
        .margin({
          top: this.topAvoidHeight + 24,
          bottom: this.bottomBarHeight,
          right: '8vp'
        })

        // Top tabs.
        Row() {
          // [StartExclude short_video]
          List({ space: CommonConstants.LIST_SPACE[1] }) {
            ForEach(CommonConstants.SHORT_VIDEO_TOP_TABS, (item: string, index: number) => {
              ListItem() {
                Text(item)
                  .fontSize($r('app.float.font_size_lg'))
                  .lineHeight($r('app.float.description_height_md'))
                  .fontColor(Color.White)
                  .fontWeight(index === this.currentTopIndex ? CommonConstants.FONT_WEIGHTS[1] :
                  CommonConstants.FONT_WEIGHTS[0])
                  .opacity(index === this.currentTopIndex ? 1 : 0.8)
                  .onClick(() => {
                    this.currentTopIndex = index;
                  })
              }
            }, (item: string, index: number) => item + index)
          }
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
          .layoutWeight(1)
          .height(CommonConstants.HUNDRED_PERCENT)
          .margin({ right: $r('app.float.description_height_md') })

          Image($r('app.media.icon_search'))
            .height($r('app.float.image_size_sm'))
            .width($r('app.float.image_size_sm'))
        }
        .position({ x: 0, y: this.topAvoidHeight })
        .width(CommonConstants.HUNDRED_PERCENT)
        .height($r('app.float.image_size_sm'))
        .padding({
          left: $r('app.float.margin_md'),
          right: $r('app.float.margin_md')
        })

        // [EndExclude short_video]
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.Black)

      // [End short_video]
    }
    .height(CommonConstants.HUNDRED_PERCENT)
    .width(CommonConstants.HUNDRED_PERCENT)
    .hideTitleBar(true)
  }
}