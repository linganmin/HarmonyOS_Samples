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

import { GlobalBuilderContext } from '../viewmodel/GlobalBuilderContext';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CustomButtonModifier, CustomColumnModifier } from '../viewmodel/ComponentModifier';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private customButton: CustomButtonModifier = new CustomButtonModifier();
  private customColumn: CustomColumnModifier = new CustomColumnModifier();

  @Builder
  pagesMap(name: string) {
    if (GlobalBuilderContext.getContext().getObject(name) !== undefined) {
      (GlobalBuilderContext.getContext().getObject(name) as WrappedBuilder<[string]>).builder(name);
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 12 }) {
        ForEach(Const.PAGE_TITLES_RESOURCE, (item: Resource, index: number) => {
          Button(item)
            .attributeModifier(this.customButton)
            .onClick(() => {
              this.pageInfos.pushPathByName(Const.PAGE_NAMES[index], 0);
            })
        }, (item: Resource) => {
          return JSON.stringify(item);
        })
      }
      .attributeModifier(this.customColumn)
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .title($r('app.string.EntryAbility_label'))
    .mode(NavigationMode.Stack)
    .navDestination(this.pagesMap)
    .backgroundColor(0XF1F3F5)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}