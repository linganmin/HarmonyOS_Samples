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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants, Route, ChildRoute } from '../common/Constants';

@Entry
@Component
struct Index {
  private routes: Route[] = Constants.ROUTES;

  build() {
    Column() {
      Row() {
        Text($r('app.string.title'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.title_font_size'))
          .width(Constants.FULL_WIDTH)
          .fontColor($r('app.color.text_color'))
      }
      .width(Constants.INDEX_CONTENT_WIDTH)
      .height(Constants.INDEX_TITLE_HEIGHT)

      Scroll(){
        Column() {
          ForEach(this.routes, (item: Route) => {
            Row() {
              Text(item.title)
                .width(Constants.INDEX_CONTENT_WIDTH)
                .fontSize($r('app.float.double_text_size'))
                .fontColor($r('app.color.index_text_color'))
            }
            .height(Constants.CARD_TITLE_HEIGHT)

            Column() {
              ForEach(item.child, (itemChild: ChildRoute, index: number) => {
                Column() {
                  Text(itemChild.text)
                    .width(Constants.FULL_WIDTH)
                    .height(Constants.CARD_TEXT_HEIGHT)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: $r('app.float.padding_bottom_tab') })
                    .fontSize($r('app.float.text_size'))

                  if (item.child.length - 1 !== index) {
                    Row()
                      .height(Constants.DIVIDER_HEIGHT)
                      .backgroundColor($r('app.color.index_divider_color'))
                      .width(Constants.DIVIDER_WIDTH)
                  }
                }
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({
                    url: 'pages/' + itemChild.to
                  })
                    .then(() => {
                      hilog.info(0x0000, 'TAG', `pushUrl success`);
                    })
                    .catch((err: BusinessError) => {
                      hilog.error(0x0000, 'TAG', `pushUrl error code is ${err.code}, message is ${err.message}`);
                    })
                })
                .width(Constants.INDEX_CONTENT_WIDTH)
                .height(Constants.CARD_TEXT_HEIGHT)
              }, (item: ChildRoute, index: number) => JSON.stringify(item) + index)
            }
            .margin({ top: $r('app.float.margin_index_top'), bottom: $r('app.float.margin_index_bottom') })
            .borderRadius(Constants.BORDER_RADIUS_INDEX_LIST)
            .backgroundColor(Color.White)
          }, (item: Route, index: number) => JSON.stringify(item) + index)
        }
        .width(Constants.FULL_WIDTH)
      }
      .height($r('app.string.index_tab_scroll'))
    }
    .padding({ top: $r('app.float.padding_index_top') })
    .backgroundColor($r('app.color.side_background_color'))
    .width(Constants.FULL_WIDTH)
    .height(Constants.FULL_HEIGHT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .alignItems(HorizontalAlign.Center)
  }
}