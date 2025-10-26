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

import { common } from '@kit.AbilityKit';
import { HotSearchView } from '../view/HotSearchView';
import { UpdateReminderView } from '../view/UpdateReminderView';
import { ScreenUtil } from '../common/util/ScreenUtil';

@Entry
@Component
struct Index {
  @StorageLink('context') context: common.UIAbilityContext | undefined = undefined;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  @State timeoutID: number = 0;

  build() {
    Navigation(this.pageInfo) {
      Swiper() {
        HotSearchView()
        UpdateReminderView()
      }
      .height('100%')
      .width('100%')
      .borderRadius('50%')
      .curve(Curve.Linear)
      .loop(false)
      .indicator(new DotIndicator()
        .itemWidth(8)
        .selectedItemWidth(15)
        .itemHeight(8)
        .selectedItemHeight(8))
      .padding({
        top: 17,
        left: 26,
        right: 26
      })
      .onChange((index: number) => {
        if (index === 0) {
          clearTimeout(this.timeoutID);
          ScreenUtil.changeScreenState(this.context, false);
        } else {
          ScreenUtil.changeScreenState(this.context, true);
          this.timeoutID = setTimeout(() => {
            ScreenUtil.changeScreenState(this.context, false);
            clearTimeout(this.timeoutID);
          }, 60 * 1000);
        }
      })
    }
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}