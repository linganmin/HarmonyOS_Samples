import FileTransferService from '../svcability/fileTransferService';

@Entry
@Component
struct Index {
  build() {
    Column() {

      Image($r('app.media.app_icon1'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
        .borderRadius(75)
        .margin({ bottom: 30 })

      Text($r('app.string.Demo_title_fileTransfer'))
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 30 })

      Row() {
        Button($r('app.string.getAuditInfo'))
          .width(200)
          .height(50)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .fontSize(18)
          .margin(5)
          .onClick(() => {
            FileTransferService.GetAuditInfo();
          })

        Button($r('app.string.setAuditInfo'))
          .width(200)
          .height(50)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .fontSize(18)
          .onClick(() => {
            FileTransferService.SetAuditInfo();
          })
      }

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}