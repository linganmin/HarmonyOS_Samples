/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[Posters]');

@Component
export default struct Posters {
  private async share() {
    const uiContext: UIContext = this.getUIContext();
    const contextFaker: Context = uiContext.getHostContext() as Context;
    let filePath = contextFaker.filesDir + '/exampleImage.jpg';

    let thumbnailPath = contextFaker.filesDir + '/exampleImage.jpg';
    const imageSource: image.ImageSource = image.createImageSource(thumbnailPath);
    const imagePacker: image.ImagePacker = image.createImagePacker();
    let buffer: ArrayBuffer | undefined = undefined;

    try {
      buffer = await imagePacker.packToData(imageSource, {
        format: 'image/jpeg',
        quality: 30,
      });
    } catch (error) {
      logger.error(`packToData error. Code: ${error?.code}, message: ${error?.message}`);
    }

    let uri: string | undefined = undefined;
    try {
      uri = fileUri.getUriFromPath(filePath);
    } catch (error) {
      logger.error(`getUriFromPath error. Code: ${error?.code}, message: ${error?.message}`);
    }

    if (!uri) {
      logger.error('getUriFromPath error.');
      return;
    }

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.IMAGE,
      uri: uri,
      title: 'Picture Title',
      description: 'Picture Description',
      label: 'Poster'
    });

    try {
      shareData.addRecord({
        utd: utd.UniformDataType.HYPERLINK,
        content: 'https://www.vmall.com/index.html?cid=128688',
        title: 'Huawei Vmall',
        description: 'Phone',
        label: 'Huawei Vmall',
        thumbnail: buffer ? new Uint8Array(buffer) : undefined,
      });
    } catch (error) {
      logger.error(`addRecord error. Code: ${error?.code}, message: ${error?.message}`);
    }

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      logger.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      logger.error(`ShareController show error. code: ${error?.code}, message: ${error?.message}`);
    });
  }

  build() {
    Row() {
      Text($r('app.string.poster_type'))

      Button($r('app.string.share_btn'))
        .onClick(() => this.share())
    }
    .width('100%')
    .margin({ top: 12 })
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
