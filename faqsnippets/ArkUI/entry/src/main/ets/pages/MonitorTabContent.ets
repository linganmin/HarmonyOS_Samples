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
* FAQ:如何监听Tabs里面tabContent页面显示
*/

// [Start monitor_tabContent]
@Component
struct MonitorTabContent {
  build() {
    Column() {
      Tabs() {
        TabContent() {
          ChildrenComponent1();
        }
        // ...
      }
      .height('60%')
      .barMode(BarMode.Fixed)
      .backgroundColor(0xf1f3f5)
    }
    .width('100%')
    .height(500)
    .padding(24)
  }
}

@Component
struct ChildrenComponent1 {
  build() {
    Column() {
      Text('Tab 1 Content')
    }
    .onVisibleAreaChange([0, 1], (isExpanding, currentRatio) => {
      if(isExpanding && currentRatio > 0) {
        console.log('Tab 1 出现');
      } else if(!isExpanding && currentRatio === 0) {
        console.log('Tab 1 消失');
      }
    })
  }
}
// [End monitor_tabContent]