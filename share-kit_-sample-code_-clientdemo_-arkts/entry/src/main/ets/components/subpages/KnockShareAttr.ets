/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import Logger from '../../utils/Logger';

let logger = Logger.getLogger('[KnockShareAttr]');

@Component
export default struct KnockShareAttr {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop windowId: number | undefined = undefined;
  @State sendOnlyStatus: boolean = false;

  aboutToAppear(): void {
    logger.info('invoked');
    if (this.isNoListening()) {
      this.sendOnlyListening();
    }
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.on('onFocus', () => {
      if (this.isNoListening()) {
        this.sendOnlyListening();
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
  sendOnlyMode() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        //记得修改图片
        Image($r('app.media.knock_reject'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Text($r('app.string.send_only_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.sendOnlyStatus) {
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
              this.sendOnlyDisablingListening();
            })
          } else {
            Button($r('app.string.knock_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.sendOnlyListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.send_only_description'))
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
          this.sendOnlyMode()
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
    if (this.sendOnlyStatus) {
      this.sendOnlyDisablingListening();
    }
  }

  private sendOnlyCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleKnock2.png';
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
      thumbnailUri: fileUri.getUriFromPath(filePath),
      title: contextFaker.resourceManager.getStringSync($r('app.string.white_title').id),
      description: contextFaker.resourceManager.getStringSync($r('app.string.white_description').id),
    });
    sharableTarget.share(shareData)
  }

  private sendOnlyListening() {
    if (!this.sendOnlyStatus) {
      if (this.windowId) {
        let capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
          windowId: this.windowId,
          sendOnly: true,
        }
        harmonyShare.on('knockShare', capabilityRegistry, this.sendOnlyCallback);
        this.sendOnlyStatus = true;
      }
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.knock_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private sendOnlyDisablingListening() {
    if (this.windowId) {
      let capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
        windowId: this.windowId,
        sendOnly: true,
      }
      harmonyShare.off('knockShare', capabilityRegistry, this.sendOnlyCallback);
      this.sendOnlyStatus = false;
    }
  }

  private isNoListening() {
    return !this.sendOnlyStatus;
  }
}