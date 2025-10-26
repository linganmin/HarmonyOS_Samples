import { pdfService, pdfViewManager, PdfView } from '@kit.PDFKit'
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'PDFView';

@Entry
@Component
struct PDFView {
  private controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();

  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext();
    if (!context) {
      hilog.error(0x0000, TAG, 'Get context failed');
      return;
    }

    let dir: string = context.filesDir
    // 确保rawfile里面有pdf文件
    let filePath: string = dir + '/pdf_reference.pdf';
    try {
      fileIo.accessSync(filePath);
      let content: Uint8Array = context.resourceManager.getRawFileContentSync('rawfile/pdf_reference.pdf');
      let fdSand = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(fdSand.fd, content.buffer);
      fileIo.closeSync(fdSand.fd);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `fs operation failed, error code: ${err.code}, error message: ${err.message}`);
    }

    (async () => {
      let loadResult: pdfService.ParseResult = await this.controller.loadDocument(filePath);
      if (loadResult === pdfService.ParseResult.PARSE_SUCCESS) {
        hilog.info(0x0000, TAG, 'PDF load successfully');
      }
    })();
  }

  @Builder
  Back() {
    Button('返回')
      .width(100)
      .fontSize(20)
      .padding({left: 30, top: 8})
      .margin({left: 10, top: 10})
      .onClick(() => {
        this.getUIContext().getRouter().back({ url: 'pages/Index' });
      })
  }

  build() {
    Row() {
      PdfView({
        controller: this.controller,
        pageFit: pdfService.PageFit.FIT_WIDTH,
        showScroll: true
      })
        .id('pdfview_app_view')
        .layoutWeight(1)
        .overlay(this.Back(), {
          align: Alignment.TopStart
        })
    }
    .width('100%')
    .height('100%')
  }
}