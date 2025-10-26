/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何解决两层Tabs出现滑动冲突的情况？
*/

// [Start resolve_two_layers_of_tabs]
@Entry
@Component
struct TwoLayerTabNestedSliding {
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Column() {
            Tabs() {
              TabContent() {
                Text('Focus on content')
              }
              .tabBar('follow with interest')
              TabContent() {
                Text('The content of the game')
              }
              .tabBar('game')
            }
          }
          .backgroundColor('#f08a34')
          .width('100%')
        }
        .tabBar('home page')
        TabContent() {
          Column() {
            Tabs() {
              TabContent() {
                Text('The content of technology')
              }
              .tabBar('science and technology')
              TabContent() {
                Text('The content of the video')
              }
              .tabBar('video')
            }
          }
          .backgroundColor('#f08a34')
          .width('100%')
        }
        .tabBar('find')
      }
      .scrollable(false)
    }
    .width('100%')
    .height('100%')
  }
}
// [End resolve_two_layers_of_tabs]