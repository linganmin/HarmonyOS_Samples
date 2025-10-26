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
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { CommonConstants } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function PasteBoardBuilder() {
  PasteBoard();
}

@Component
export struct PasteBoard {
  @StorageProp('currentBreakpoint') curBp: string = CommonConstants.BREAK_POINT_SM;
  // Copying content area controller.
  pasteController: RichEditorStyledStringController = new RichEditorStyledStringController();
  pasteOptions: RichEditorStyledStringOptions = { controller: this.pasteController };
  pasteTextController: RichEditorStyledStringController = new RichEditorStyledStringController();
  pasteTextOptions: RichEditorStyledStringOptions = { controller: this.pasteTextController };
  pastePixelMapController: RichEditorController = new RichEditorController();
  pastePixelMapOptions: RichEditorOptions = { controller: this.pastePixelMapController };
  // Paste content area controller.
  editController: RichEditorStyledStringController = new RichEditorStyledStringController();
  editOption: RichEditorStyledStringOptions = { controller: this.editController };
  pathStack: NavPathStack = new NavPathStack();
  uiContext = this.getUIContext();

  aboutToAppear() {
    const context: Context = this.uiContext.getHostContext()!;
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    resourceMgr.getMediaContent($r('app.media.startIcon').id).then((imageArray) => {
      let pixelBuffer = imageArray.buffer.slice(0)
      const imageSource: image.ImageSource = image.createImageSource(pixelBuffer);
      let mutableStyledString1 = new MutableStyledString('012345');
      imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
        let mutableStyledString2 = new MutableStyledString(new ImageAttachment({
          value: pixelMap,
          size: {
            width: '57px',
            height: '57px'
          }
        }));
        mutableStyledString1.appendStyledString(mutableStyledString2);
        let mutableStyledString3 = new MutableStyledString('56789');
        mutableStyledString1.appendStyledString(mutableStyledString3);
        this.editController.setStyledString(mutableStyledString1);
      });
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, '[PasteBoard]', `getMediaContent error.code: ${error.code}, message: ${error.message}`);
    })
  }

  async handlerPasteHtmlData(html: string) {
    if (html.trim() === '') {
      return;
    }

    try {
      const styledString: StyledString = await StyledString.fromHtml(html);
      this.pasteController.setStyledString(styledString);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, '[PasteBoard]', `fromHtml failed. Code is ${err.code}, message is ${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: $r('sys.float.padding_level6') }) {
          RichEditor(this.editOption)
            .width(CommonConstants.FULL_PERCENT)
            .height('18%')
            .borderRadius(20)
            .backgroundColor($r('app.color.start_window_background'))

          RichEditor(this.pasteOptions)
            .width(CommonConstants.FULL_PERCENT)
            .height('18%')
            .borderRadius(20)
            .backgroundColor($r('app.color.start_window_background'))
            .placeholder($r('app.string.paste_image_text'), { fontColor: '#66000000' })

          RichEditor(this.pasteTextOptions)
            .width(CommonConstants.FULL_PERCENT)
            .height('18%')
            .borderRadius(20)
            .backgroundColor($r('app.color.start_window_background'))
            .placeholder($r('app.string.paste_text'), { fontColor: '#66000000' })

          RichEditor(this.pastePixelMapOptions)
            .width(CommonConstants.FULL_PERCENT)
            .height('18%')
            .borderRadius(20)
            .backgroundColor($r('app.color.start_window_background'))
            .placeholder($r('app.string.paste_image'), { fontColor: '#66000000' })
        }

        Column() {
          // [Start pasteboard_paste_1]
          // [Start pasteboard_paste_2]
          PasteButton()
          // [StartExclude pasteboard_paste_1]
          // [StartExclude pasteboard_paste_2]
            .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
            .height($r('app.float.button_height'))
            // [EndExclude pasteboard_paste_1]
            // [EndExclude pasteboard_paste_2]
            .onClick(async (_event: ClickEvent, result: PasteButtonOnClickResult) => {
              if (result === PasteButtonOnClickResult.SUCCESS) {
                try {
                  // [StartExclude pasteboard_paste_1]
                  // [StartExclude pasteboard_paste_2]
                  this.pasteController.setStyledString(new StyledString(''));
                  // [EndExclude pasteboard_paste_1]
                  // [EndExclude pasteboard_paste_2]
                  let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
                  let gettedData = await systemPasteBoard.getData();
                  // [StartExclude pasteboard_paste_1]
                  if (gettedData.getRecordCount() <= 0) {
                    return;
                  }

                  let isPastedSuccess: boolean = false;
                  for (let i = 0; i < gettedData.getRecordCount(); i++) {
                    let record = gettedData.getRecord(i);
                    let targetTypes: string[] = [
                      pasteboard.MIMETYPE_TEXT_HTML,
                      pasteboard.MIMETYPE_TEXT_PLAIN,
                      pasteboard.MIMETYPE_PIXELMAP
                    ];
                    let tmpTypes: string[] = record.getValidTypes(targetTypes);
                    for (let j = 0; j < tmpTypes.length; j++) {
                      switch (tmpTypes[j]) {
                        case pasteboard.MIMETYPE_TEXT_HTML: {
                          let htmlRecord = await record.getData(pasteboard.MIMETYPE_TEXT_HTML);
                          htmlRecord = htmlRecord as string;
                          this.handlerPasteHtmlData(htmlRecord);
                          isPastedSuccess = true;
                          break;
                        }
                        case pasteboard.MIMETYPE_TEXT_PLAIN: {
                          let textRecord = await record.getData(pasteboard.MIMETYPE_TEXT_PLAIN);
                          textRecord = textRecord as string;
                          let styledString = new StyledString(textRecord);
                          this.pasteTextController.setStyledString(styledString);
                          isPastedSuccess = true;
                          break;
                        }
                        case pasteboard.MIMETYPE_PIXELMAP: {
                          let pixelMapRecord = await record.getData(pasteboard.MIMETYPE_PIXELMAP);
                          pixelMapRecord = pixelMapRecord as PixelMap;
                          this.pastePixelMapController.deleteSpans();
                          this.pastePixelMapController.addImageSpan(pixelMapRecord, {
                            imageStyle: {
                              size: ['57px', '57px']
                            }
                          });
                          isPastedSuccess = true;
                          break;
                        }
                        default:
                          break;
                      }
                    }
                  }
                  // [StartExclude pasteboard_paste_2]
                  if (isPastedSuccess) {
                    this.getUIContext().getPromptAction().showToast({
                      message: $r('app.string.paste_complete'),
                      offset: {
                        dx: 0,
                        dy: -140
                      }
                    });
                  }
                  // [EndExclude pasteboard_paste_1]
                  // [EndExclude pasteboard_paste_2]
                } catch {
                  (err: BusinessError) => {
                    hilog.error(0x0000, '[PasteBoard]', `getData error.code: ${err.code}, message: ${err.message}`);
                  }
                }
              }
            })
          // [End pasteboard_paste_1]
          // [End pasteboard_paste_2]

          Button($r('app.string.copy'))
            .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
            .height($r('app.float.button_height'))
            .margin({
              top: $r('app.float.button_space')
            })
            .onClick(async () => {
              // [Start pasteboard_copy]
              let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, '');
              let record: pasteboard.PasteDataRecord = pasteData.getRecord(0);

              let styledString: StyledString = this.editController.getStyledString();
              let html: string = StyledString.toHtml(styledString);

              record.addEntry(pasteboard.MIMETYPE_TEXT_HTML, html);
              record.addEntry(pasteboard.MIMETYPE_TEXT_PLAIN, styledString.getString());
              const htmlSpans = this.pastePixelMapController.fromStyledString(styledString);
              if (!htmlSpans || htmlSpans.length < 1) {
                return;
              }
              for (let i = 0; i < htmlSpans.length; i++) {
                const span = htmlSpans[i];
                if (!!(span as RichEditorImageSpanResult)?.valuePixelMap) {
                  const pixelMap = (span as RichEditorImageSpanResult)?.valuePixelMap;
                  record.addEntry(pasteboard.MIMETYPE_PIXELMAP, pixelMap);
                  break;
                }
              }

              let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
              await systemPasteBoard.setData(pasteData).catch((err: BusinessError) => {
                hilog.error(0x0000, '[PasteBoard]',
                  `Failed to set pastedata. Code: ${err.code}, message: ${err.message}`);
              });
              // [End pasteboard_copy]
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
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .padding({
        right: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8')
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .title($r('app.string.button_mixed'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      bottom: $r('app.float.column_side_padding')
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}