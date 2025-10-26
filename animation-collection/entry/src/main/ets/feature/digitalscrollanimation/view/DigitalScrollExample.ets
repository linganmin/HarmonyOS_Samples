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

import { CommonConstants } from '../common/CommonConstants';
import { DigitalScrollDetail } from './DigitalScrollDetail';

@Component
export struct DigitalScrollExample {
  @State isRefresh: boolean = false;
  private scroller: Scroller = new Scroller();

  @Builder
  scrollArea() {
    List({ space: CommonConstants.ITEM_SPACE, scroller: this.scroller }) {
      ListItem() {
        Text($r('app.string.digital_scroll_animation_ticket'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .width($r('app.string.max_size'))
          .textAlign(TextAlign.Center)
      }

      ListItem() {
        Row({ space: CommonConstants.TEXT_SPACE }) {
          Text($r('app.string.digital_scroll_animation_today'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Bold)

          DigitalScrollDetail({ isRefresh: this.isRefresh })

          Text($r('app.string.digital_scroll_animation_get_ticket'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Bold)
        }
        .width($r('app.string.max_size'))
        .justifyContent(FlexAlign.Center)
      }
    }
    .scrollBar(BarState.Off)
    .height($r('app.string.max_size'))
  }

  build() {
    Column({ space: CommonConstants.ITEM_SPACE }) {
      Refresh({ refreshing: $$this.isRefresh }) {
        this.scrollArea()
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefresh = false;
        }, CommonConstants.TIME_OUT);
      })
    }
    .padding({ top: $r('app.float.column_padding_top') })
    .width($r('app.string.max_size'))
    .height($r('app.string.max_size'))
    .linearGradient({
      colors: [[$r('app.color.digital_scroll_animation_background_color'), 0.0],
        [$r('sys.color.ohos_id_color_background'), 0.3]]
    })
  }
}

@Builder
export function getDigitalScrollExample(name: string): void {
  if (name === 'DigitalScrollExample') {
    NavDestination() {
      DigitalScrollExample()
    }
  }
}

export const wrappedBuilderDigitalScroll: WrappedBuilder<[string, number]> = wrapBuilder(getDigitalScrollExample);