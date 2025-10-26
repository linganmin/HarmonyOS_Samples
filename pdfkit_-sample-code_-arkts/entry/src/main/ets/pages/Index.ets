import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'Index';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'

  // 将资源文件复制到沙盒中并进入下一个页面
  copyResourceFileAndJump(): void {
    try {
      let context = this.getUIContext().getHostContext();
      if (!context) {
        hilog.error(0x0000, TAG, 'Get context failed');
        return;
      }
      let dir = context.filesDir;
      let filePath = dir + '/input.pdf';
      let res = fs.accessSync(filePath);
      if (!res) {
        hilog.info(0x0000, TAG, 'File does not exist');
        let content = context.resourceManager.getRawFileContentSync('rawfile/pdf_reference.pdf');
        let fdSand = fs.openSync(filePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
        fs.writeSync(fdSand.fd, content.buffer);
        fs.closeSync(fdSand.fd);
      }
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/PDFPreview',
        params: {
          src: filePath,
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Router push url failed, error code: ${err.code}, error message: ${err.message}`);
      })
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `Copy resource file failed, error code: ${err.code}, error message: ${err.message}`);
    }
  }

  // 将URI对应的PDF文件复制到沙盒中并进入到下一个页面
  copyURIAndJump(uri: string): void {
    try {
      let context = this.getUIContext().getHostContext();
      if (!context) {
        hilog.error(0x0000, TAG, 'Get context failed');
        return;
      }
      let dir = context.filesDir;
      let file = dir + '/temp.pdf';
      hilog.info(0x0000, TAG, `Copy file to sandbox, file path: ${file}`);
      let sourceFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(sourceFile.fd, file);
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/PDFPreview',
        params: {
          src: file,
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Router push url failed, error code: ${err.code}, error message: ${err.message}`);
      });
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `Copy file to sandbox failed, error code: ${err.code}, error message: ${err.message}`);
    }
  }

  build() {
    Row() {
      Column() {
        Button('打开电脑里的PDF文件')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // 拷贝文件到沙盒中，并push到下一个PDFPreview页面，展示功能
            const documentSelectOptions = new picker.DocumentSelectOptions();
            documentSelectOptions.maxSelectNumber = 1; // 选择文档的最大数目
            documentSelectOptions.fileSuffixFilters = ['.pdf']; // 选择文件的后缀类型
            let uris: Array<string> = [];
            const documentViewPicker = new picker.DocumentViewPicker(); // 创建文件选择器实例
            documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
              uris = documentSelectResult;
              let uri = uris[0];
              this.copyURIAndJump(uri)
              hilog.info(0x0000, TAG, `documentViewPicker.select file succeed and URI is: ${uri}`);
            }).catch((err: BusinessError) => {
              hilog.error(0x0000, TAG, `Invoke documentViewPicker.select failed, error code: ${err.code}, error message: ${err.message}`);
            })
          })
        Button('打开资源PDF文件')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 15 })
          .onClick(() => {
            this.copyResourceFileAndJump()
          })
        Button('打开PdfView文件预览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 15 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/PDFView'
            }).catch((err: BusinessError) => {
              hilog.error(0x0000, TAG, `Router push url failed, error code: ${err.code}, error message: ${err.message}`);
            })
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}