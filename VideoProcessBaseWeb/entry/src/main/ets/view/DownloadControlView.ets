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

import { webview } from "@kit.ArkWeb";
import { WebDownloadManager } from "../utils/WebDownloadManager";

class MyButtonAttributeModify implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.fontColor($r('sys.color.font_emphasize'));
    instance.width(88);
    instance.height(21);
    instance.buttonStyle(ButtonStyleMode.TEXTUAL);
    instance.stateEffect(false);
  }
}

@Component
struct DownloadControlView {
  @State webDownloadManager: WebDownloadManager = WebDownloadManager.getInstance();
  private myButtonAttributeModify = new MyButtonAttributeModify();

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.downloading'))
            .fontColor('rgba(0,0,0,0.9)')
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(19)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.webDownloadManager.downloadProgress + '%')
            .margin({ left: 8 })
            .fontColor('rgba(0,0,0,0.6)')
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(19)
        }
        .width(244)
        .height(20)
        .margin({ bottom: 4 })

        Row() {
          Progress({
            value: this.webDownloadManager.downloadProgress,
            total: 100,
            type: ProgressType.Linear
          })
            .width(244)
          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize(24)
            .fontColor(['rgba(0,0,0,0.4)'])
            .margin({ left: 12 })
            .onClick(() => {
              this.webDownloadManager.cancel();
              const contentNode: ComponentContent<Object> = AppStorage.get('contentNode') as ComponentContent<Object>;
              this.getUIContext().getPromptAction().closeCustomDialog(contentNode);
              this.webDownloadManager.clearProgress();
            })
        }
        .width('100%')
        .height(24)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        if (this.webDownloadManager.taskStatus === webview.WebDownloadState.IN_PROGRESS ||
          this.webDownloadManager.taskStatus === webview.WebDownloadState.PENDING
        ) {
          Button($r('app.string.pause'))
            .attributeModifier(this.myButtonAttributeModify)
            .onClick(() => this.webDownloadManager.pause())
        } else if (this.webDownloadManager.taskStatus === webview.WebDownloadState.PAUSED) {
          Button($r('app.string.continue_download'))
            .attributeModifier(this.myButtonAttributeModify)
            .onClick(() => this.webDownloadManager.unpause())
        }
      }
      .padding({
        top: 9,
        right: 16,
        bottom: 9,
        left: 16
      })
    }
    .width(328)
    .height(136)
    .borderRadius(32)
    .backgroundColor('rgba(255,255,255,0.8)')
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THIN)
    .padding(24)
  }
}

@Builder
export function downloadControlBuilder() {
  DownloadControlView()
}