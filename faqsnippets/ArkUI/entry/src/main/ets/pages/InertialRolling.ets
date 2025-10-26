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
* FAQ: 如何通过PanGesture手势或者SwipeGesture手势实现自定义组件的惯性滚动效果
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
      Text('PanGesture offset: \nX: ' + this.offsetX + '\n' + 'Y: ' + this.offsetY)
    }
    .height(200)
    .width(200)
    .padding(20)
    .border({ width: 3 })
    .margin(30)
    // 以组件左上角为坐标原点进行移动
    .translate({
      x: this.offsetX,
      y: this.offsetY,
      z: 0
    })
    .gesture(
      // 拖动
      PanGesture(this.panOption)
        .onActionStart((event?: GestureEvent) => {
          console.info('Pan start');
        })
        .onActionUpdate((event?: GestureEvent) => {
          if (event) {
            // 最后的位置加上偏移量
            this.offsetX = this.positionX + event.offsetX;
            this.offsetY = this.positionY + event.offsetY;
          }
        })
        .onActionEnd((event) => {
          this.offsetX = this.positionX + event.offsetX;
          this.offsetY = this.positionY + event.offsetY;
          this.positionX = this.positionX + event.offsetX;
          this.positionY = this.positionY + event.offsetY;
          let ySpeed = event.velocityY;
          this.getUIContext().animateTo({
            duration: 1000,
            curve: Curve.LinearOutSlowIn,
            iterations: 1,
            playMode: PlayMode.Normal,
            onFinish: () => {
              console.info('play end');
            }
          }, () => {
            this.offsetY = this.offsetY + ySpeed * 0.2;
            this.positionY = this.positionY + ySpeed * 0.2;
          })
        })
    )
  }
}
// [End pan_gesture_example]