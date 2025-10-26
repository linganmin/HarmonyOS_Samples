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
import CommonConstant from "../../utils/CommonConstant"

@Builder
export function SkipActionBuilder(name: string, param: Object) {
  SkipAction();
}

@Component
export struct SkipAction {
  pageInfos: NavPathStack = new NavPathStack();
  @State skipParams: string = '';

  build() {
    NavDestination() {
      Column() {
        Text(this.skipParams)
          .fontSize($r('app.float.font_size_large'))
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: $r('app.float.SkipActionMarginBottom') })
      }.width(CommonConstant.FULL_LENGTH).height(CommonConstant.FULL_LENGTH)
    }
    .title(CommonConstant.SKIP_ACTION_TITLE)
    .backgroundColor($r('app.color.SkipActionBgColor'))
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true;
    }).onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.skipParams = this.pageInfos.getParamByIndex(1) as string;
    })
  }
}