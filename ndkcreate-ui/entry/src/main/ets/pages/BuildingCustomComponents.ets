/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import nativeNode from 'libentry.so';
import { NodeContent } from '@kit.ArkUI';

@Builder
function PageBuilder() {
  PageComponent()
}

@Component
struct PageComponent {
  // Initialize NodeContent object.
  private rootSlot = new NodeContent();
  @State @Watch('changeNativeFlag') showNative: boolean = false;

  changeNativeFlag(): void {
    if (this.showNative) {
      // Passing NodeContent object for Native creation of component mounting display.
      nativeNode.CreateCustomContainerNativeRoot(this.rootSlot);
    } else {
      // Destroy NativeModule component.
      nativeNode.DestroyCustomContainerNativeRoot();
    }
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Button(this.showNative ? "HideNativeUI" : "ShowNativeUI")
          .onClick(() => {
            this.showNative = !this.showNative;
          })
        Row() {
          // Bind NodeContent and ContentSlot placeholder components.
          ContentSlot(this.rootSlot)
        }.layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ top: 16 })
    }
    .title($r('app.string.building_custom_components'))
  }
}