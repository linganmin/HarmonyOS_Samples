/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { DocType, DocumentScanner, SaveOption } from '@kit.VisionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';

const TAG: string = 'SheetExtractionPage';

@Component
export struct SheetExtractionPage {
  @Consume('pathStack') pathStack: NavPathStack;

  build() {
    Stack({ alignContent: Alignment.Top }) {
      //The document scanning control is embedded in the blank page.
      //The control provides the table extraction capability.
      DocumentScanner({
        scannerConfig: {
          //The DocType.SHEET attribute needs to be configured to support table extraction.
          supportType: [DocType.DOC, DocType.SHEET],
          isGallerySupported: true
        },
        onResult: (code: number, saveType: SaveOption, uris: string[]) => {
          //200 indicates success, SaveOption.EXCEL indicates that the Excel file is returned.
          //and uris indicates the file path.
          if (code === 200 && saveType == SaveOption.EXCEL) {
            this.saveToExcel(uris[0]);
          }
          this.pathStack.pop();
        }
      })
        .size({ width: '100%', height: '100%' })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * Save File to the Files
   * @param uri
   * @returns
   */
  async saveToExcel(uri: string): Promise<string> {
    let originFile: fs.File | undefined = undefined;
    let targetFile: fs.File | undefined = undefined;
    let documentSaveOptions = new picker.DocumentSaveOptions;
    documentSaveOptions.newFileNames = [`DocumentScanner_${new Date().getTime()}`];
    documentSaveOptions.fileSuffixChoices = ['.xlsx'];
    let documentViewPicker = new picker.DocumentViewPicker(getContext(this));
    let saveUri = new Promise<string>(async (resolve, reject) => {
      documentViewPicker.save(documentSaveOptions).then((saveResult: Array<string>) => {
        let pdfUri = saveResult[0];
        try {
          originFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
          targetFile = fs.openSync(pdfUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          fs.copyFileSync(originFile.fd, targetFile.fd);
          promptAction.showToast({
            message: 'The file is saved successfully.',
            alignment: Alignment.Center
          });
          return resolve(pdfUri);
        } catch (error) {
          hilog.error(0x0001, TAG, `error: ${error}`);
          reject('');
        } finally {
          fs.closeSync(originFile);
          fs.closeSync(targetFile);
        }
      })
    })
    return saveUri;
  }
}