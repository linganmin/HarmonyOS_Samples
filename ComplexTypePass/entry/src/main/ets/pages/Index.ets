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

@Entry
@Component
struct Index {
  menu: string[] = ['Uint8Array', 'Object', 'HashMap', 'PixelMap', 'Class'];
  pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Column() {
        ForEach(this.menu, (entry: string) => {
          Button(entry)
            .fontWeight(FontWeight.Bold)
            .width($r('app.string.100percent'))
            .margin({
              top: $r("app.string.margin_m_half"),
              bottom: $r("app.string.margin_m_half"),
            })
            .onClick(() => {
              this.pageStack.pushPathByName(entry + 'Page', entry);
            })
        })
      }
      .padding({
        bottom: $r("app.string.margin_s"),
        left: $r("app.string.margin_huge"),
        right: $r("app.string.margin_huge"),
      })
      .width($r('app.string.100percent'))
      .height($r('app.string.100percent'))
      .justifyContent(FlexAlign.End)
    }
    .title($r('app.string.main_title'))
  }
}