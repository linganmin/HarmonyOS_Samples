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
* FAQ:如何实现当长按触发成功后，移出组件取消当前长按手势
*/

// [Start CancelLongPressEventWhenRemovingComponents]
@Entry
@Component
struct CancelLongPressEventWhenRemovingComponents {
  private recWidth: number = 200;
  private recHeight: number = 100;
  @State isLongPressing: boolean = false;
  @State shouldCancel: boolean = false;
  @State touchInBounds: boolean = true;

  build() {
    Column() {
      // Touchable area.
      Stack() {
        Text(this.isLongPressing ? 'Long Pressing...' : 'Long press me')
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width(this.recWidth)
      .height(this.recHeight)
      .backgroundColor(this.isLongPressing ? Color.Red : Color.Blue)
      .gesture(
        LongPressGesture({ repeat: false })
          .onAction(() => {
            if (!this.shouldCancel && this.touchInBounds) {
              this.handleLongPressStart();
            }
          })
          .onActionEnd(() => {
            this.handleLongPressEnd();
          })
      )
      .onTouch((event: TouchEvent) => {
        this.handleTouchEvent(event);
      })
      .onClick(() => {
        console.info('onClick');
      })
      .width(this.recWidth)
      .height(this.recHeight)

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // Handling touch events.
  private handleTouchEvent(event: TouchEvent) {
    const touchX = event.touches[0].x;
    const touchY = event.touches[0].y;
    // Calculate whether the touch point is within the component boundary.
    const inBounds = touchX >= 0 && touchX <= this.recWidth && touchY >= 0 && touchY <= this.recHeight;
    switch (event.type) {
      case TouchType.Down:
        this.shouldCancel = false;
        this.touchInBounds = true;
        break;
      case TouchType.Move:
        // Update touch position status.
        this.touchInBounds = inBounds;
        // If moving out of the boundary and long pressing, cancel.
        if (!inBounds && this.isLongPressing) {
          this.shouldCancel = true;
          this.isLongPressing = false;
          console.info('LongPressCancel', 'Slide beyond the boundary, cancel long press.');
        }
        break;
      case TouchType.Up:
        this.shouldCancel = true;
        this.touchInBounds = true;
        break;
    }
  }

  // Long press to start processing.
  private handleLongPressStart() {
    console.info('LongPress', 'Long press to start');
    this.isLongPressing = true;
  }

  // Long press to end processing.
  private handleLongPressEnd() {
    console.info('LongPress', 'Long press to end');
    this.isLongPressing = false;
    this.shouldCancel = false;
  }
}

// [End CancelLongPressEventWhenRemovingComponents]