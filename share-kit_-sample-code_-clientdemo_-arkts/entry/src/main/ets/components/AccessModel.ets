/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[AccessModel]');

@Component
export default struct AccessModel {
  @State message: ResourceStr = $r('app.string.access_model_title');
  @State isSheetShow: boolean = false;

  private async handelShare(): Promise<void> {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleImage.jpg';
    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.jpg', utd.UniformDataType.IMAGE);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: 'Picture Title',
      description: 'Picture Description',
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.BATCH,
    }).then(() => {
      logger.info('HuaweiShare_ show');
    }).catch((error: BusinessError) => {
      logger.error(`HuaweiShare_ show error. Code: ${error?.code}, message: ${error?.message}`);
    });
  }

  @Builder
  FullJoint() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image($r('app.media.joint_full'))
          .width(100)
      }
      .width(150)
      .margin({ right: 12 })

      Column() {
        Flex({ direction: FlexDirection.Row }) {
          Text($r('app.string.full_title'))
            .flexGrow(1)
            .fontSize(20)
            .fontWeight(500)

          Button($r('app.string.share_btn'))
            .width(100)
            .height(30)
            .fontSize(14)
            .margin({ left: 8 })
            .onClick(() => this.handelShare())
        }.width('100%')

        Column() {
          Text($r('app.string.full_model'))
            .width('100%')
            .margin({ top: 12 })
            .fontWeight(500)
          Text($r('app.string.full_description'))
            .width('100%')
            .margin({ top: 12 })
        }.width('100%')
      }
      .flexGrow(1)
    }
    .margin({ bottom: 20 })
  }

  @Builder
  HalfJoint() {
    Flex({ direction: FlexDirection.Column }) {
      Column() {
        Flex({ direction: FlexDirection.Row }) {
          Text($r('app.string.half_title'))
            .flexGrow(1)
            .fontSize(20)
            .fontWeight(500)

          Button($r('app.string.share_btn'))
            .width(100)
            .height(30)
            .fontSize(14)
            .margin({ left: 8 })
            .bindSheet($$this.isSheetShow, this.HalfSheet(), {
              height: 220,
              title: this.HalfTitle(),
            })
            .onClick(() => {
              this.isSheetShow = true;
            })
        }.width('100%')

        Column() {
          Text($r('app.string.half_model'))
            .width('100%')
            .margin({ top: 12 })
            .fontWeight(500)
          Text($r('app.string.half_description'))
            .width('100%')
            .margin({ top: 12 })
        }.width('100%')
      }

      Row() {
        Image($r('app.media.joint_half'))
          .width(100)
          .margin({ left: 20 })

        Image($r('app.media.joint_full'))
          .width(100)
          .margin({ left: 20 })
      }
      .width('100%')
      .height(220)
      .margin({ top: 12 })
    }
    .margin({ bottom: 20 })
  }

  @Builder
  HalfTitle() {
    Text($r('app.string.share_to'))
      .fontSize(20)
      .fontWeight(500)
  }

  @Builder
  HalfSheet() {
    Flex({ direction: FlexDirection.Row }) {
      this.HalfAppItem();
      this.HalfAppItem();
      this.HalfAppItem();

      Column() {
        Column() {
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize('24vp')
        }
        .width(48)
        .height(48)
        .borderRadius(12.4)
        .borderWidth($r('sys.float.border_small'))
        .borderColor('#99808080')
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)

        Text($r('app.string.system_share'))
          .fontSize(12)
          .margin({ top: 8 })
          .textAlign(TextAlign.Center)
      }
      .width('22%')
      .height(100)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.handelShare();
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
  }

  @Builder
  HalfAppItem() {
    Column() {
      Image($r('app.media.app_icon'))
        .width(48)
        .height(48)

      Text($r('app.string.app'))
        .fontSize(12)
        .margin({ top: 8 })
    }
    .width('20%')
    .height(100)
    .justifyContent(FlexAlign.Center)
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

        this.FullJoint();

        this.HalfJoint();
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }
}