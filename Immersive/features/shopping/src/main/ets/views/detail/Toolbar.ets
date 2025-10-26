/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { Breakpoint } from 'commons';

@Component
export struct Toolbar {
  @Consume('navPageInfos') navPageInfos: NavPathStack;
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  getPadding() {
    return this.getDataByBp({ 'sm': 16, 'md': 24 });
  }

  build() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(30)
        .height(30)
        .onClick(() => {
          this.navPageInfos.pop()
        })
      Blank()
      Image($r('app.media.ic_more'))
        .width(30)
        .height(30)
    }
    .width('100%')
    .padding({
      left: this.getPadding(),
      right: this.getPadding()
    })
  }
}
