/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
// HuaweiAuthButtonNativeComponent: This function is used to register components with the JavaScript runtime.
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { DirectEventHandler, Int32, WithDefault } from 'react-native/Libraries/Types/CodegenTypes';

/*
 * Parameters of the button to be controlled.
 */
// Response body of a successful tap.
export type OnLoginSuccessEventData = Readonly<{
  authorizationCode: string;
}>;

// Response body of a tap failure.
export type OnLoginFailureEventData = Readonly<{
  errorCode: Int32;
  errorMessage: string;
}>;

// Response body of onClickEvent.
export type OnClickEventData = Readonly<{
  errorCode: Int32;
  errorMessage: string;
  eventType: Int32;
}>;

// customButtonParams of the one-tap sign-in button.
export type CustomButtonParamsOject = Readonly<{
  fontColor: Int32;
  backgroundColor: string;
}>;

// Props is used to customize parameters of React components.
export interface ButtonNativeProps extends ViewProps {
  buttonStyle: Int32;
  buttonBorderRadius?: Int32;
  loginType?: Int32;
  supportDarkMode?: boolean;
  verifyPhoneNumber?: boolean;
  customButtonParams?: CustomButtonParamsOject;
  agreementStatus?: WithDefault<'NOT_ACCEPTED' | 'ACCEPTED', 'NOT_ACCEPTED'>;
  onLoginSuccess?: DirectEventHandler<OnLoginSuccessEventData>;
  onLoginFailure?: DirectEventHandler<OnLoginFailureEventData>;
  onClickEventResult?: DirectEventHandler<OnClickEventData>;
}

// Register the callback for one-tap sign-in.
type HuaweiAuthButtonType = HostComponent<ButtonNativeProps>;

export interface NativeCommands {
  setAgreementStatus: (
    viewRef: React.ElementRef<HuaweiAuthButtonType>,
    agreementStatus: string,
  ) => void;
  continueLogin: (
    viewRef: React.ElementRef<HuaweiAuthButtonType>,
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'setAgreementStatus',
    'continueLogin'
  ],
});

// Register parameters to be controlled with Fabric, so these parameters can be called on the RN side.
export default codegenNativeComponent<ButtonNativeProps>(
  'RNHuaweiAuthButton',
) as HostComponent<ButtonNativeProps>;
