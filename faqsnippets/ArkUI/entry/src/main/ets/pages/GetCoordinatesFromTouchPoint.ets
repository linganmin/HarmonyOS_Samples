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
* FAQ:如何在长按手势回调方法里获取手指触摸点的坐标
*/

// [Start CoordinatesOfTheFingerTouchPoint]
@Component
struct CoordinatesOfTheFingerTouchPoint {
  @State count: number = 0;
  private touchAreaRight: number = 0;
  private touchAreaBottom: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;
  @State gestureEventInfo: string = '';

  build() {
    Column() {
      Row() {
        Column() {
          Text('+')
            .fontSize(28)
            .position({ x: this.positionX, y: this.positionY })
        }
        .height(200)
        .width('100%')
        .backgroundColor('#F1F3F5')
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.touchAreaRight = newValue.width as number;
          this.touchAreaBottom = newValue.height as number;
        })
        .gesture(
          // The following combined gestures are recognized sequentially. If the long press gesture event is not triggered normally, the drag gesture event will not be triggered.
          GestureGroup(GestureMode.Sequence,
            LongPressGesture({ repeat: true })
              .onAction((event: GestureEvent) => {
                if (event.repeat) {
                  this.count++;
                }
              }),
            PanGesture()
              .onActionStart(() => {
                this.getUIContext().getPromptAction().showToast({ message: 'Pan start', duration: 1000 });
              })
              .onActionUpdate((event: GestureEvent) => {
                for (let i = 0; i < event.fingerList.length; i++) {
                  if (event.fingerList[i] == undefined
                    || event.fingerList[i].localX < 0
                    || event.fingerList[i].localY < 0
                    || event.fingerList[i].localX > this.touchAreaRight
                    || event.fingerList[i].localY > this.touchAreaBottom) {
                    return;
                  }
                  this.positionX = event.fingerList[i].localX;
                  this.positionY = event.fingerList[i].localY;
                }
                this.gestureEventInfo = 'sequence gesture\n' + 'LongPress onAction' + this.count
                  + '\nX:' + this.positionX + '\nY:' + this.positionY;
              })
              .onActionEnd(() => {
                this.getUIContext().getPromptAction().showToast({ message: 'Pan end', duration: 1000 });
              })
          )
            .onCancel(() => {
              this.getUIContext().getPromptAction().showToast({ message: 'Cancel', duration: 1000 });
            })
        )
      }
      .padding(12)
      .borderRadius(24)
      .backgroundColor(Color.White)

      Text(this.gestureEventInfo)
        .fontSize(18)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 18, top: 30 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}
// [End CoordinatesOfTheFingerTouchPoint]