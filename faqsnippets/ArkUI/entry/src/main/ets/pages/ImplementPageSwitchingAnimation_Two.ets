/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何实现上下切换的页面间跳转动画
*/

// [Start implement_page_switching_animation_two]
// Page1.ets
@Entry
@Component
struct PageTransition2 {
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Navigation(this.pageInfos) {
        Image($r('app.media.ic_banner02')).width('100%').height(200) // The image is stored in the media folder
      }
    }.height('100%').width('100%')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 500, curve: Curve.Linear }).slide(SlideEffect.Bottom)
    PageTransitionExit({ duration: 500, curve: Curve.Ease }).slide(SlideEffect.Bottom)
  }
}
// [End implement_page_switching_animation_two]