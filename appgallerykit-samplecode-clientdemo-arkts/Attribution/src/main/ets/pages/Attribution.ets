/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { attributionManager, attributionTestManager } from '@kit.AppGalleryKit';
import { SignUtil } from '../common/utils/SignUtil';
import { util } from '@kit.ArkTS';

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
        .id('set_postback')
        .onClick(() => {
          this.setPostback();
        })
        .width('100%')

      Button($r("app.string.flush_postbacks"))
        .id('flush_postbacks')
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
      let privateKey: string = '********u2rMtFw==';
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '2******';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '1*****';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '6*********4';
      // ID of the monitoring platform.
      let mmpIds: string[] = ['2f*****15'];
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
        signature: await SignUtil.getSign(this.getUIContext(),
          SignUtil.genSignContent(adTechId, campaignId, destinationId, mmpIds, serviceTag, nonce, timestamp),
          privateKey)
      };

      attributionManager.registerSource(adSourceInfo).then(() => {
        hilog.info(0, TAG, 'registerSource success.');
        this.showToastPrompt($r('app.string.register_source_success').id);
      }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `registerSource error. code is ${error.code}, message is ${error.message}`);
        this.showToastPrompt($r('app.string.register_source_failed').id);
      })
    } catch (error) {
      hilog.error(0, TAG, `registerSource error. code is ${error.code}, message is ${error.message}`);
      this.showToastPrompt($r('app.string.register_source_failed').id);
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
        this.showToastPrompt($r('app.string.register_trigger_success').id);
      }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `registerTrigger error. code is ${error.code}, message is ${error.message}`);
        this.showToastPrompt($r('app.string.register_trigger_failed').id);
      })
    } catch (error) {
      hilog.error(0, TAG, `registerTrigger error. code is ${error.code}, message is ${error.message}`);
      this.showToastPrompt($r('app.string.register_trigger_failed').id);
    }
  }

  async validateSource(): Promise<void> {
    try {
      // Public key and corresponding private key provided during role registration on the cloud platform of the app attribution service. You can customize the values for debugging purposes.
      let privateKey: string = '';

      let publicKey: string = '';

      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '1******8';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '1****6';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '1******8';
      // ID of the monitoring platform.
      let mmpIds: string[] = ['1******8', '2******9'];
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
        signature: await SignUtil.getSign(this.getUIContext(),
          SignUtil.genSignContent(adTechId, campaignId, destinationId, mmpIds, serviceTag, nonce, timestamp),
          privateKey)
      };

      await attributionTestManager.validateSource(adSourceInfo, publicKey);
      hilog.info(0, TAG, 'validateSource success.');
      this.showToastPrompt($r('app.string.validate_source_success').id);
    } catch (error) {
      hilog.error(0, TAG, `validateSource error. code is ${error.code}, message is ${error.message}`);
      this.showToastPrompt($r('app.string.validate_source_failed').id);
    }
  }

  async setPostback(): Promise<void> {
    try {
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '1******8';
      // ID of the ad task created by the ad platform.
      let campaignId: string = '1****6';
      // ID of the advertiser's app released on AppGallery, without letter C.
      let destinationId: string = '1******8';
      // Business information that the ad platform focuses on.
      let serviceTag: string = 'testServiceTag';


      let postbackInfo: attributionTestManager.PostbackInfo = {
        adTechId: adTechId,
        campaignId: campaignId,
        destinationId: destinationId,
        // Impression.
        sourceId: '1******8',
        serviceTag: serviceTag,
        triggerData: 123,
        businessScene: 5 ,
        postbackUrl: 'https://xxx.com'
      };

      await attributionTestManager.setPostback(postbackInfo);
      hilog.info(0, TAG, 'setPostback success.');
      this.showToastPrompt($r('app.string.set_postback_success').id);
    } catch (error) {
      hilog.error(0, TAG, `setPostback error. code is ${error.code}, message is ${error.message}`);
      this.showToastPrompt($r('app.string.set_postback_failed').id);
    }
  }

  async flushPostbacks(): Promise<void> {
    try {
      // Allocated by the app attribution service during role registration on the cloud platform of the app attribution service.
      let adTechId: string = '1******8';
      await attributionTestManager.flushPostbacks(adTechId);
      hilog.info(0, TAG, 'flushPostbacks success.');
      this.showToastPrompt($r('app.string.flush_postbacks_success').id);
    } catch (error) {
      hilog.error(0, TAG, `flushPostbacks error. code is ${error.code}, message is ${error.message}`);
      this.showToastPrompt($r('app.string.flush_postbacks_failed').id);
    }
  }

  private showToastPrompt(resId: number): void {
    let msg: string | undefined =
      this.getUIContext().getHostContext()?.resourceManager.getStringSync(resId);
    if (msg) {
      this.getUIContext().getPromptAction().showToast({
        message: msg
      })
    }
  }
}