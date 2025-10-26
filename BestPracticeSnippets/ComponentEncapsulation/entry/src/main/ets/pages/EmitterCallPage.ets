/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { emitter } from '@kit.BasicServicesKit';

// [Start emitter]
@Component
export struct ChildComponent {
  public static readonly EVENT_ID_SWITCH_COLOR = 'SWITCH_COLOR';
  @State bgColor: ResourceColor = Color.White;
  private switchColor = () => {
    if (this.bgColor === Color.White) {
      this.bgColor = Color.Red;
    } else {
      this.bgColor = Color.White;
    }
  }

  aboutToAppear(): void {
    emitter.on(ChildComponent.EVENT_ID_SWITCH_COLOR, this.switchColor);
  }

  aboutToDisappear(): void {
    emitter.off(ChildComponent.EVENT_ID_SWITCH_COLOR, this.switchColor);
  }

  build() {
    Column() {
      Text('Child Component')
    }.backgroundColor(this.bgColor)
    .borderWidth(1)
  }
}

@Entry
@Component
struct Index {
  build() {
    Column() {
      ChildComponent()

      Button('Switch Color')
        .onClick(() => {
          emitter.emit(ChildComponent.EVENT_ID_SWITCH_COLOR);
        })
        .margin({ top: 16 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

// [End emitter]