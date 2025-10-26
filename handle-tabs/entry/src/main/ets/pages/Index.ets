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

import { util } from '@kit.ArkTS';
import { FULL_PERCENT, STYLE_CONFIGURATION } from '../model/ConstantsData';
import { MenuBar } from './MenuBar';
import { TabSheets } from './TabSheetComponent';

@Entry
@Component
struct Index {
  @State tabArray: Array<number> = [0];
  @State focusIndex: number = 0;
  private addressList: Array<number> = new Array(8).fill(0);
  private controller: TabsController = new TabsController();

  build() {
    Column() {
      TabSheets({ tabArray: $tabArray, focusIndex: $focusIndex, controller: this.controller })

      MenuBar()

      Divider()
        .width(FULL_PERCENT)
        .backgroundColor($r('sys.color.ohos_id_color_subheading_separator'))

      Tabs({ barPosition: BarPosition.Start, index: this.focusIndex, controller: this.controller }) {
        ForEach(this.tabArray, (item: number, index: number) => {
          TabContent() {
            Column() {
              if (this.tabArray[index] === 0) {
                Column() {
                  Row() {
                    Text($r('app.string.HandleTabs'))
                      .fontSize($r('app.float.text_size_headline'))
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({overflow:TextOverflow.Ellipsis})
                      .maxLines(1)
                  }
                  .margin({ bottom: $r('app.float.margin_vertical_m') })
                  Row(){
                    Text($r('app.string.HandleTabsDesc'))
                      .wordBreak(WordBreak.BREAK_ALL)
                  }
                  .width(FULL_PERCENT)
                }
                .width(FULL_PERCENT)
                .backgroundColor($r('app.color.ohos_id_color_sub_background'))
                .borderRadius($r('app.float.corner_radius_default_m'))
                .padding($r('app.float.card_padding_start'))
              } else {
                Column() {
                  Search()
                    .width('90%')
                  Grid() {
                    ForEach(this.addressList, () => {
                      GridItem() {
                        Column({ space: STYLE_CONFIGURATION.CONTENT_GUTTER_S }) {
                          Text()
                            .width(STYLE_CONFIGURATION.IMAGE_SIZE)
                            .aspectRatio(1)
                            .backgroundColor($r('app.color.third_black'))
                            .borderRadius(STYLE_CONFIGURATION.IMAGE_RADIUS)
                          Text()
                            .width(STYLE_CONFIGURATION.TEXT_WIDTH)
                            .height(STYLE_CONFIGURATION.TEXT_HEIGHT)
                            .backgroundColor($r('app.color.third_black'))
                        }
                      }
                    })
                  }
                  .columnsTemplate('1fr 1fr 1fr 1fr')
                  .rowsGap(STYLE_CONFIGURATION.CONTENT_GUTTER_M)
                  .rowsTemplate('1fr 1fr')
                  .height(STYLE_CONFIGURATION.GRID_HEIGHT)
                  .margin({ top: STYLE_CONFIGURATION.GRID_MARGIN })
                }
                .height(FULL_PERCENT)
                .justifyContent(FlexAlign.Center)
              }
            }
            .height(FULL_PERCENT)
          }
        }, (item: number) => item.toString() + util.generateRandomUUID())
      }
      .scrollable(false)
      .barHeight(0)
      .onChange((index: number) => {
        this.focusIndex = index;
      })
    }.width("100%")
  }
}