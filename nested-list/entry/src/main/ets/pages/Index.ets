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

import { window } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { CardItem } from '../viewmodel/CardItem';
import { CardItemComponent } from '../view/CardItemComponent';
import { ClassifyModel } from '../viewmodel/ClassifyModel';
import { ClassifyViewModel } from '../viewmodel/ClassifyViewModel';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State currentClassify: number = 0;
  @StorageLink('topArea') topArea: number = 0;
  @StorageLink('bottomArea') bottomArea: number = 0;
  private classifyList: Array<ClassifyModel> = [];
  private data: Array<CardItem> = new ClassifyViewModel().getTopData();
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.classifyList = new ClassifyViewModel().getClassifyModelList();

    window.getLastWindow(this.getUIContext().getHostContext()).then((windowStage: window.Window) => {
      let area = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topArea = this.getUIContext().px2vp(area.topRect.height);
      let bottom = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.bottomArea = this.getUIContext().px2vp(bottom.bottomRect.height);
      if (this.topArea > 0) {
        windowStage.setWindowLayoutFullScreen(true);
      }
    })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', `getLastWindow failed. code=${err.code}, message=${err.message}`);
      })
  }

  classifyChangeAction(startIndex: number, isClassify: boolean) {
    if (this.currentClassify !== startIndex) {
      this.currentClassify = startIndex;
      if (isClassify) {
        this.scroller.scrollToIndex(startIndex);
      } else {
        this.classifyScroller.scrollToIndex(startIndex);
      }
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Image($r('app.media.ic_back'))
              .width($r('app.float.image_size'))
              .height($r('app.float.image_size'))
              .margin({
                left: $r('app.float.image_margin_left'),
                right: $r('app.float.image_margin_right')
              })
              .onClick(() => {
                this.getUIContext().getRouter().back();
              })

            Text($r('app.string.title'))
              .height($r('app.float.text_title_height'))
              .fontSize($r('app.float.top_title_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.title_height'))

          Column() {
            Text($r('app.string.common_service'))
              .fontSize($r('app.float.title_font_size'))
              .fontColor($r('app.color.service_color'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontFamily($r('app.string.common_font_family'))
              .lineHeight($r('app.float.common_line_height'))
              .margin({
                left: $r('app.float.common_margin_left')
              })
            List() {
              ForEach(this.data, (item: CardItem) => {
                ListItem() {
                  Column() {
                    Image(item.icon)
                      .width($r('app.float.top_image'))
                      .height($r('app.float.top_image'))
                    Text(item.name)
                      .fontSize($r('app.float.item_font_size'))
                      .margin({
                        top: $r('app.float.text_margin_top')
                      })
                  }
                }
                .margin({ top: $r('app.float.flex_item_margin') })
                .width(CommonConstants.ONE_FOURTH)
              }, (item: CardItem, index: number) => index + JSON.stringify(item))
            }
            .listDirection(Axis.Horizontal)
            .alignListItem(ListItemAlign.Center)
            .lanes(2)
            .scrollBar(BarState.Off)
            .enableScrollInteraction(false)
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.common_radius'))
            .height($r('app.float.service_height'))
            .margin({
              top: $r('app.float.common_margin_left')
            })
            .padding($r('app.float.service_padding'))
          }
          .alignItems(HorizontalAlign.Start)
          .padding($r('app.float.common_padding'))

          Column() {
            List({ scroller: this.classifyScroller }) {
              ForEach(this.classifyList, (item: ClassifyModel, index: number) => {
                ListItem() {
                  Column() {
                    Text(item.classifyName)
                      .fontSize($r('app.float.common_font_size'))
                      .fontColor(index === this.currentClassify ?
                      $r('app.color.select_title_color') : $r('app.color.title_color'))
                      .fontWeight(index === this.currentClassify ? CommonConstants.FONT_WEIGHT_500 : FontWeight.Normal)
                      .fontFamily($r('app.string.common_font_family'))
                      .width($r('app.float.item_width'))
                      .textAlign(TextAlign.Center)
                      .lineHeight($r('app.float.classify_line_height'))
                    Divider()
                      .width($r('app.float.item_width'))
                      .color($r('app.color.select_title_color'))
                      .strokeWidth(2)
                      .visibility(index === this.currentClassify ? Visibility.Visible : Visibility.Hidden)
                      .margin({
                        top: $r('app.float.divider_margin_top')
                      })
                  }
                  .justifyContent(FlexAlign.Center)
                  .width(CommonConstants.ONE_FOURTH)
                  .height(CommonConstants.FULL_PERCENT)
                }
                .onClick(() => {
                  this.classifyChangeAction(index, true);
                })
              }, (item: ClassifyModel, _index: number) => JSON.stringify(item.classifyName))
            }
            .height($r('app.float.top_height'))
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .padding({
              left: $r('app.float.list_padding'),
              right: $r('app.float.list_padding')
            })

            List({ scroller: this.scroller }) {
              ForEach(this.classifyList, (item: ClassifyModel, index: number) => {
                if (index !== this.classifyList.length - 1) {
                  ListItem() {
                    CardItemComponent({ classifyModel: item })
                  }
                } else {
                  ListItem() {
                    CardItemComponent({ classifyModel: item })
                      .height(CommonConstants.FULL_PERCENT)
                  }
                }
              }, (item: ClassifyModel, _index: number) => JSON.stringify(item.classifyName))
            }
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .height(CommonConstants.LIST_HEIGHT)
            .edgeEffect(EdgeEffect.Spring)
            .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
            .scrollBar(BarState.Off)
            .padding({
              left: $r('app.float.common_padding'),
              right: $r('app.float.common_padding'),
              bottom: $r('app.float.common_padding')
            })
            .edgeEffect(EdgeEffect.None)
          }
          .height(CommonConstants.FULL_PERCENT)
        }
      }
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('app.color.background_color'))
    .padding({
      top: this.topArea,
      bottom: this.bottomArea
    })
  }
}