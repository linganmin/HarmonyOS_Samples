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

import { pdfService, PdfView, pdfViewManager } from '@kit.PDFKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { NavBar } from '../component/NavBar';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constants/Constants';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'WatermarkPdfPage';

@Entry
@Component
struct WatermarkPdfPage {
  // [Start controller]
  private controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();
  // [StartExclude controller]
  @State hasWatermark: boolean = false;

  showSuccess() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.pdf_save_success'),
        duration: Constants.TOAST_DURATION
      });
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `showToast failed code=${err.code}, message=${err.message}`);
    }
  }

  getSandboxPath(path: string) {
    const context = this.getUIContext().getHostContext();
    const sandboxDir = context?.filesDir;
    return `${sandboxDir}/${path}`;
  }

  getPdfSandboxPath(): string {
    return this.getSandboxPath('input.pdf');
  }

  getAddedWatermarkPdfSandboxPath(): string {
    return this.getSandboxPath('output.pdf');
  }
  // [Start save_box]
  savePdfToSandbox(): string {
    const filePath = this.getPdfSandboxPath();
    try {
      fileIo.accessSync(filePath);
      const content: Uint8Array = this.getUIContext().getHostContext()?.resourceManager.getRawFileContentSync('watermark.pdf') as Uint8Array;
      const file = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, content.buffer);
      fileIo.closeSync(file.fd);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `savePdfToSandbox failed code=${err.code}, message=${err.message}`);
    }
    return filePath;
  }
  // [End save_box]
  // [EndExclude controller]
  aboutToAppear(): void {
    const filePath = this.savePdfToSandbox();
    this.controller.loadDocument(filePath);
  }
  // [StartExclude controller]
  // [Start mark_info]
  getWatermarkInfo() {
    const watermarkInfo: pdfService.TextWatermarkInfo = new pdfService.TextWatermarkInfo();
    watermarkInfo.watermarkType = pdfService.WatermarkType.WATERMARK_TEXT;
    watermarkInfo.content = 'This is Watermark';
    watermarkInfo.textSize = 32;
    watermarkInfo.textColor = 200;
    watermarkInfo.rotation = 45;
    watermarkInfo.opacity = 0.3;
    return watermarkInfo;
  }
  // [End mark_info]
  // [Start add_mark]
  addWatermark() {
    const filePath = this.getPdfSandboxPath();
    let pdfDocument: pdfService.PdfDocument = new pdfService.PdfDocument();
    pdfDocument.loadDocument(filePath);
    pdfDocument.addWatermark(this.getWatermarkInfo(), 0, pdfDocument.getPageCount(), true, true);
    const watermarkFilePath = this.getAddedWatermarkPdfSandboxPath();
    pdfDocument.saveDocument(watermarkFilePath);
    this.showInPdfView(watermarkFilePath);
  }
  // [End add_mark]
  // [Start show_mark]
  async showInPdfView(filePath: string) {
    this.hasWatermark = true;
    // release before reload avoid crash.
    this.controller.releaseDocument();
    await this.controller.loadDocument(filePath);
    this.controller.setPageFit(pdfService.PageFit.FIT_WIDTH);
  }
  // [End show_mark]
  async savePdf() {
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = ['watermark.pdf'];
    const documentPicker = new picker.DocumentViewPicker(this.getUIContext().getHostContext() as common.UIAbilityContext);
    const saveResult = await documentPicker.save(documentSaveOptions);
    this.copyFileSync(this.getAddedWatermarkPdfSandboxPath(), saveResult[0]);
    this.showSuccess();
  }

  copyFileSync(srcPath: string, destPath: string) {
    try {
      const srcFile = fileIo.openSync(srcPath, fileIo.OpenMode.READ_WRITE);
      const destFile = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE);
      fileIo.copyFileSync(srcFile.fd, destFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `copyFileSync failed code=${err.code}, message=${err.message}`);
    }
  }
  // [EndExclude controller]
  build() {
    // [StartExclude controller]
    Column() {
      NavBar()
      Stack({ alignContent: Alignment.Bottom }) {
        // [EndExclude controller]
        PdfView({
          controller: this.controller,
          pageFit: pdfService.PageFit.FIT_WIDTH
        })
          // [StartExclude controller]
          .id('pdfview_app_view')
          .layoutWeight(1)
        Row() {
          if (!this.hasWatermark) {
            Button($r('app.string.button_text_add_watermark'))
              .height(40)
              .width('100%')
              .onClick(() => this.addWatermark())
          } else {
            SaveButton()
              .height(40)
              .width('100%')
              .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
                if (result === SaveButtonOnClickResult.SUCCESS) {
                  try {
                    this.savePdf();
                  } catch (err) {
                    hilog.error(0x0000, TAG, 'createAsset failed, error:', err);
                  }
                } else {
                  hilog.error(0x0000, TAG, 'SaveButtonOnClickResult createAsset failed');
                }
              })
          }
        }
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }
  // [StartExclude controller]
  // [End controller]
}