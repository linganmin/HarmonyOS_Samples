/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[BaseDemo]');

@Component
export default struct BaseDemo {
  @State selectionMode: number = systemShare.SelectionMode.SINGLE;
  @State sharePreviewMode: number = systemShare.SharePreviewMode.DEFAULT;

  @Builder
  RadioItem(text: ResourceStr, value: string, group: string, checked: boolean, handelChecked: () => void) {
    Row() {
      Radio({ value, group })
        .checked(checked)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            handelChecked();
          }
        })
      Text(text)
    }
    .margin({ right: 12 })
  }

  @Builder
  DescriptionTitle(resourceStr: ResourceStr) {
    Text(resourceStr)
      .width('100%')
      .margin({ top: 12 })
      .fontSize(14)
  }

  @Builder
  DescriptionText(resourceStr: ResourceStr, code: number) {
    Row() {
      Text(code + '.').fontSize(14)
      Text(resourceStr).fontSize(14)
    }
    .width('100%')
    .margin({ top: 4 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  HostShare() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Flex({ direction: FlexDirection.Row }) {
          Text('宿主应用发起分享')
            .flexGrow(1)
            .fontSize(18)
            .fontWeight(500)

          Button($r('app.string.share_btn'))
            .width(80)
            .height(30)
            .margin({ left: 12 })
            .onClick(() => {
              this.handelHostShare();
            })
        }
        .width('100%')

        Flex({ direction: FlexDirection.Row }) {
          Row() {
            Image(this.getImageSrc()).width(100);
          }
          .width(150)
          .margin({ right: 12 })

          Column() {
            Column() {
              Row() {
                this.RadioItem($r('app.string.single_mode'), 'single', 'SelectionModeGroup', this.selectionMode === 0,
                  () => {
                    this.selectionMode = systemShare.SelectionMode.SINGLE;
                  })
                this.RadioItem($r('app.string.batch_mode'), 'batch', 'SelectionModeGroup', this.selectionMode === 1,
                  () => {
                    this.selectionMode = systemShare.SelectionMode.BATCH;
                  })
              }

              Row() {
                this.RadioItem($r('app.string.default_mode'), 'default', 'SharePreviewModeGroup',
                  this.sharePreviewMode === 0,
                  () => {
                    this.sharePreviewMode = systemShare.SharePreviewMode.DEFAULT;
                  })
                this.RadioItem($r('app.string.detail_mode'), 'detail', 'SharePreviewModeGroup',
                  this.sharePreviewMode === 1,
                  () => {
                    this.sharePreviewMode = systemShare.SharePreviewMode.DETAIL;
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)

            Column() {
              this.DescriptionTitle($r('app.string.function_title'));
              this.DescriptionText($r('app.string.share_selection_mode'), 1);
              this.DescriptionText($r('app.string.share_preview_mode'), 2);
              this.DescriptionText($r('app.string.share_excluded_abilities_print'), 3);
            }
          }
          .flexGrow(1)
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  Dismiss() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Flex({ direction: FlexDirection.Row }) {
          Text('监听分享面板关闭')
            .flexGrow(1)
            .fontSize(18)
            .fontWeight(500)

          Button($r('app.string.share_btn'))
            .width(80)
            .height(30)
            .margin({ left: 12 })
            .onClick(() => {
              this.handelShareDismiss();
            })
        }
        .width('100%')

        Column() {
          this.DescriptionTitle($r('app.string.function_title'));
          this.DescriptionText($r('app.string.dismiss_description_1'), 1);
          this.DescriptionText($r('app.string.dismiss_description_2'), 2);
          this.DescriptionText($r('app.string.dismiss_description_3'), 3);
        }
        .width('100%')
      }
    }
    .margin({ top: 20 })
  }

  @Builder
  ShareCompleted() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Flex({ direction: FlexDirection.Row }) {
          Text('获取分享结果')
            .flexGrow(1)
            .fontSize(18)
            .fontWeight(500)

          Button($r('app.string.share_btn'))
            .width(80)
            .height(30)
            .margin({ left: 12 })
            .onClick(() => {
              this.handelShareCompleted();
            })
        }
        .width('100%')

        Column() {
          this.DescriptionTitle($r('app.string.function_title'));
          this.DescriptionText($r('app.string.shareCompleted_description_1'), 1);
          this.DescriptionText($r('app.string.shareCompleted_description_2'), 2);
          this.DescriptionText($r('app.string.shareCompleted_description_3'), 3);
          this.DescriptionText($r('app.string.shareCompleted_description_4'), 4);
        }
        .width('100%')
      }
    }
    .margin({ top: 20 })
  }

  build() {
    Scroll() {
      Flex({ direction: FlexDirection.Column }) {
        // 宿主应用发起分享
        this.HostShare();

        // 监听分享面板关闭
        this.Dismiss();

        // 获取分享结果
        this.ShareCompleted();
      }
      .width('100%')
      .height('100%')
      .padding({ top: 12, left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }

  private getImageSrc(): ResourceStr {
    switch (this.selectionMode) {
      case systemShare.SelectionMode.SINGLE:
        if (this.sharePreviewMode === systemShare.SharePreviewMode.DEFAULT) {
          return $r('app.media.share_preview_00');
        } else {
          return $r('app.media.share_preview_01');
        }
      case systemShare.SelectionMode.BATCH:
        if (this.sharePreviewMode === systemShare.SharePreviewMode.DEFAULT) {
          return $r('app.media.share_preview_10');
        } else {
          return $r('app.media.share_preview_11');
        }
      default:
        return $r('app.media.share_preview_00');
    }
  }

  private async handelHostShare(): Promise<void> {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.getUniformDataTypeByFilenameExtension('.jpg', utd.UniformDataType.IMAGE),
      uri: fileUri.getUriFromPath(contextFaker.filesDir + '/exampleImage.jpg'),
      title: 'Image Title',
      description: 'Image Description',
    });
    try {
      shareData.addRecord({
        utd: utd.getUniformDataTypeByFilenameExtension('.mp4', utd.UniformDataType.VIDEO),
        uri: fileUri.getUriFromPath(contextFaker.filesDir + '/exampleVideo.mp4'),
        title: 'Video Title',
        description: 'Video Description',
      });
    } catch (error) {
      logger.error(`addRecord error. Code: ${error?.code}, message: ${error?.message}`);
    }
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: this.sharePreviewMode,
      selectionMode: this.selectionMode,
      excludedAbilities: [systemShare.ShareAbilityType.PRINT]
    }).then(() => {
      logger.info('HuaweiShare_ show');
    }).catch((error: BusinessError) => {
      logger.error(`HuaweiShare_ show error. Code: ${error?.code}, message: ${error?.message}`);
    });
  }

  private async handelShareDismiss(): Promise<void> {
    const uiContext: UIContext = this.getUIContext();
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: 'Hello HarmonyOS',
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    const callback = () => {
      try {
        logger.info('HuaweiShare_ dismiss invoked.');
        uiContext.getPromptAction().showToast({ message: 'dismiss' });
      } catch (error) {
        logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
      }
    };
    controller.on('dismiss', callback);
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE,
    }).then(() => {
      logger.info('HuaweiShare_ show');
    }).catch((error: BusinessError) => {
      logger.error(`HuaweiShare_ show error. Code: ${error?.code}, message: ${error?.message}`);
    });
  }

  private async handelShareCompleted(): Promise<void> {
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
    const callback = (result: systemShare.ShareOperationResult) => {
      logger.info('HuaweiShare_ shareCompleted invoked. result:', result.targetAbilityInfo.name);
    };
    controller.on('shareCompleted', callback);
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE,
    }).then(() => {
      logger.info('HuaweiShare_ show');
    }).catch((error: BusinessError) => {
      logger.error(`HuaweiShare_ show error. Code: ${error?.code}, message: ${error?.message}`);
    });
  }
}