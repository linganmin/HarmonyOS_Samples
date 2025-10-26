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

import { FIleShow } from '../view/FileShow';
import { RdbDataShow } from '../view/RdbDataShow';
import { XMLDataShow } from '../view/XMLDataShow';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'rdbShow') {
      RdbDataShow()
    } else if (name === 'fileShow') {
      FIleShow()
    } else if (name === 'XMLShow') {
      XMLDataShow()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 12 }) {
        Button($r('app.string.database_show'))
          .width('100%')
          .fontSize(16)
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'rdbShow' });
          })
        Button($r('app.string.file_show'))
          .width('100%')
          .fontSize(16)
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'fileShow' });
          })
        Button($r('app.string.xml_show'))
          .width('100%')
          .fontSize(16)
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'XMLShow' });
          })
      }
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
    }
    .title($r('app.string.backup_recover'))
    .hideTitleBar(false)
    .hideBackButton(false)
    .hideToolBar(true)
    .navDestination(this.PageMap)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}