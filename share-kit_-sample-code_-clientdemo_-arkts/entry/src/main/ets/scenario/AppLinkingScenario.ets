/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[AppLinking]');

@Component
export default struct AppLinking {

  private async share() {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    const resourceMgr: resourceManager.ResourceManager = contextFaker.resourceManager;
    let fileData: Uint8Array | undefined = undefined;

    try {
      fileData = await resourceMgr.getMediaContent($r('app.media.icon').id);
    } catch (error) {
      logger.error(`getMediaContent error. Code: ${error?.code}, message: ${error?.message}`);
    }

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
      title: 'App Name',
      description: 'App Description',
      thumbnail: fileData,
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE
    }).then(() => {
      logger.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      logger.error(`ShareController show error. code: ${error?.code}, message: ${error?.message}`);
    });
  }

  build() {
    Row() {
      Text('AppLinking')

      Button($r('app.string.share_btn'))
        .onClick(() => this.share())
    }
    .width('100%')
    .margin({ top: 12 })
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
