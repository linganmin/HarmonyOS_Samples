/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import Logger from '../../utils/Logger';

let logger = Logger.getLogger('[KnockShareApi]');

@Component
export default struct KnockShareApi {
  @Consume('pageStack') pageStack: NavPathStack;
  @State ShareStatus: boolean = false;
  @State rejectStatus: boolean = false;
  @State updateStatus: boolean = false;

  aboutToAppear(): void {
    logger.info('invoked');
    if (this.isNoListening()) {
      this.shareListening();
    }
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.on('onFocus', () => {
      if (this.isNoListening()) {
        this.shareListening();
      }
    });
    context.eventHub.on('onBackGround', () => {
      this.onBackGround();
    });
  }

  aboutToDisappear(): void {
    logger.info('aboutToDisappear invoked.');
    this.disablingAllListening();
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.off('onFocus');
    context.eventHub.off('onBackGround');
  }

  @Builder
  ShareMode() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.knock_purity'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.knock_share_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.ShareStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.knock_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.shareDisablingListening();
            })
          } else {
            Button($r('app.string.knock_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.shareListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.share_timer'))
            .width('100%')
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
        }.width('100%')
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ bottom: 20 })
  }

  @Builder
  RejectMode() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.knock_reject'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.reject_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.rejectStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.knock_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.rejectDisablingListening();
            })
          } else {
            Button($r('app.string.knock_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.rejectListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.reject_timer'))
            .width('100%')
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
        }.width('100%')
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ bottom: 20 })
  }

  @Builder
  UpdateMode() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.knock_white'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.delay_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.updateStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.knock_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.updateDisablingListening();
            })
          } else {
            Button($r('app.string.knock_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.updateListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.delay_description'))
            .width('100%')
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
        }.width('100%')
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.ShareMode()

          this.RejectMode()

          this.UpdateMode()
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height('100%')
    }
    .title($r("app.string.navigation_toolbar_function"))
  }

  private onBackGround() {
    logger.info('onBackGround invoked.');
    this.disablingAllListening();
  }

  private disablingAllListening() {
    if (this.ShareStatus) {
      this.shareDisablingListening();
    }
    if (this.rejectStatus) {
      this.rejectDisablingListening();
    }
    if (this.updateStatus) {
      this.updateDisablingListening();
    }
  }

  private purityCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleKnock3.jpg';
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.JPEG,
      uri: fileUri.getUriFromPath(filePath),
      thumbnailUri: fileUri.getUriFromPath(filePath),
    });
    sharableTarget.share(shareData);
  }

  private shareListening() {
    if (this.isNoListening()) {
      harmonyShare.on('knockShare', this.purityCallback);
      this.ShareStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.knock_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private shareDisablingListening() {
    harmonyShare.off('knockShare', this.purityCallback);
    this.ShareStatus = false;
  }

  private rejectCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    setTimeout(() => {
      sharableTarget.reject(harmonyShare.SharableErrorCode.DOWNLOAD_ERROR);
    }, 1000);
  }

  private rejectListening() {
    if (this.isNoListening()) {
      harmonyShare.on('knockShare', this.rejectCallback);
      this.rejectStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.knock_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private rejectDisablingListening() {
    harmonyShare.off('knockShare', this.rejectCallback);
    this.rejectStatus = false;
  }

  private updateCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
      title: contextFaker.resourceManager.getStringSync($r('app.string.white_title').id),
      description: contextFaker.resourceManager.getStringSync($r('app.string.white_description').id),
    });
    sharableTarget.share(shareData);
    setTimeout(() => {
      let filePath = contextFaker.filesDir + '/exampleKnock2.png';
      sharableTarget.updateShareData({
        thumbnailUri: fileUri.getUriFromPath(filePath),
      });
    }, 3000)
  }

  private updateListening() {
    if (this.isNoListening()) {
      harmonyShare.on('knockShare', this.updateCallback);
      this.updateStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.knock_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private updateDisablingListening() {
    harmonyShare.off('knockShare', this.updateCallback);
    this.updateStatus = false;
  }

  private isNoListening() {
    return !this.ShareStatus && !this.rejectStatus && !this.updateStatus;
  }
}