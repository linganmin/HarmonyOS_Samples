/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import Logger from '../../utils/Logger';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';

let logger = Logger.getLogger('[KnockShareSandbox]');

@Component
export default struct KnockShareSandbox {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop windowId: number | undefined = undefined;
  @State dataReceiveStatus: boolean = false;
  @State dataReceiveUri: string | undefined = undefined;

  aboutToAppear(): void {
    if (this.isNoListening()) {
      this.dataReceiveListening();
    }
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.on('onFocus', () => {
      if (this.isNoListening()) {
        this.dataReceiveListening();
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
  dataReceiveMode() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Text($r('app.string.sandbox_title'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        Stack() {
          if (this.dataReceiveStatus) {
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
              this.dataReceiveDisablingListening();
            })
          } else {
            Button($r('app.string.knock_click'))
              .width(200)
              .height(30)
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.dataReceiveListening();
              })
          }
        }.margin({ top: 12 })

        Column() {
          Text($r('app.string.sandbox_description'))
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
        }

        Column() {
          Text($r('app.string.sandbox_account'))
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
        }

        Column() {
          Text($r('app.string.sandbox_note'))
            .margin({ top: 12 })
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
        }
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text($r('app.string.sandbox_result'))
          .flexGrow(1)
          .fontSize(20)
          .fontWeight(500)

        if (this.dataReceiveUri) {
          Text(this.dataReceiveUri)
          Image(this.dataReceiveUri)
            .width(300)
            .height(300)
        }
      }
      .width(500)
      .padding({ right: 20 })
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.dataReceiveMode()
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
    if (this.dataReceiveStatus) {
      this.dataReceiveDisablingListening();
    }
  }

  private dataReceiveCallback = (receivableTarget: harmonyShare.ReceivableTarget) => {
    let uiContext: UIContext = this.getUIContext();
    let context = uiContext.getHostContext() as common.UIAbilityContext;
    let sandboxUri = fileUri.getUriFromPath(context.filesDir);
    receivableTarget.receive(sandboxUri, {
      onDataReceived: (sharedData: systemShare.SharedData) => {
        let sharedRecords = sharedData.getRecords();
        sharedRecords.forEach((record: systemShare.SharedRecord) => {
          this.dataReceiveUri = record.uri;
        });
      },
      onResult: (resultCode: harmonyShare.ShareResultCode) => {
        if (resultCode === harmonyShare.ShareResultCode.SHARE_SUCCESS) {
          try {
            const uiContext: UIContext = this.getUIContext();
            uiContext.getPromptAction().showToast({ message: $r('app.string.success_supported') });
          } catch (error) {
            logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
          }
        }
      }
    });
  }

  private dataReceiveListening() {
    if (this.isNoListening()) {
      if (this.windowId) {
        let capabilityRegistry: harmonyShare.RecvCapabilityRegistry = {
          windowId: this.windowId,
          capabilities: [{
            utd: utd.UniformDataType.IMAGE,
            maxSupportedCount: 1,
          }]
        }
        harmonyShare.on('dataReceive', capabilityRegistry, this.dataReceiveCallback);
        this.dataReceiveStatus = true;
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

  private dataReceiveDisablingListening() {
    try {
      if (this.windowId) {
        let capabilityRegistry: harmonyShare.RecvCapabilityRegistry = {
          windowId: this.windowId,
          capabilities: [{
            utd: utd.UniformDataType.IMAGE,
            maxSupportedCount: 1,
          }]
        }
        harmonyShare.off('dataReceive', capabilityRegistry, this.dataReceiveCallback);
        this.dataReceiveStatus = false;
      }
    } catch (error) {
      logger.error(error?.message);
    }
  }

  private isNoListening() {
    return !this.dataReceiveStatus;
  }
}