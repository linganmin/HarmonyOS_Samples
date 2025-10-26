/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { minorsProtection } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';

const domainId: number = 0x0000;
const logTag: string = 'MinorsProtection';

@Component
export struct MinorsProtection {
  @Link minorsProtectionMode: boolean;
  @Link availableTimeMode: boolean;
  @Link userTurnOffFlag: boolean;
  @Link lowerAge: number;
  @Link upperAge: number;

  // Call the API for enabling the youth mode.
  private turnOnMinorsMode() {
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      // Check whether the current device supports the youth mode.
      try {
        if (!minorsProtection.supportMinorsMode()) {
          hilog.info(domainId, logTag,
            'The current device environment does not support the youth mode, please check the current device environment.');
          return;
        }
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to invoke supportMinorsMode. errCode: ${error.code}, message: ${error.message}`);
        return;
      }
      // Call the API for enabling the youth mode.
      minorsProtection.leadToTurnOnMinorsMode(this.getUIContext().getHostContext())
        .catch((error: BusinessError<Object>) => {
          hilog.error(domainId, logTag,
            `Failed to turnOnMinorsMode. errCode: ${error.code}, message: ${error.message}`);
        });
    } else {
      hilog.info(domainId, logTag,
        'The current device does not support the invoking of the leadToTurnOnMinorsMode interface.');
    }
  }

  // Call the API for verifying the youth mode password.
  private async verifyMinorsProtectionCredential(): Promise<boolean> {
    hilog.info(domainId, logTag, 'into verifyMinorsProtectionCredential');
    try {
      if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
        // Check whether the current device supports the youth mode.
        try {
          if (!minorsProtection.supportMinorsMode()) {
            hilog.info(domainId, logTag,
              'The current device environment does not support the youth mode, please check the current device environment.');
            return false;
          }
          const result = await minorsProtection.verifyMinorsProtectionCredential(this.getUIContext().getHostContext());
          hilog.info(domainId, logTag,
            `Succeeded in getting verifyMinorsProtectionCredential result: ${result.valueOf()}`);
          return result;
        } catch (error) {
          this.getUIContext().getPromptAction().showToast({ message: error.message });
          hilog.error(domainId, logTag,
            `Failed to invoke verifyMinorsProtectionCredential or supportMinorsMode. errCode: ${error.code}, errMessage: ${error.message}`);
          return false;
        }
      } else {
        hilog.info(domainId, logTag,
          'The current device does not support the invoking of the verifyMinorsProtectionCredential interface.');
        return false;
      }
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to invoke verifyMinorsProtectionCredential. errCode: ${error.code}, errMessage: ${error.message}`);
      return false;
    }
  }

  build() {
    // Youth mode.
    Column() {
      Row() {
        Text($r('app.string.minorProtection'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)
          .height('50%')

        Button({ type: ButtonType.Normal }) {
          Toggle({ type: ToggleType.Switch, isOn: this.minorsProtectionMode && !this.userTurnOffFlag })
            .selectedColor($r('app.color.activity_color'))
            .hitTestBehavior(HitTestMode.None)
        }
        .height(48)
        .width(48)
        .borderRadius(8)
        .id('minorProtectionButton')
        .onClick(() => {
          hilog.info(domainId, logTag, 'minorProtection onClick');
          AvoidRepeatClick.avoidRepeatClick(() => {
            // If the youth mode is enabled, a dialog box needs to be displayed when the user taps the switch.
            if (this.minorsProtectionMode) {
              if (this.userTurnOffFlag) {
                this.userTurnOffFlag = false;
              } else {
                this.getUIContext().showAlertDialog(
                  {
                    title: '',
                    subtitle: '',
                    message: $r('app.string.closeMinorsTitle'),
                    autoCancel: false,
                    alignment: DialogAlignment.Center,
                    gridCount: 4,
                    offset: { dx: 0, dy: -20 },
                    primaryButton: {
                      value: $r('app.string.cancel'),
                      action: () => {
                        hilog.info(domainId, logTag, 'Callback when the first button is clicked');
                      }
                    },
                    secondaryButton: {
                      value: $r('app.string.close'),
                      action: async () => {
                        // The user taps the button to disable the youth mode. The API for disabling the youth mode is called.
                        this.userTurnOffFlag = await this.verifyMinorsProtectionCredential();
                      }
                    },
                    cancel: () => {
                      hilog.info(domainId, logTag, 'Closed callbacks');
                    },
                    textStyle: {
                      wordBreak: WordBreak.BREAK_WORD
                    }
                  }
                )
              }
            } else {
              // Call the API for enabling the youth mode.
              this.turnOnMinorsMode();
            }
          });
        })
        .backgroundColor(Color.Transparent)
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height(56)
      .padding({
        top: 4,
        bottom: 4
      })

      Column() {
        if (this.minorsProtectionMode && !this.userTurnOffFlag) {
          Row() {
            Divider().strokeWidth(0.5)
          }

          Row() {
            Text($r('app.string.ageAppropriateContent'))
              .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
              .fontWeight(FontWeight.Medium)
              .height('50%')
            Text($r('app.string.age', this.lowerAge, this.upperAge))
              .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }.height(56)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            top: 4,
            bottom: 4
          })

          Row() {
            Divider().strokeWidth(0.5)
          }

          Row() {
            Text($r('app.string.availableTime'))
              .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
              .fontWeight(FontWeight.Medium)
              .height('50%')
            Button({ type: ButtonType.Normal }) {
              Toggle({ type: ToggleType.Switch, isOn: this.availableTimeMode })
                .selectedColor($r('app.color.activity_color'))
                .hitTestBehavior(HitTestMode.None)
            }
            .height(48)
            .width(48)
            .borderRadius(8)
            .id('availableTimeButton')
            .onClick(() => {
              AvoidRepeatClick.avoidRepeatClick(async () => {
                // Password is required for adjusting youth mode–related settings.
                const result = await this.verifyMinorsProtectionCredential();
                if (result) {
                  this.availableTimeMode = !this.availableTimeMode;
                }
              });
            })
            .backgroundColor(Color.Transparent)
          }.width('100%')
          .height(56)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            top: 4,
            bottom: 4
          })
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(this.minorsProtectionMode && !this.userTurnOffFlag ? 168 : 56)
    .padding({
      left: 12,
      right: 12
    })
    .margin({ top: 12 })
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(20)
    .constraintSize({
      minHeight: 56
    })
  }
}