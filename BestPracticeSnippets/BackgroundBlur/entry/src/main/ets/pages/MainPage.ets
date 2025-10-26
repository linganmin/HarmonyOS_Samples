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

import { AdaptiveColorMode } from './AdaptiveColorMode';
import { ColorPickerMode } from './ColorPickerMode';
import { FastMode } from './FastMode';
import { OffscreenMode } from './OffscreenMode';
@Entry
@Component
struct MainPage {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  @Builder
  myRouter(name: string) {
    if (name === 'AdaptiveColorMode') {
      AdaptiveColorMode();
    } else if (name === 'ColorPickerMode') {
      ColorPickerMode();
    } else if (name === 'FastMode') {
      FastMode();
    } else if (name === 'OffscreenMode') {
      OffscreenMode();
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {
        Button('AdaptiveColorMode')
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pushPathByName('AdaptiveColorMode', null);
          })
        Button('ColorPickerMode')
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pushPathByName('ColorPickerMode', null);
          })
        Button('FastMode')
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pushPathByName('FastMode', null);
          })
        Button('OffscreenMode')
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pushPathByName('OffscreenMode', null);
          })
      }
      .height('100%')
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .navDestination(this.myRouter)
  }
}