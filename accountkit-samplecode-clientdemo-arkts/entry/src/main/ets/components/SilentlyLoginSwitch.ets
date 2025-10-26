/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { getUnionID, showErrorMessage } from '../common/Utils';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';

@Component
export struct SilentlyLoginSwitch {
  @Link isSilentLogin: boolean;
  onChange?: (unionID: string) => void; // Callback for updating user information after authorization.

  // Change the value of whether to use silent sign-in.
  private updateIsSilentLogin() {
    getUnionID(this.getUIContext().getHostContext()).then((unionID: string) => {
      // Change the switch status.
      this.isSilentLogin = !this.isSilentLogin;
      if (this.onChange) {
        // Update user data with unionId.
        this.onChange(unionID);
      }
    })
      .catch((error: BusinessError) => {
        showErrorMessage(this.getUIContext(), error);
      })
  }

  build() {
    Row() {
      Text($r('app.string.use_hwid_silently_login'))
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .fontWeight(FontWeight.Medium)
        .height('100%')
      Row() {
        Button({ type: ButtonType.Normal }) {
          Toggle({ type: ToggleType.Switch, isOn: this.isSilentLogin })
            .selectedColor($r('app.color.activity_color'))
            .hitTestBehavior(HitTestMode.None)
        }
        .height(50)
        .width(50)
        .borderRadius(8)
        .backgroundColor(Color.Transparent)
        .id('useHwidSilentlyLoginButton')
        .onClick(() => {
          AvoidRepeatClick.avoidRepeatClick(() => {
            this.updateIsSilentLogin();
          });
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({
      left: 12,
      right: 12,
      top: 4,
      bottom: 4
    })
    .margin({ top: 12 })
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(20)
  }
}