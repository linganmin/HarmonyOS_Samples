/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { ChildRoute, Constants, Route } from '../constants/Constants';
import { camera, cameraPicker as picker } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  private routes: Route[] = Constants.ROUTES;
  private one: number = 1;
  @State fileUri: string = '';

  async openCamera(title: ResourceStr) {
    const pickerProfile: picker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
    };
    const pickerResult: picker.PickerResult = await picker.pick(this.getUIContext().getHostContext(),
      [picker.PickerMediaType.PHOTO], pickerProfile);
    this.fileUri = pickerResult.resultUri;
    if (this.fileUri) {
      try {
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/CameraPage', params: {
            fileUri: this.fileUri,
            title
          }
        });
      } catch (e) {
        let err = e as BusinessError;
        hilog.error(0x0000, 'Index', `failed code=${err.code}, message=${err.message}`);
      }
    }
  }

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
                Row() {
                  Text(itemChild.text)
                    .height(Constants.CARD_TEXT_HEIGHT)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: $r('app.float.index_item_padding_left') })
                    .fontSize($r('app.float.text_size'))
                  Column()
                    .layoutWeight(1)
                  Image($r('app.media.ic_public_arrow_right'))
                    .width($r('app.float.index_arrow_width'))
                    .height($r('app.float.index_arrow_height'))
                    .margin({ right: $r('app.float.index_item_margin_right') })
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)

                Stack() {
                  if (item.child.length - this.one !== index) {
                    Row()
                      .height(Constants.DIVIDER_HEIGHT)
                      .backgroundColor($r('app.color.index_divider_color'))
                      .width(Constants.DIVIDER_WIDTH)
                  }
                }
              }
              .onClick(() => {
                if (itemChild.to === 'CameraPage') {
                  this.openCamera(itemChild.text);
                } else {
                  this.getUIContext().getRouter().pushUrl({
                    url: 'pages/' + itemChild.to,
                    params: {
                      title: itemChild.text
                    }
                  });
                }
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
    .padding({ top: $r('app.float.padding_index_top') })
    .translate({ y: Constants.TRANSLATE_TOP })
    .backgroundColor($r('app.color.side_background_color'))
    .width(Constants.FULL_WIDTH)
    .height(Constants.LIST_CONTENT_HEIGHT)
    .alignItems(HorizontalAlign.Center)
  }
}