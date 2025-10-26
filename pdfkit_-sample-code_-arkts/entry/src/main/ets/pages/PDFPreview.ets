import { pdfService } from '@kit.PDFKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { Font } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'PDFPreview';

@Entry
@Component
struct PDFPreview {
  @State filePath: string = (this.getUIContext().getRouter().getParams() as Record<string, string>)['src'];
  @State pageCount: number = 0;
  @State pageIndex: number = 0;
  @State pixelMap: image.PixelMap | undefined = undefined;
  private document: pdfService.PdfDocument = new pdfService.PdfDocument;

  // 打开选择的PDF文件
  openFile() {
    let t0 = Date.now();
    this.document.loadDocument(this.filePath, '');
    let t1 = Date.now();
    hilog.info(0x0000, TAG, `loadDocument time: ${t1 - t0} ms`);
  }

  // 提示框
  showDialog(title: string, msg: string) {
    this.getUIContext().showAlertDialog({
      title: title,
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      confirm: {
        value: '关闭',
        action: () => {
          hilog.info(0x0000, TAG, 'Button-clicking callback');
        }
      },
    });
  }

  aboutToAppear() {
    this.openFile(); // 打开文件
    let page: pdfService.PdfPage = this.document.getPage(0); // 默认第一页
    this.pixelMap = page.getPagePixelMap(); // 设置Image组件参数
  }

  aboutToDisappear() {
    this.document.releaseDocument();
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .fontSize(12)
          .onClick(() => {
            this.getUIContext().getRouter().back({ url: 'pages/Index' });
          })
        Button('上一页')
          .fontSize(12)
          .onClick(async () => {
            this.pageIndex--;
            if (this.pageIndex < 0) {
              this.showDialog('提示', '已是第一页');
              this.pageIndex++;
              return;
            }
            let page: pdfService.PdfPage = this.document.getPage(this.pageIndex); // 设置页面为上一页
            this.pixelMap = page.getPagePixelMap(); // 设置Image组件参数
          }).margin({ left: 15 })
        Button('下一页')
          .fontSize(12)
          .margin({ left: 15 })
          .onClick(async () => {
            this.pageIndex++;
            if (this.pageIndex >= this.document.getPageCount()) {
              this.showDialog('提示', '已是最后一页');
              this.pageIndex--;
              return;
            }
            let page: pdfService.PdfPage = this.document.getPage(this.pageIndex); // 设置页面为下一页
            this.pixelMap = page.getPagePixelMap(); // 设置Image组件参数
          })
      }
      Row() {
        // 显示内容
        Image(this.pixelMap)
          .width('80%')
          .height('80%')
          .objectFit(ImageFit.Contain)
          .border({ width: 1, color: Color.Blue })
      }
      Row() {
        Button('PDF转图片')
          .fontSize(12)
          .margin({ left: 15 })
          .onClick(() => {
            const pageCount: number = this.document.getPageCount();
            if (pageCount > 20) { // 页面数过多的PDF会导致convertToImage执行时间过长，当前将可转图片的PDF页面数限制为20页
              this.showDialog('PDF转图片失败', 'PDF页面数过多');
              return;
            }

            let context = this.getUIContext().getHostContext();
            if (!context) {
              hilog.error(0x0000, TAG, 'Get context failed');
              return;
            }
            let outputPath: string = context.filesDir + '/output_images';
            try {
              fs.mkdirSync(outputPath);
            } catch (e) {
              let err = e as BusinessError;
              hilog.error(0x0000, TAG, `Create directory failed, error code: ${err.code}, error message: ${err.message}`);
            }
            const result: boolean = this.document.convertToImage(outputPath, 0); // 将PDF文件转为图片
            if (result) {
              this.showDialog('PDF转图片成功', `存储路径为：${outputPath}`);
            } else {
              this.showDialog('PDF转图片失败', '请检查用户权限');
            }
          })
        Button('添加示例文字')
          .fontSize(12)
          .margin({ left: 15 })
          .onClick(async () => {
            let page: pdfService.PdfPage = this.document.getPage(this.pageIndex);
            let textStyle: pdfService.TextStyle = new pdfService.TextStyle;
            let sysFont: Font = this.getUIContext().getFont();
            let fontList: Array<string> = sysFont.getSystemFontList();
            let fontInfo = new pdfService.FontInfo();
            if (fontList.length > 0) {
              fontInfo.fontPath = sysFont.getFontByName(fontList[0]).path;
            } else {
              // 确保字体路径存在
              fontInfo.fontPath = '/system/fonts/HarmonyOS_Sans.ttf';
            }
            textStyle.fontInfo = fontInfo;
            textStyle.textSize = 20;
            page.addTextObject('中文HelloWold123', 0, 0, textStyle); // 添加示例文字
            this.pixelMap = page.getPagePixelMap();
          })
        Button('保存文件')
          .fontSize(12)
          .margin({ left: 15 })
          .onClick(async () => {
            let context = this.getUIContext().getHostContext();
            if (!context) {
              hilog.error(0x0000, TAG, 'Get context failed');
              return;
            }
            let dir: string = context.filesDir;
            let savePath: string = dir + '/output.pdf';
            const result: boolean = this.document.saveDocument(savePath); // 保存文件
            if (result) {
              this.showDialog('PDF保存成功', `存储路径：${savePath}`);
            } else {
              this.showDialog('PDF保存失败', '请检查用户权限');
            }
          })
      }
    }
    .width('100%')
  }
}

