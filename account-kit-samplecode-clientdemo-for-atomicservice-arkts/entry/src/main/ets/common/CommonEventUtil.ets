/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { minorsProtection } from '@kit.AccountKit';

// Subscriber information.
const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: [
    commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON,
    commonEventManager.Support.COMMON_EVENT_MINORSMODE_OFF
  ]
};

const logTag: string = 'CommonEventUtil';
const domainId: number = 0x0000;

export class CommonEventUtil {
  static subscriber: commonEventManager.CommonEventSubscriber;

  // Common event method, which is used to subscribe to common events related to the youth mode.
  static subscriberCommonEvent() {
    hilog.info(domainId, logTag, 'into subscriberCommonEvent');
    // Create a subscriber.
    commonEventManager.createSubscriber(subscribeInfo)
      .then((commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        CommonEventUtil.subscriber = commonEventSubscriber;
        hilog.info(domainId, logTag, 'Succeeded in getting subscriber.');

        // Subscribe to a common event.
        try {
          commonEventManager.subscribe(CommonEventUtil.subscriber, CommonEventUtil.subscribeCallBack);
        } catch (error) {
          const err: BusinessError = error as BusinessError;
          hilog.error(domainId, logTag, `Failed to subscribe. errCode: ${err.code}, message: ${err.message}`);
        }

      })
      .catch((err: BusinessError) => {
        hilog.error(domainId, logTag, `Failed to createSubscriber. errCode: ${err.code}, errMessage: ${err.message}.`);
      });
  }

  /**
   * Callback for common event subscription.
   * @param err Error information.
   * @param data Event that is listened to.
   */
  private static subscribeCallBack(err: BusinessError, data: commonEventManager.CommonEventData) {
    if (err) {
      hilog.error(domainId, logTag, `Failed to subscribe. errCode: ${err.code}, errMessage: ${err.message}`);
      return;
    }
    hilog.info(domainId, logTag, `Succeeded in subscribing. ${data.event}`);
    // If the event of enabling the youth mode is received:
    if (data.event === commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON) {
      AppStorage.setOrCreate('minorsProtectionMode', true);
      AppStorage.setOrCreate('availableTimeMode', true);
      const userTurnOffFlag: boolean | undefined = AppStorage.get<boolean>('userTurnOffFlag');
      /*
       * If the flag for disabling the atomic service's youth mode separately is true,
       * the youth mode in the atomic service is disabled.
       * */
      if (userTurnOffFlag) {
        return;
      }
      // Obtain the age group and display content accordingly.
      if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
        try {
          const minorsProtectionInfo: minorsProtection.MinorsProtectionInfo =
            minorsProtection.getMinorsProtectionInfoSync();
          const ageGroup: minorsProtection.AgeGroup | undefined = minorsProtectionInfo.ageGroup;
          if (ageGroup) {
            AppStorage.setOrCreate('lowerAge', ageGroup.lowerAge);
            AppStorage.setOrCreate('upperAge', ageGroup.upperAge);
            hilog.info(domainId, logTag, `Succeeded in getting lowerAge is: ${ageGroup.lowerAge}`);
            hilog.info(domainId, logTag, `Succeeded in getting upperAge is: ${ageGroup.upperAge}`);
          }
        } catch (error) {
          hilog.error(domainId, logTag,
            `Failed to invoke getMinorsProtectionInfoSync. errCode: ${error.code}, message: ${error.message}`);
        }
      }
      return;
    }
    // If the event of disabling the youth mode is received:
    if (data.event === commonEventManager.Support.COMMON_EVENT_MINORSMODE_OFF) {
      AppStorage.setOrCreate('minorsProtectionMode', false);
      AppStorage.setOrCreate('availableTimeMode', true);
      AppStorage.setOrCreate('userTurnOffFlag', false);
    }
  }
}
