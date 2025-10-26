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
* FAQ:如何获取组件渲染完成时间
*/

// [Start get_component_render_time]
import { inspector } from '@kit.ArkUI';

@Entry
@Component
struct GetComponentRenderTime {
  @State startTime: number = 0;
  private listener: inspector.ComponentObserver = this.getUIContext().getUIInspector().createComponentObserver('IMAGE_ID');
  // Calculate rendering duration: currentTime - this.startTime
  private onDrawCompleteCallback = () => {
    // 2. Time when the image component finishes drawing
    console.info('onDrawComplete', new Date().getTime());
  };

  aboutToAppear() {
    // 1. Time when rendering starts
    this.startTime = new Date().getTime();
    console.info('aboutToAppear', this.startTime);

    // layout: Component layout completed
    // draw: Component drawing completed
    this.listener.on('draw', this.onDrawCompleteCallback);
  }

  aboutToDisappear() {
    // Unregister callback before destruction
    this.listener.off('draw', this.onDrawCompleteCallback);
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        Row({ space: 5 }) {
          Image($r('app.media.app_icon'))
            .width(110)
            .height(110)
            .id('IMAGE_ID')
        }
      }
    }
    .height(320)
    .width(360)
    .padding({
      right: 10,
      top: 10
    })
  }
}
// [End get_component_render_time]