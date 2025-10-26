/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { attributionManager, attributionTestManager } from '@kit.StoreKit';
import { SignUtil } from '../common/utils/SignUtil';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';

const TAG: string = 'Attribution';

@Entry
@Component
struct Attribution {
  build() {
    Column({ space: 20 }) {
      Button($r("app.string.register_source"))
        .id('register_source')
        .onClick(() => {
          this.registerSource();
        })
        .width('100%')

      Button($r("app.string.register_trigger"))
        .id('register_trigger')
        .onClick(() => {
          this.registerTrigger();
        })
        .width('100%')

      Button($r("app.string.validate_source"))
        .id('validate_source')
        .onClick(() => {
          this.validateSource();
        })
        .width('100%')

      Button($r("app.string.set_postback"))
        .id('setpostback')
        .onClick(() => {
          this.setPostback();
        })
        .width('100%')

      Button($r("app.string.flush_postbacks"))
        .id('flushPostbacks')
        .onClick(() => {
          this.flushPostbacks();
        })
        .width('100%')
    }
    .margin(16)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  async registerSource(): Promise<void> {
    try {
      // Private key corresponding to the public key provided during role registration on the cloud platform of the app attribution service.
      let privateKey: string = '';
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '12345678';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '123456';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '102345678';
      // ID of the monitoring platform.
      let mmpIds: string[] = ['12345678', '23456789'];
      // Business information that the ad platform focuses on.
      let serviceTag: string = 'testServiceTag';
      // UUID in lowercase, without hyphens (-).
      let nonce: string = util.generateRandomUUID().replace(/-/g, '');
      // Timestamp.
      let timestamp: number = Date.now()

      let adSourceInfo: attributionManager.AdSourceInfo = {
        adTechId: adTechId,
        campaignId: campaignId,
        destinationId: destinationId,
        // Impression.
        sourceType: attributionManager.SourceType.IMPRESSION,
        mmpIds: mmpIds,
        serviceTag: serviceTag,
        nonce: nonce,
        timestamp: timestamp,
        // Signature value.
        signature: await SignUtil.getSign(SignUtil.genSignContent(adTechId, campaignId, destinationId, mmpIds, serviceTag, nonce, timestamp), privateKey)
      };

      attributionManager.registerSource(adSourceInfo).then(() => {
        hilog.info(0, TAG, 'registerSource success.');
        promptAction.showToast({
          message: 'registerSource success.'
        })
      }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `registerSource error. code is ${error.code}, message is ${error.message}`);
        promptAction.showToast({
          message: `registerSource failed.`
        })
      })
    } catch (error) {
      hilog.error(0, TAG, `registerSource error. code is ${error.code}, message is ${error.message}`);
      promptAction.showToast({
        message: `registerSource failed.`
      })
    }
  }

  registerTrigger(): void {
    try {
      let adTriggerInfo: attributionManager.AdTriggerInfo = {
        // Conversion event ID, which is obtained from the cloud platform of the app attribution service.
        triggerData: 123 ,
        businessScene: 5
      };

      attributionManager.registerTrigger(adTriggerInfo).then(() => {
        hilog.info(0, TAG, 'registerTrigger success');
        promptAction.showToast({
          message: 'registerTrigger success.'
        })
      }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `registerTrigger error. code is ${error.code}, message is ${error.message}`);
        promptAction.showToast({
          message: `registerTrigger failed.`
        })
      })
    } catch (error) {
      hilog.error(0, TAG, `registerTrigger error. code is ${error.code}, message is ${error.message}`);
      promptAction.showToast({
        message: `registerTrigger failed.`
      })
    }
  }

  async validateSource(): Promise<void> {
    try {
      // Public key and corresponding private key provided during role registration on the cloud platform of the app attribution service. You can customize the values for debugging purposes.
      let privateKey: string = '';

      let publicKey: string = '';

      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '12345678';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '123456';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '102345678';
      // ID of the monitoring platform.
      let mmpIds: string[] = ['12345678', '23456789'];
      // Business information that the ad platform focuses on.
      let serviceTag: string = 'testServiceTag';
      // UUID in lowercase, without hyphens (-).
      let nonce: string = util.generateRandomUUID().replace(/-/g, '');
      // Timestamp.
      let timestamp: number = Date.now()

      let adSourceInfo: attributionTestManager.AdSourceInfo = {
        adTechId: adTechId,
        campaignId: campaignId,
        destinationId: destinationId,
        // Impression.
        sourceType: attributionTestManager.SourceType.IMPRESSION,
        mmpIds: mmpIds,
        serviceTag: serviceTag,
        nonce: nonce,
        timestamp: timestamp,
        // Signature value.
        signature: await SignUtil.getSign(SignUtil.genSignContent(adTechId, campaignId, destinationId, mmpIds, serviceTag, nonce, timestamp), privateKey)
      };

      await attributionTestManager.validateSource(adSourceInfo, publicKey);
      hilog.info(0, TAG, 'validateSource success.');
      promptAction.showToast({
        message: 'validateSource success.'
      })
    } catch (error) {
      hilog.error(0, TAG, `validateSource error. code is ${error.code}, message is ${error.message}`);
      promptAction.showToast({
        message: 'validateSource failed.'
      })
    }
  }

  async setPostback(): Promise<void> {
    try {
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '12345678';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '123456';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '102345678';
      // Business information that the ad platform focuses on.
      let serviceTag: string = 'testServiceTag';


      let postbackInfo: attributionTestManager.PostbackInfo = {
        adTechId: adTechId,
        campaignId: campaignId,
        destinationId: destinationId,
        // Impression.
        sourceId: '1',
        serviceTag: serviceTag,
        triggerData: 123,
        businessScene: 5 ,
        postbackUrl: 'http://abc.com'
      };

      await attributionTestManager.setPostback(postbackInfo);
      hilog.info(0, TAG, 'setPostback success.');
      promptAction.showToast({
        message: 'setPostback success.'
      })
    } catch (error) {
      hilog.error(0, TAG, `setPostback error. code is ${error.code}, message is ${error.message}`);
      promptAction.showToast({
        message: 'setPostback failed.'
      })
    }
  }

  async flushPostbacks(): Promise<void> {
    try {
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '12345678';
      await attributionTestManager.flushPostbacks(adTechId);
      hilog.info(0, TAG, 'flushPostbacks success.');
      promptAction.showToast({
        message: 'flushPostbacks success.'
      })
    } catch (error) {
      hilog.error(0, TAG, `flushPostbacks error. code is ${error.code}, message is ${error.message}`);
      promptAction.showToast({
        message: 'flushPostbacks failed.'
      })
    }
  }
}