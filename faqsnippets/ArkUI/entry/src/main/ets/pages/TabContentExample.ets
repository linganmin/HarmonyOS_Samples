/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:如何实现Tabs切换页签，强制重新刷新页面数据
*/

// [Start TabContentExample]
import { SubTabContent } from './SubTabContent'
import { emitter } from '@kit.BasicServicesKit'

@Entry
@Component
export struct TabContentExample {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  @State selectedIndex: number = 0
  @State refreshFlag: boolean = true
  private controller: TabsController = new TabsController()

  @Builder
  tabBuilder(index: number) {
    Column() {
      Text(`Tab${index + 1}`)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(20)
        .fontWeight(500)
        .lineHeight(14)
    }.width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          Column() {
            SubTabContent()
          }
          .width('100%')
        }.tabBar(this.tabBuilder(0))

        TabContent() {
          Column() {
            Text('Tab2')
              .fontSize(36)
              .fontColor('#182431')
              .fontWeight(500)
              .opacity(0.4)
              .margin({ top: 30, bottom: 56.5 })
            Divider()
              .strokeWidth(0.5)
              .color('#182431')
              .opacity(0.05)
          }.width('100%')
        }.tabBar(this.tabBuilder(1))
      }
      .vertical(false)
      .barHeight(56)
      .onChange((index: number) => {
        this.currentIndex = index
        this.selectedIndex = index
        if (index === 0) {
          // 事件携带的数据
          let eventData: emitter.EventData = {
            data: {}
          };
          // 通过emitter.emit('refreshTable')发送指定的事件
          emitter.emit("refreshTable", eventData);
        }
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if (index === targetIndex) {
          return
        }
        // selectedIndex控制自定义TabBar内Image和Text颜色切换
        this.selectedIndex = targetIndex
      })
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
      .margin({ top: 38 })
    }
    .width('100%')
    .height('100%')
    .padding({
      bottom: 30
    })
  }
}
// [End TabContentExample]

// [Start SubTabContent]
import { emitter } from '@kit.BasicServicesKit';

@Component
export struct SubTabContent {
  @State counter: number = 0

  aboutToAppear(): void {
    // Tabs子组件通过emitter.on('refreshTable')持续订阅该事件去刷新数据
    emitter.on("refreshTable", () => {
      this.counter += 1
    });
  }

  build() {
    Text(`切换Tabs刷新数据${this.counter}`)
  }
}
// [End SubTabContent]