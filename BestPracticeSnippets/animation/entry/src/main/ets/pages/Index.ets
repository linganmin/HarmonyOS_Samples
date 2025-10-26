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

import { CustomAnimation } from './CustomAnimation';
import { PropertyAnimateTo } from './PropertyAnimateTo';
import { ExplicitAnimateTo } from './ExplicitAnimateTo';
import { ImageAnimation } from './ImageAnimation';
import { MultipleProperties } from './MultipleProperties';
import { UpdateMultipleProperties } from './UpdateMultipleProperties';
import { RenderGroup } from './RenderGroup';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    NavDestination() {
      if (name === 'CustomAnimation') {
        CustomAnimation()
      } else if (name === 'PropertyAnimateTo') {
        PropertyAnimateTo()
      } else if (name === 'ExplicitAnimateTo') {
        ExplicitAnimateTo()
      } else if (name === 'ImageAnimation') {
        ImageAnimation()
      } else if (name === 'MultipleProperties') {
        MultipleProperties()
      } else if (name === 'UpdateMultipleProperties') {
        UpdateMultipleProperties()
      } else if (name === 'RenderGroup') {
        RenderGroup()
      }

    }
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }

  build() {
    Navigation(this.pageStack) {
      Column() {

        Blank()

        Button('CustomAnimation')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('CustomAnimation', '');
          })
        Button('PropertyAnimateTo')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('PropertyAnimateTo', '');
          })
        Button('ExplicitAnimateTo')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('ExplicitAnimateTo', '');
          })
        Button('ImageAnimation')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('ImageAnimation', '');
          })
        Button('MultipleProperties')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('MultipleProperties', '');
          })
        Button('UpdateMultipleProperties')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('UpdateMultipleProperties', '');
          })
        Button('RenderGroup')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('RenderGroup', '');
          })
      }
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor('#F1F3F5')
    .navDestination(this.PagesMap)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}