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
* FAQ:Toggle组件设置拖动的同时如何屏蔽其本身的点击手势
*/

// [Start toggle_component_blocks_click_gestures]
import { hilog } from '@kit.PerformanceAnalysisKit';


@Entry
@Component
struct ToggleDrag {
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;
  @State toggleIsOn: boolean = true;
  // Marks whether the current drag state is used to block click events
  private isDragging: boolean = false;


  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Toggle({ type: ToggleType.Button, isOn: this.toggleIsOn }) {
        Text('Toggle')
      }
      .selectedColor(Color.Pink)
      // Onchange callback precedes onActionEnd
      .onChange((isOn: boolean) => {
        hilog.info(0x0000, 'TOGGLE_DRAG', 'xxx %{public}s', `onClick Toggle, isOn: ${isOn}`);
        console.info('isDragging======' + this.isDragging);
        if (isOn === this.toggleIsOn) {
          return;
        } else {
          this.toggleIsOn = isOn;
        }
        if (this.isDragging) {
          this.toggleIsOn = !this.toggleIsOn;
        }
      })
      .translate({ x: this.offsetX, y: this.offsetY })
      .gesture(
        PanGesture()
          .onActionStart(() => {
            this.isDragging = true;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetX = this.positionX + event.offsetX;
            this.offsetY = this.positionY + event.offsetY;
          })
          .onActionEnd(() => {
            this.positionX = this.offsetX;
            this.positionY = this.offsetY;
            this.isDragging = false;
          })
      )
    }
  }
}
// [End toggle_component_blocks_click_gestures]