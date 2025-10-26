/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { minorsProtection } from '@kit.AccountKit';

const logTag: string = 'CommonEventUtil';
const domainId: number = 0x0000;

export class CommonEventUtil {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  // Common event method, which is used to subscribe to common events related to the youth mode.
  subscriberCommonEvent() {
    hilog.info(domainId, logTag, 'into subscriberCommonEvent');
    // Create a subscriber.
    if (canIUse("SystemCapability.Notification.CommonEvent")) {
      // Subscriber information.
      const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [
          commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON,
          commonEventManager.Support.COMMON_EVENT_MINORSMODE_OFF,
          commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN,
          commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT
        ]
      };
      commonEventManager.createSubscriber(subscribeInfo)
        .then((commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
          hilog.info(domainId, logTag, 'Succeeded in getting subscriber.');

          // Subscribe to a common event.
          try {
            commonEventManager.subscribe(commonEventSubscriber, this.subscribeCallBack);
          } catch (error) {
            hilog.error(domainId, logTag, `Failed to subscribe. errCode: ${error.code}, message: ${error.message}`);
          }
        })
        .catch((err: BusinessError) => {
          hilog.error(domainId, logTag, `Failed to create Subscriber. errCode: ${err.code}, message: ${err.message}.`);
        });
    } else {
      hilog.error(domainId, logTag, 'SubscriberCommonEvent is not supported on this device');
    }
  }

  /**
   * Callback for common event subscription.
   * @param error Error information.
   * @param data Event that is listened to.
   */
  private subscribeCallBack(error: BusinessError, data: commonEventManager.CommonEventData) {
    if (error) {
      hilog.error(domainId, logTag, `Failed to subscribe. errCode: ${error.code}, message: ${error.message}`);
      return;
    }
    if (canIUse("SystemCapability.Notification.CommonEvent")) {
      hilog.info(domainId, logTag, `Succeeded in subscribing. ${data.event}`);
      // If the event of enabling the youth mode is received:
      if (data.event === commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON) {
        AppStorage.setOrCreate('minorsProtectionMode', true);
        AppStorage.setOrCreate('availableTimeMode', true);
        const userTurnOffFlag: boolean | undefined = AppStorage.get<boolean>('userTurnOffFlag');
        // If the flag for disabling the app's youth mode separately is true, the youth mode in the app is disabled.
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
      if (data.event === commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN) {
        this.context.eventHub.emit('userLogin');
      }
      if (data.event === commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT) {
        this.context.eventHub.emit('userLogout');
      }
    } else {
      // The API is not supported on this device.
      hilog.error(domainId, logTag, 'The API is not supported on this device.');
    }
  }
}
