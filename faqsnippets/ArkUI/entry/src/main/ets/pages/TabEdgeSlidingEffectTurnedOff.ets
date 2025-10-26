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
* FAQ:如何将Tab的边缘滑动效果关掉，不要回弹
*/

// [Start tab_edge_sliding_effect_turned_off]
@Component
export struct TabsNoRebound {
  @State currentIndex: number = 0;
  private fontColor: string = '#182431';
  private selectedFontColor: string = '#007DFF';
  private controller: TabsController = new TabsController();
  private panOptionR: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Right });
  private panOptionL: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left });

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({
          top: 17,
          bottom: 7
        })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
    }
    .width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#00CB87')
        }
        .tabBar(this.tabBuilder(0, 'green'))
        .gesture(
          // Dragging to the right triggers this gesture event
          PanGesture(this.panOptionR)
            .onActionStart((event?: GestureEvent) => {
              console.info('Pan start');
            })
            .onActionUpdate((event?: GestureEvent) => {
              console.info('Pan onActionUpdate');
            })
            .onActionEnd(() => {
              console.info('Pan end');
            })
        )

        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#007DFF')
        }
        .tabBar(this.tabBuilder(1, 'blue'))

        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#FFBF00')
        }
        .tabBar(this.tabBuilder(2, 'yellow'))

        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#E67C92')
        }
        .tabBar(this.tabBuilder(3, 'pink'))
        .gesture(
          // Dragging to the left triggers this gesture event
          PanGesture(this.panOptionL)
            .onActionStart((event?: GestureEvent) => {
              console.info('Pan start');
            })
            .onActionUpdate((event?: GestureEvent) => {
              console.info('Pan onActionUpdate');
            })
            .onActionEnd(() => {
              console.info('Pan end');
            })
        )
      }
      .barMode(BarMode.Fixed)
      .barWidth(360)
      .barHeight(56)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width(360)
      .height(296)
      .margin({ top: 52 })
      .backgroundColor('#F1F3F5')
    }
    .width('100%')
  }
}
// [End tab_edge_sliding_effect_turned_off]