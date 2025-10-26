/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import React from "react";
import { NativeSyntheticEvent } from "react-native";
import HuaweiAuthButtonNativeComponent, {Commands as HuaweiAuthButtonCommands} from
    "./specs/HuaweiAuthButtonNativeComponent";
import type {
  ButtonNativeProps,
  OnLoginSuccessEventData,
  OnLoginFailureEventData,
  OnClickEventData
} from "./specs/HuaweiAuthButtonNativeComponent";

// Wrap the one-tap sign-in button using Fabric.
class LoginWithHuaweiIDButton extends React.Component<ButtonNativeProps> {
  private _huaweiAuthButtonRef: React.ElementRef<typeof HuaweiAuthButtonNativeComponent> | null = null;
  private _onLoginSuccess = (e: NativeSyntheticEvent<OnLoginSuccessEventData>) => {
    if (this.props.onLoginSuccess) {
      this.props.onLoginSuccess(e);
    }
  };

  private _onLoginFailure = (e: NativeSyntheticEvent<OnLoginFailureEventData>) => {
    if (this.props.onLoginFailure) {
      this.props.onLoginFailure(e);
    }
  };

  private _onClickEventResult = (e: NativeSyntheticEvent<OnClickEventData>) => {
    if (this.props.onClickEventResult) {
      this.props.onClickEventResult(e);
    }
  };

  public setAgreementStatus = (agreementStatus: 'ACCEPTED' | 'NOT_ACCEPTED') => {
    if (this._huaweiAuthButtonRef) {
      HuaweiAuthButtonCommands.setAgreementStatus(this._huaweiAuthButtonRef,agreementStatus);
    }
  };

  public continueLogin = () => {
    if (this._huaweiAuthButtonRef) {
      HuaweiAuthButtonCommands.continueLogin(this._huaweiAuthButtonRef);
    }
  };

  render() {
    return (
      <HuaweiAuthButtonNativeComponent
        {...this.props}
        ref={(ref)=>{
          this._huaweiAuthButtonRef = ref
        }}
        onLoginSuccess={this._onLoginSuccess}
        onLoginFailure={this._onLoginFailure}
        onClickEventResult={this._onClickEventResult}
      />
    );
  }
}

export default LoginWithHuaweiIDButton;
