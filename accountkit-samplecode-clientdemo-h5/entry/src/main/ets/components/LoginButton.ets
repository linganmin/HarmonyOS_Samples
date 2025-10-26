/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';

@Component
export struct LoginButton {
  loginController?: loginComponentManager.LoginWithHuaweiIDButtonController

  // Construct the controller of the LoginWithHuaweiIDButton component.
  constructor(loginController: loginComponentManager.LoginWithHuaweiIDButtonController) {
    super()
    this.loginController = loginController
  }

  build() {
    LoginWithHuaweiIDButton({
      params: {
        // Custom button style.
        style: loginComponentManager.Style.BUTTON_CUSTOM,
        extraStyle: {
          buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
            show: true
          })
        },
        loginType: loginComponentManager.LoginType.QUICK_LOGIN,
        iconRadius: 10,
      },
      controller: this.loginController
    })
  }
}