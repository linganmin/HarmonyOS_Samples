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
* FAQ：如何判断组件遮挡情况，并主动隐藏被遮挡的组件
*/

// [Start component_occlusion_scene_one]
import { inspector, UIInspector } from '@kit.ArkUI';

@Entry
@Component
struct ComponentHide {
  uiInspector: UIInspector = this.getUIContext().getUIInspector();
  listener: inspector.ComponentObserver = this.uiInspector.createComponentObserver('inspectTarget');
  @State x: number = 170;
  @State button1Visibility: Visibility = Visibility.Visible;

  aboutToAppear(): void {
    let shouldShow: () => void = (): void => {
      let button1Info = this.getUIContext().getFrameNodeById('button1')?.getPositionToWindowWithTransform(); // vp
      let button1Size = this.getUIContext().getFrameNodeById('button1')?.getMeasuredSize(); // px
      let button1TopLeftX = this.getUIContext().vp2px(button1Info?.x); // The x-coordinate of the upper left corner of button1, with the unit of px
      let button1TopLeftY = this.getUIContext().vp2px(button1Info?.y); // The y-coordinate of the upper left corner of button1, with the unit of px
      let button1BottomRightX = button1TopLeftX + (button1Size?.width ?? 0); // The x-coordinate at the lower right corner of button1, with the unit of px
      let button1BottomRightY = button1TopLeftY + (button1Size?.height ?? 0); // The y-coordinate of the lower right corner of button1, with the unit of px

      let button2Info = this.getUIContext().getFrameNodeById('button2')?.getPositionToWindowWithTransform(); // vp
      let button2Size = this.getUIContext().getFrameNodeById('button2')?.getMeasuredSize(); // px
      let button2TopLeftX = this.getUIContext().vp2px(button2Info?.x); // The x-coordinate of the upper left corner of button2, with the unit of px
      let button2TopLeftY = this.getUIContext().vp2px(button2Info?.y); // The y-coordinate of the upper left corner of button2, with the unit of px
      let button2BottomRightX = button2TopLeftX + (button2Size?.width ?? 0); // The x-coordinate at the lower right corner of button2, with the unit being px
      let button2BottomRightY = button2TopLeftY + (button2Size?.height ?? 0); // The y-coordinate of the lower right corner of button2, with the unit of px

      let xOverlap = (button1TopLeftX < button2BottomRightX) && (button2TopLeftX < button1BottomRightX);
      let yOverlap = (button1TopLeftY < button2BottomRightY) && (button2TopLeftY < button1BottomRightY);
      if (xOverlap && yOverlap) {
        this.button1Visibility = Visibility.Hidden;
      } else {
        this.button1Visibility = Visibility.Visible;
      }
      this.listener.on('layout', shouldShow);
    }
  }

  build() {
    Column() {
      Column() {
        Button('button1')
          .position({ x: 200, y: 200 })
          .id('button1')
          .visibility(this.button1Visibility)
      }

      Column() {
        Button('button2')
          .position({ x: this.x, y: 200 })
          .onClick(() => {
            this.x = 200 - this.x; // If the component position changes, the layout will not be reconfigured and the registered shouldShow callback will not be called
          })
          .id('button2')
      }
    }
    .id('inspectTarget')
  }
}

// [End component_occlusion_scene_one]