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

@Component
export struct ScrollComponent {
  @State list: string[] = new Array(100).fill('');
  @State banner_height: number = 50;
  scroll_start_timeout?: number;
  scroll_stop_timeout?: number;

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text('top')
          .fontSize(20)
      }
      .height(this.banner_height)

      List() {
        ForEach(this.list, () => {
          ListItem() {
            Text('北京')
              .fontSize(24)
          }
        }, (item: string) => item)
      }
      .onScrollStart(() => {
        if (this.scroll_stop_timeout) {
          clearTimeout(this.scroll_stop_timeout);
        }
        if (!this.scroll_start_timeout) {
          this.scroll_start_timeout = setTimeout(() => {
            this.banner_height = 0;
          }, 2000)
        }
      })
      .onScrollStop(() => {
        if (this.scroll_start_timeout) {
          clearTimeout(this.scroll_start_timeout);
        }
        if (this.scroll_stop_timeout) {
          clearTimeout(this.scroll_stop_timeout);
        }
        this.scroll_stop_timeout = setTimeout(() => {
          this.banner_height = 50;
        }, 2000);
      })
      .backgroundColor('#FFF1F3F5')
      .alignListItem(ListItemAlign.Center)

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text('bottom')
          .fontSize(20)
      }
      .height(this.banner_height)
    }
  }
}