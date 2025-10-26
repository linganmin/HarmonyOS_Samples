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

import { fileIo } from '@kit.CoreFileKit';

@Component
export struct FIleShow {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State names: string[] = [];

  build() {
    NavDestination() {
      Column() {
        List({ space: 12 }) {
          ForEach(this.names, (item: number) => {
            ListItem() {
              Text('' + item)
                .width('100%')
                .fontSize(16)
                .borderRadius(10)
            }
          }, (item: string) => item)
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 16
      })
    }
    .title($r('app.string.file_list'))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      let targetPath: string = this.getUIContext().getHostContext()!.filesDir + '/targetFiles';
      fileIo.listFile(targetPath).then((filenames: Array<string>) => {
        this.names = filenames;
      });
    })
  }
}