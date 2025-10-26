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

import { NestedScrolling } from './NestedScrolling';
import { FullExpansion } from './FullExpansion';
import { WebNestedTabs } from './WebNestedTabs';
import { MenuViewModel } from '../viewmodel/MenuViewModel';
import { StandardButtonList, StandardButtonListItem } from '../view/StandardButtonList';

@Entry
@Component
struct Index {
  @State buttonList: StandardButtonListItem[] = (new MenuViewModel()).getData();
  @Provide navPathStack: NavPathStack = new NavPathStack();
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  aboutToAppear(): void {
    this.buttonList[0].callback = () => this.navPathStack.pushPath({ name: 'Demo01' });
    this.buttonList[1].callback = () => this.navPathStack.pushPath({ name: 'Demo02' });
    this.buttonList[2].callback = () => this.navPathStack.pushPath({ name: 'Demo03' });
  }

  @Builder
  PageMap(name: string) {
    if (name === 'Demo01') {
      NestedScrolling()
    } else if (name === 'Demo02') {
      FullExpansion()
    } else if (name === 'Demo03') {
      WebNestedTabs()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Text($r('app.string.text4'))
          .width('100%')
          .fontColor('#E6000000')
          .fontSize(30)
          .fontWeight(700)
          .lineHeight(40)
          .textAlign(TextAlign.Start)

        StandardButtonList({ data: this.buttonList })
      }
      .padding({
        left: 24,
        right: 24,
        top: 64 + this.topRectHeight,
        bottom: 44
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .backgroundColor('#F1F3F5')
  }
}