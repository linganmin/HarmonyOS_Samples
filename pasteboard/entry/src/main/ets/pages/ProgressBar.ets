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

import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { CommonConstants } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context: Context = uiContext?.getHostContext()!;
const VALUE_TEST_STRING_ELEMENT = 'a'.repeat(1 * 1024 * 1024 * 2);
let dstDir = context.distributedFilesDir + '/dst';

@Builder
export function ProgressBarBuilder() {
  ProgressBar();
}

@Component
export struct ProgressBar {
  @StorageProp('currentBreakpoint') curBp: string = CommonConstants.BREAK_POINT_SM;
  @State progressInfo: number = 0;
  private gradientColor: LinearGradient = new LinearGradient([{ color: '#0A59F7', offset: 0.5 },
    { color: '#0A59F7', offset: 1.0 }])
  controller: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controller };
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.doc_plaintext'))
              .fontSize(24)
          }
          .padding({
            top: $r('sys.float.padding_level8'),
            left: $r('sys.float.padding_level8')
          })
          .alignItems(VerticalAlign.Top)
          .width(CommonConstants.FULL_PERCENT)
          .height('20%')
          .borderRadius(20)
          .backgroundColor($r('app.color.start_window_background'))
          .margin({
            bottom: 16
          })

          Row() {
            if (this.progressInfo === 100) {
              SymbolGlyph($r('sys.symbol.doc_plaintext'))
                .fontSize(24)
            }
          }
          .padding({
            top: $r('sys.float.padding_level8'),
            left: $r('sys.float.padding_level8')
          })
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start)
          .width(CommonConstants.FULL_PERCENT)
          .height('20%')
          .borderRadius(20)
          .backgroundColor($r('app.color.start_window_background'))
        }

        Text($r('app.string.paste_progress')).fontSize(18).width('90%')
        Progress({ value: this.progressInfo, total: 100, type: ProgressType.Ring })
          .width(100)
          .style({ strokeWidth: 20 })
          .color(this.gradientColor)

        Column() {
          // [Start progress_paste]
          PasteButton()
          // [StartExclude progress_paste]
            .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
            .height($r('app.float.button_height'))
            // [EndExclude progress_paste]
            .onClick(async (event: ClickEvent, result: PasteButtonOnClickResult) => {
              if (result === PasteButtonOnClickResult.SUCCESS) {
                let systemPasteboard = pasteboard.getSystemPasteboard();
                let ProgressListener = (progress: pasteboard.ProgressInfo) => {
                  this.progressInfo = progress.progress;
                  hilog.info(0x0000, '[ProgressBar]', 'progressListener success, progress:' + progress.progress);
                  // [StartExclude progress_paste]
                  if (progress.progress === 100) {
                    setTimeout(()=>{
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.paste_complete'),
                        offset: {
                          dx: 0,
                          dy: -140
                        }
                      });
                    }, 300);
                  }
                  // [EndExclude progress_paste]
                }
                let dstUri: string = fileUri.getUriFromPath(dstDir);
                hilog.info(0x0000, '[ProgressBar]', 'progressBar' + 'dstUri: ' + dstUri + ' length: ' + dstUri.length);
                let params: pasteboard.GetDataParams = {
                  destUri: dstUri,
                  progressIndicator: pasteboard.ProgressIndicator.NONE,
                  progressListener: ProgressListener
                };
                try {
                  await systemPasteboard.getDataWithProgress(params).then((data) => {
                    hilog.info(0x0000, '[ProgressBar]', 'getDataWithProgress success');
                    fs.unlink(dstUri);
                  }).catch((error: BusinessError) => {
                    hilog.error(0x0000, '[ProgressBar]', 'getDataWithProgress failed,error: ' + JSON.stringify(error));
                  })
                } catch (err) {
                  hilog.error(0x0000, '[ProgressBar]',
                    'getDataWithProgress fail,err：' + err.code + ',message: ' + err.message);
                }
              }
            })
          // [Start progress_paste]

          Button($r('app.string.copy'))
            .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
            .height($r('app.float.button_height'))
            .margin({
              top: $r('app.float.button_space')
            })
            .onClick(async () => {
              // [Start progress_copy]
              let filesDir = uiContext?.getHostContext()!.filesDir;
              let fileFullName = filesDir + '/test1.txt';
              hilog.info(0x0000, '[ProgressBar]', 'The fileFullName of str is:' + fileFullName);
              let file = fs.openSync(fileFullName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
              let writeLen = fs.writeSync(file.fd, VALUE_TEST_STRING_ELEMENT);
              hilog.info(0x0000, '[ProgressBar]', 'The size of str is: ' + writeLen);
              fs.closeSync(file);
              let pasteData =
                pasteboard.createData(pasteboard.MIMETYPE_TEXT_URI, fileUri.getUriFromPath(fileFullName));

              let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
              await systemPasteBoard.setData(pasteData).catch((err: BusinessError) => {
                hilog.error(0x0000, '[ProgressBar]',
                  `Failed to set pastedata. Code: ${err.code}, message: ${err.message}`);
              });
              // [End progress_copy]

              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.copy_complete'),
                offset: {
                  dx: 0,
                  dy: -140
                }
              });
            })
        }
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        right: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8')
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .title($r('app.string.button_progress'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      bottom: $r('app.float.column_side_padding')
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}