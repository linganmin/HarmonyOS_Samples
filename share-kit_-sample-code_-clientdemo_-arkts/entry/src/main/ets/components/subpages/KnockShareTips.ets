/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import KnockShareGuideCard, { CardRes } from '../modules/KnockShareGuideCard';
import Logger from '../../utils/Logger';

let logger = Logger.getLogger('[KnockShareTips]');

@Component
export default struct KnockShareTips {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop windowId: number | undefined = undefined;
  @State tipsStatus: boolean = false;
  private readonly cardSwiperResourcesPhone: CardRes[] = [
    {
      text: '对方手机需 HarmonyOS 5 及以上版本。',
      rawfilePrefix: 'knock_share_guide/knock_share_guide_phone_',
      framesCount: 128,
      startDelay: 50,
      stopDelay: 500,
    }
  ];
  private readonly cardSwiperResources: CardRes[] = [
    {
      text: '对方手机需 HarmonyOS 5 及以上版本。',
      rawfilePrefix: 'knock_share_guide/knock_share_guide_phone_',
      framesCount: 128,
      startDelay: 50,
      stopDelay: 500,
    },
    {
      text: '对方电脑需 HarmonyOS 6 及以上版本。',
      rawfilePrefix: 'knock_share_guide/knock_share_guide_pc_',
      framesCount: 104,
      startDelay: 50,
      stopDelay: 50,
    },
  ];
  private readonly cardSwiperResourcesPc: CardRes[] = [
    {
      text: '对方手机需 HarmonyOS 6 及以上版本。',
      rawfilePrefix: 'knock_share_guide/knock_share_guide_pc_pull_',
      framesCount: 150,
      startDelay: 500,
      stopDelay: 1000,
    },
  ]

  aboutToAppear(): void {
    logger.info('invoked');
    if (this.isNoListening()) {
      this.tipsListening();
    }
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.on('onFocus', () => {
      if (this.isNoListening()) {
        this.tipsListening();
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
  sceneDescription() {
    Flex({ direction: FlexDirection.Column }) {
      Text($r('app.string.tap_to_share_tips'))
        .width('100%')
        .fontSize(18)
        .lineHeight(20)
    }
    .margin({ bottom: 20 })
    .padding({ left: 20, right: 20 })
  }

  @Builder
  textNote() {
    Flex({ direction: FlexDirection.Column }) {
      Text('一、纯文本提示')
        .width('100%')
        .fontSize(18)
        .lineHeight(20)
        .margin({ bottom: 20 })

      Text('可碰一碰分享至 HarmonyOS 5 及以上版本手机')
        .padding({ left: 24, right: 24 })
        .maxLines(2)
        .fontSize(11)
        .maxFontScale(1.75)
        .width('100%')
        .constraintSize({ minHeight: 16 })
        .fontColor($r('sys.color.font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
    }
    .margin({ bottom: 20 })
    .padding({ left: 20, right: 20 })
  }

  @Builder
  webmNote() {
    Flex({ direction: FlexDirection.Column }) {
      Text('二、卡片提示')
        .width('100%')
        .fontSize(18)
        .lineHeight(20)
        .margin({ bottom: 20 })
        .padding({ left: 20, right: 20 })

      Column() {
        Text('仅支持手机设备')
          .width('100%')
          .fontSize(16)
          .lineHeight(20)
          .margin({ bottom: 20 })
          .padding({ left: 20, right: 20 })

        KnockShareGuideCard({ cardSwiperResources: this.cardSwiperResourcesPhone })
      }
      .margin({ bottom: 20 })

      Column() {
        Text('支持手机和PC/2in1设备')
          .width('100%')
          .fontSize(16)
          .lineHeight(20)
          .margin({ bottom: 20 })
          .padding({ left: 20, right: 20 })

        KnockShareGuideCard({ cardSwiperResources: this.cardSwiperResources })
      }
      .margin({ bottom: 20 })

      Column() {
        Text('仅支持PC/2in1设备发送给手机')
          .width('100%')
          .fontSize(16)
          .lineHeight(20)
          .margin({ bottom: 20 })
          .padding({ left: 20, right: 20 })

        KnockShareGuideCard({ cardSwiperResources: this.cardSwiperResourcesPc })
      }
      .margin({ bottom: 20 })

    }
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.sceneDescription()

          this.textNote()

          this.webmNote()

        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
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
    if (this.tipsStatus) {
      this.tipsDisablingListening();
    }
  }

  private sendOnlyCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleDocx.docx';
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.docx', utd.UniformDataType.FILE);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: contextFaker.resourceManager.getStringSync($r('app.string.white_title').id),
      description: contextFaker.resourceManager.getStringSync($r('app.string.white_description').id),
    });
    sharableTarget.share(shareData)
  }

  private tipsListening() {
    if (!this.tipsStatus) {
      harmonyShare.on('knockShare', this.sendOnlyCallback);
      this.tipsStatus = true;
    } else {
      try {
        const uiContext: UIContext = this.getUIContext();
        uiContext.getPromptAction().showToast({ message: $r('app.string.knock_close_other') });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private tipsDisablingListening() {
    harmonyShare.off('knockShare', this.sendOnlyCallback);
    this.tipsStatus = true;
  }

  private isNoListening() {
    return !this.tipsStatus;
  }
}