/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

@Entry
@Component
struct Index {
  private buttonList: string[] =
    Array.from({ length: 12 }, (_: number, i: number) => `Segment${i + 1}`);
  @Provide("appPathStack") appPathStack: NavPathStack = new NavPathStack();
  @Provide("discoverPathStack") discoverPathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.appPathStack) {
      List({ space: 12 }) {
        ForEach(this.buttonList, (item: string) => {
          ListItem() {
            Button(item).onClick(() => this.appPathStack.pushPathByName(item, null));
          }
        }, (item: string) => item)
      }
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Center)
    }
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
  }
}