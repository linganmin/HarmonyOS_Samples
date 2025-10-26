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

import { router } from '@kit.ArkUI';
import {CommonConstants} from '../constants/CommonConstants';

class DirectoryItem {
  title: ResourceStr = '';
  uri: string = '';
  id: string = '';
}

@Entry
@Component
struct Index {
  private directory: DirectoryItem[] = [
    {
      title: $r('app.string.grid_nest_list'),
      uri: CommonConstants.TABLE_GRID_NEST_LIST_URI,
      id: 'GridNestListIndex'
    },
    {
      title: $r('app.string.grid_nest_swiper'),
      uri: CommonConstants.TABLE_GRID_NEST_SWIPER_URI,
      id: 'GridNestSwiperIndex'
    }
  ];

  build() {
    Column(){
      ForEach(this.directory, (item: DirectoryItem) => {
        Button(item.title)
          .id(item.id)
          .fontSize($r('app.float.font_size'))
          .width(CommonConstants.NINETY_PERCENT)
          .height($r('app.float.button_height'))
          .margin({bottom:$r('app.float.button_margin')})
          .backgroundColor($r('app.color.button_background'))
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: item.uri
            });
          })
      }, (item: DirectoryItem) => JSON.stringify(item))
    }
    .justifyContent(FlexAlign.End)
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}