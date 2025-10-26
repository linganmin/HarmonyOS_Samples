import scanFileGuard from '../svcability/ScanFileGuard';

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Text($r('app.string.Demo_title'))
          .fontWeight(FontWeight.Bold)
        Blank();
        Row() {
          Button($r('app.string.scanCommonDir'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.getFileList();
            })
          Button($r('app.string.scanAllFiles'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.getAllFileList();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.openFile'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.getFileFd();
            })
          Button($r('app.string.deleteFile'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testDeleteKiaFile();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.setFileTags'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testSetKiaFileTag();
            })
          Button($r('app.string.queryFileTags'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testQueryKiaFileTag();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.setKIAFileList'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testSetKiaList();
            })
          Button($r('app.string.setAddKIAFileList'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testUpdateKiaList();
            })
          Button($r('app.string.setDeleteKIAFileList'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testDeleteKiaList();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.updatePolicy'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.updateNetRejectPolicy();
            })
          Button($r('app.string.updateIncrementalPolicy'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.updateIncrementalNetRejectPolicy();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.queryFileUri'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testQueryFileUri();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.subscriptionKIAEvent'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.testSubscriptionKIAEvent();
            })
          Button($r('app.string.UnsubscriptionKIAEvent'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.unSubscriptionKIAEvent();
            })
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.setKiaWatermarkImage'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              scanFileGuard.setKiaWatermarkImage();
            })
        }.width('100%').justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .height('100%')
  }
}