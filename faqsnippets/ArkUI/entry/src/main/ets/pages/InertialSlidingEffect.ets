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
* FAQ:如何实现手指离开屏幕后的惯性滑动效果
*/

// [Start pan_gesture_example]
@Entry
@Component
struct PanGestureExample {
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down });

  build() {
    Column() {
      Text('PanGesture offset:\nX: ' + this.offsetX + '\n' + 'Y: ' + this.offsetY)
    }
    .height(300)
    .width(300)
    .padding(20)
    .border({ width: 3 })
    .margin(30)
    .translate({ x: this.offsetX, y: this.offsetY, z: 0 }) // Move using the component's top-left corner as the coordinate origin
    // Trigger gesture event when dragging up and down
    .gesture(
      PanGesture(this.panOption)
        .onActionStart((event?: GestureEvent) => {
          console.info('Pan start');
        })
        .onActionUpdate((event?: GestureEvent) => {
          if (event) {
            this.getUIContext().animateTo({
              curve: Curve.LinearOutSlowIn,
              iterations: 1,
              tempo: 10000,
              playMode: PlayMode.Normal,
              onFinish: () => {
                console.info('play end');
              }
            }, () => {
              this.offsetX = this.positionX + event.offsetX;
              this.offsetY = this.positionY + event.offsetY;
            })
          }
        })
        .onActionEnd((event?: GestureEvent) => {
          if (event) {
            this.getUIContext().animateTo({
              curve: Curve.LinearOutSlowIn,
              iterations: 1,
              playMode: PlayMode.Normal,
              onFinish: () => {
                console.info('play end');
              }
            }, () => {
              this.offsetX = this.positionX + event.offsetX * 2;
              this.offsetY = this.positionY + event.offsetY * 2;
            })
          }
          this.positionX = this.offsetX;
          this.positionY = this.offsetY;
          console.info('Pan end');
        })
    )
  }
}
// [End pan_gesture_example]