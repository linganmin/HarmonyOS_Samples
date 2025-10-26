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

import { map } from '@kit.MapKit';
import { Common } from '@ohos/commons/Index';
import { ColumnView } from './ColumnView';
import { GridView } from './GridView';
import { ListView } from './ListView';
import { SearchBar } from './SearchBar';

@Component
export struct HomeFullView {
  @Link columnHeight: number;
  @Link mapController: map.MapComponentController;

  build() {
    Scroll() {
      Column() {
        SearchBar({
          columnHeight: this.columnHeight,
          mapController: this.mapController
        })

        GridView({ columnHeight: this.columnHeight })

        ColumnView({ columnHeight: this.columnHeight })

        ListView()

        Column() {
          Row() {
            Text($r('app.string.voice_navigation'))
              .fontSize($r('app.float.add_font_size'))
              .fontColor($r('app.color.black'))
            Image($r('app.media.close'))
              .height($r('app.float.close_image_size'))
              .width($r('app.float.close_image_size'))
          }
          .width(Common.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: $r('app.float.side_space'),
            right: $r('app.float.side_space'),
            bottom: $r('app.float.text_space')
          })
        }
        .height($r('app.float.voice_column_height'))
        .padding({
          top: $r('app.float.side_distance'),
          bottom: $r('app.float.add_text_space')
        })
        .margin({ top: $r('app.float.side_distance') })
        .borderRadius($r('app.float.border_radius'))
        .shadow({
          radius: $r('app.float.shadow_radius'),
          color: $r('app.color.blur')
        })
      }
      .width(Common.FULL_WIDTH)
      .padding({
        left: $r('app.float.side_space'),
        right: $r('app.float.side_space')
      })
    }
    .width(Common.FULL_WIDTH)
    .scrollBar(BarState.Off)
    .scrollable(this.columnHeight === Common.HEIGHT_LOW ? ScrollDirection.None : ScrollDirection.Vertical)
  }
}