/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

@Component
export struct HyperlinkDrag {
  @State visible: boolean = true;

  // Customize the content displayed during dragging
  @Builder
  pixelMapBuilder() {
    Hyperlink("https://www.developer.huawei.com", 'HarmonyOS')
      .color('#007DFF')
  }

  build() {
    Column() {
      Hyperlink("https://www.developer.huawei.com", 'HarmonyOS')
        .id('hyperlink')
        .color('#007DFF')
        .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
        .draggable(true)
        .onDragStart(() => {
          this.visible = false;
          return this.pixelMapBuilder;
        })
        .onDragEnd(() => {
          this.visible = true;
        })
    }
    .width(400)
    .height(80)
    .backgroundColor(0xF9CF93)
    .justifyContent(FlexAlign.Center)
  }
}