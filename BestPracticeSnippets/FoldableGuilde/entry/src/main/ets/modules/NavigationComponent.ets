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

// [Start NavigationComponent]
@Component
export struct NavigationComponent {
  @State TooTmp: ToolbarItem = {'value': 'func', 'action': ()=> {}};
  private arr: number[] = [1, 2, 3];

  build() {
    Column() {
      // Root view container for routing navigation
      Navigation() {
        List({ space: 12 }) {
          ForEach(this.arr, (item: string) => {
            ListItem() {
              // Navigation component, which provides click response processing by default, does not require developers to customize click event logic。
              Navigation() {
                Text('NavRouter' + item)
                  .width('100%')
                  .height(72)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(24)
                  .fontSize(16)
                  .fontWeight(500)
                  .textAlign(TextAlign.Center)
                // Non-home page display content
                NavDestination() {
                  Text('NavDestinationContent' + item)
                }
                .title('NavDestinationTitle' + item)
              }
            }
          }, (item: string): string => item)
        }
        .width('90%')
        .margin({ top: 12 })
      }
      .title('主标题')
      .mode(NavigationMode.Auto)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

// [End NavigationComponent]