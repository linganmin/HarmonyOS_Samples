/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[GesturesShare]');

@Component
export default struct KnockShare {
  @Prop windowId: number | undefined = undefined;
  @State message: ResourceStr = $r('app.string.gesture_title');
  @State purityStatus: boolean = false;
  @State immersiveStatus: boolean = false;
  @State whiteStatus: boolean = false;

  aboutToAppear(): void {
    if (this.isNoListening()) {
      this.purityListening();
    }
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.on('onFocus', () => {
      if (this.isNoListening()) {
        this.purityListening();
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
  PurityCard() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.gestures_purity'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.gesture_file_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.purityStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.gesture_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.purityDisablingListening();
            })
          } else {
            Button($r('app.string.gesture_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.purityListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.knock_no_title'))
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
  ImmersiveCard() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.gestures_immersive'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.knock_immersive_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.immersiveStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.gesture_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.immersiveDisablingListening();
            })
          } else {
            Button($r('app.string.gesture_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.immersiveListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.knock_image_upper_limit'))
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
  WhiteCard() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.gestures_white'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.knock_white_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.whiteStatus) {
            Button() {
              Row() {
                LoadingProgress().width(20).height(20).margin({ left: 12 }).color(0xFFFFFF)
                Text($r('app.string.gesture_listening')).fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
              }.alignItems(VerticalAlign.Center)
            }
            .width(200)
            .height(30)
            .margin({ left: 8 })
            .onClick(() => {
              this.whiteDisablingListening();
            })
          } else {
            Button($r('app.string.gesture_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.whiteListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.knock_image_lower_limit'))
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
  GestureExplain() {
    Column() {
      Text($r('app.string.precautions'))
        .width('100%')
        .fontSize(18)

      Text($r('app.string.gesture_precautions_1'))
        .width('100%')
        .fontSize(16)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(this.message)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .margin({ bottom: 12 })

        this.GestureExplain()

        this.PurityCard()

        this.ImmersiveCard()

        this.WhiteCard()
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }

  private onBackGround() {
    logger.info('onBackGround invoked.');
    this.disablingAllListening();
  }

  private disablingAllListening() {
    if (this.purityStatus) {
      this.purityDisablingListening();
    }
    if (this.immersiveStatus) {
      this.immersiveDisablingListening();
    }
    if (this.whiteStatus) {
      this.whiteDisablingListening();
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

  private purityListening() {
    if (this.isNoListening()) {
      if (this.windowId) {
        let capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
          windowId: this.windowId,
        }
        harmonyShare.on('gesturesShare', capabilityRegistry, this.purityCallback);
        this.purityStatus = true;
      }
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.gesture_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private purityDisablingListening() {
    if (this.windowId) {
      let capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
        windowId: this.windowId,
      }
      harmonyShare.off('gesturesShare', capabilityRegistry, this.purityCallback);
      this.purityStatus = false;
    }
  }

  private immersiveCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleKnock1.jpg';
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
      thumbnailUri: fileUri.getUriFromPath(filePath),
      title: contextFaker.resourceManager.getStringSync($r('app.string.immersive_title').id),
      description: contextFaker.resourceManager.getStringSync($r('app.string.immersive_description').id)
    });
    sharableTarget.share(shareData);
  }

  private immersiveListening() {
    if (this.isNoListening()) {
      harmonyShare.on('gesturesShare', this.immersiveCallback);
      this.immersiveStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.gesture_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private immersiveDisablingListening() {
    harmonyShare.off('gesturesShare', this.immersiveCallback);
    this.immersiveStatus = false;
  }

  private whiteCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleKnock2.png';
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
      thumbnailUri: fileUri.getUriFromPath(filePath),
      title: contextFaker.resourceManager.getStringSync($r('app.string.white_title').id),
      description: contextFaker.resourceManager.getStringSync($r('app.string.white_description').id)
    });
    sharableTarget.share(shareData);
  }

  private whiteListening() {
    if (this.isNoListening()) {
      harmonyShare.on('gesturesShare', this.whiteCallback);
      this.whiteStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.gesture_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private whiteDisablingListening() {
    harmonyShare.off('gesturesShare', this.whiteCallback);
    this.whiteStatus = false;
  }

  private isNoListening() {
    return !this.purityStatus && !this.immersiveStatus && !this.whiteStatus;
  }
}