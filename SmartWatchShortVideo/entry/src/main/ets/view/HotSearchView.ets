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

import { CommonConstants } from '../common/constants/CommonConstants';

@Component
export struct HotSearchView {
  @Consume('pageInfo') pageInfo: NavPathStack;

  build() {
    Column() {
      Text($r('app.string.title_hot_search'))
        .fontSize('19fp')
        .fontWeight(700)
        .margin({ bottom: 9 })

      Swiper() {
        ForEach(CommonConstants.PICTURES, (item: ResourceStr) => {
          Image(item)
            .width('80%')
            .borderRadius('50%')
            .clip(true)
            .margin({ bottom: 6 })
            .onClick(() => {
              this.pageInfo.pushPath({ name: 'VideoView' });
            })
        }, (item: ResourceStr) => JSON.stringify(item))
      }
      .vertical(true)
      .indicator(false)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}