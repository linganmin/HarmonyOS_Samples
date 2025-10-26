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
* FAQ: 如何对手势事件进行限流？例如500ms内不允许点击事件重复触发？
*/

// [Start gesture_modifier]
class MyGesture implements GestureModifier {
  interval: number = 2000;
  private inThrottle: boolean = false;
  private lastGestureType: string = '';

  // Unified rate limiting processing
  private throttleWrapper(eventType: string, callback: () => void) {
    if (!this.inThrottle) {
      this.inThrottle = true;
      this.lastGestureType = eventType;
      callback();

      setTimeout(() => {
        this.inThrottle = false;
        this.lastGestureType = '';
      }, this.interval);
    }
  }

  applyGesture(event: UIGestureEvent): void {
    // Create a unified gesture processing function
    const handleTap = (gestureEvent: GestureEvent) => {
      this.throttleWrapper('tap', () => {
        console.info('---onTap---');
      });
    };

    const handleLongPress = (gestureEvent: GestureEvent) => {
      this.throttleWrapper('longPress', () => {
        console.info('---onLongPress---');
      });
    };

    // Add two gesture recognizers
    event.addGesture(
      new TapGestureHandler({ count: 1, fingers: 1 })
        .onAction(handleTap)
    );

    event.addGesture(
      new LongPressGestureHandler({ fingers: 1, duration: 600 })
        .onAction(handleLongPress)
    );
  }
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State modifier: MyGesture = new MyGesture();

  build() {
    RelativeContainer() {
      Button(this.message)
        .id('click')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .gestureModifier(this.modifier)
    }
    .height('100%')
    .width('100%')
  }
}

// [End gesture_modifier]