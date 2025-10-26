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
import { Title } from '../views/Titles'

@Entry
@Component
struct IndexPage {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      Column() {
        Title($r('app.string.EntryAbility_label'))
        Blank()
        Button($r('app.string.multi_net_upload_slice_file'))
          .fontSize($r('app.float.size_16fp'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .borderRadius($r('app.float.size_20vp'))
          .height($r('app.float.size_40vp'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .onClick(async () => {
            this.pathStack.pushPathByName('UploadPage', null, false);
          })

        Button($r('app.string.multi_net_download_single_file'))
          .fontSize($r('app.float.size_16fp'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .borderRadius($r('app.float.size_20vp'))
          .height($r('app.float.size_40vp'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .margin({
            top: $r('app.float.size_12vp'),
            bottom: $r('app.float.size_16vp'),
          })
          .onClick(async () => {
            this.pathStack.pushPathByName('DownloadPage', null, false);
          })
      }
      .padding({
        left: $r('app.float.size_16vp'),
        right: $r('app.float.size_16vp')
      })
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}