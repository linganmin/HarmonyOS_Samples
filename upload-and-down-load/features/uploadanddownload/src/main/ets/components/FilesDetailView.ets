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

import { fileUtils } from '../utils/FileUtils';

@Builder
export function FilesDetailViewBuilder() {
  FilesDetailView()
}

@Component
struct FilesDetailView {
  @StorageLink('files') files: Array<string> = [];
  @StorageLink('currentFolder') currentFolder: string = '';
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      this.FilesView()
    }
    .title(this.CustomTitle(this.currentFolder))
    .backgroundColor($r('app.color.light_gray'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .height('100%')
  }

  @Builder
  CustomTitle(title: string) {
    Row() {
      Text(title)
        .fontSize(20)
        .fontColor($r('app.color.text_normal'))
        .fontWeight(700)
        .margin({ left: 8 })
    }
    .width('100%')
  }


  @Builder
  FilesView() {
    Column() {
      List({ space: 12 }) {
        if (this.files.length === 0) {
          ListItem() {
            Text($r('app.string.folder_empty'))
              .fontSize(16)
              .width('100%')
              .margin({ top: 50 })
              .textAlign(TextAlign.Center)
          }
        }
        ForEach(this.files, (item: string) => {
          ListItem() {
            Text(decodeURIComponent(item))
              .fontSize(16)
              .width('100%')
          }
          .padding(12)
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
        }, (item: string, index: number) => index + item)
      }
      .padding({ left: 12, right: 12 })
      .layoutWeight(1)

      Column() {
        Button() {
          Image($r('app.media.ic_public_delete'))
            .objectFit(ImageFit.Cover)
            .size({ width: 24, height: 24 })
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor('#FF0000')
        .margin({ left: 5 })

        Text($r('app.string.clear_folder'))
          .fontSize(14)
          .fontColor($r('app.color.text_normal'))
          .opacity(0.6)
          .margin({ top: 8 })
      }
      .margin({ bottom: 24, top: 6 })
      .onClick(() => {
        fileUtils.clearFolder(this.currentFolder);
        this.files = [];
      })
    }
    .height('100%')
    .backgroundColor($r('app.color.light_gray'))
  }
}