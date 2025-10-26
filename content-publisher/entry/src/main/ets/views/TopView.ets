/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
import Logger from "../utils/Logger";

const TAG = 'TopView';

@Component
export struct TopView {
  private context: Context = this.getUIContext().getHostContext()!;
  private applicationContext = this.context.getApplicationContext();
  onPublish: () => void = () => {};

  exitApp() {
    try {
      this.applicationContext.killAllProcesses();
    } catch (e) {
      Logger.error(TAG, `Failed to killAllProcesses: ${e.message}`);
    }
  }

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(24)
        .padding(8)
        .margin({ right: 16 })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius('50%')
        .onClick(() => {
          this.exitApp();
        })
      Text($r('app.string.text_posts'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()
      Button($r('app.string.text_publish'))
        .height(32)
        .onClick(() => {
          this.onPublish();
        })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16
    })
    .margin({
      top: 16,
      bottom: 16
    })
  }
}