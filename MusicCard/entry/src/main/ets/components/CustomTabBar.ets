/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Component
export struct CustomTabBar {
  @Link currentIndex: number;

  @Builder
  CustomTabBarItem(title: Resource, tabIndex: number, img: Resource) {
    Column() {
      SymbolGlyph(img)
        .fontSize(24)
        .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
        .fontColor(this.currentIndex === tabIndex ? ['#FF1949'] : ['#99000000'])
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === tabIndex ? '#FF1949' : '#99000000')
        .margin({
          top: 4
        })
    }
    .onClick(() => {
      this.currentIndex = tabIndex;
    })
    .width('100%')
    .height(52)
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .clip(false)
    .border({
      width: { top: 1 },
      color: $r('sys.color.ohos_id_divider_color')
    })
  }

  build() {
    Row() {
      this.CustomTabBarItem($r('app.string.tab_home'), 0, $r('sys.symbol.house_fill'))
      this.CustomTabBarItem($r('app.string.tab_mine'), 1, $r('sys.symbol.person_crop_circle_fill'))
    }
    .height(48)
    .borderRadius(10)
    .margin({
      left: 8,
      right: 8
    })
  }
}