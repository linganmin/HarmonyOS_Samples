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
/**
 * 最佳实践：Native侧实现文件访问开发实践
 */
import { promptAction } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
// [Start file_access]
// [Start file_access_so]
// [Start file_access_so1]
import FileAccess from 'libfile_access.so';
// [End file_access_so1]
// [End file_access_so]
// [End file_access]
import readFile from '../common/utils/ReadFile';
import Logger from '../common/utils/Logger';
import { CreateFileByPicker, WriteFileByPicker, ReadFileByPicker } from '../common/utils/FileOperate';
import { FileNameList } from '../model/FileNameModel';

@Entry
@Component
struct Index {
  // [Start sand_box]
  private sandboxFilesDir: string = this.getUIContext().getHostContext()!.filesDir;
  // [End sand_box]
  // [Start resMgr]
  private resMgr: resourceManager.ResourceManager = this.getUIContext().getHostContext()!.resourceManager;
  // [End resMgr]
  @Styles
  customButtonStyle() {
    .width('288vp')
    .height('40vp')
  }

  customToast(str: string) {
    Logger.info('show file contents:' + str);
    try {
      this.getUIContext().getPromptAction().showToast({
        message: str,
        duration: 2000,
        bottom: '80vp',
        backgroundColor: Color.White,
        backgroundBlurStyle: BlurStyle.NONE
      })
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      Logger.error(`showToast args error code is ${code}, message is ${message}`);
    }
  }

  build() {
    Column({ space: 12 }) {
      Button($r('app.string.button_sandbox'))
        .customButtonStyle()
        .onClick(() => {
          let content = this.getUIContext().getHostContext()!.resourceManager
            .getStringByNameSync('file_content_sandbox');
          // [Start trans_box_path]
          FileAccess.transferSandboxPath(this.sandboxFilesDir, content);
          // [End trans_box_path]
          this.customToast(readFile(this.sandboxFilesDir + '/' + FileNameList[0]));
        })

      Button($r('app.string.button_splice'))
        .customButtonStyle()
        .onClick(() => {
          let content = this.getUIContext().getHostContext()!.resourceManager
            .getStringByNameSync('file_content_splice');
          // [Start file_path]
          FileAccess.splicePath(content);
          // [End file_path]
          this.customToast(readFile(this.sandboxFilesDir + '/' + FileNameList[1]));
        })

      Button($r('app.string.button_resMgr'))
        .customButtonStyle()
        .onClick(() => {
          // [Start raw_file_con]
          let rawfileContext = FileAccess.transferResourceMgr(this.resMgr, FileNameList[2]);
          // [End raw_file_con]
          this.customToast(rawfileContext.toString());
        })

      Button($r('app.string.button_create'))
        .customButtonStyle()
        .onClick(async () => {
          CreateFileByPicker(this.getUIContext().getHostContext()!, FileNameList[3]);
        })

      Button($r('app.string.button_write'))
        .customButtonStyle()
        .onClick(async () => {
          let content = this.getUIContext().getHostContext()!.resourceManager
            .getStringByNameSync('file_content_picker');
          await WriteFileByPicker(content).then((value: string) => {
            setTimeout(() => {
              this.customToast(value);
            }, 200);
          });
        })

      Button($r('app.string.button_read'))
        .customButtonStyle()
        .margin({ bottom: '16vp' })
        .onClick(async () => {
          await ReadFileByPicker().then((value: string) => {
            setTimeout(() => {
              this.customToast(value);
            }, 200);
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0XF1F3F5)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}