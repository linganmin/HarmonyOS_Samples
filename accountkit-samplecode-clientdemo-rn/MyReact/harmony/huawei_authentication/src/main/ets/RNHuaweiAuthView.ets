/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
// Import the content generated via Codegen.
import { RNC } from "@rnoh/react-native-openharmony/generated";
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const logTag: string = 'AccountDemo';
const domainId: number = 0x0000;
const SUCCESS_STATUS: number = 0;
const DEFAULT_EVENT_TYPE: number = -1;

// Command, corresponding to the content in RN/react-native-huawei-authentication/src/specs/HuaweiAuthButtonNativeComponent.ts.
const enum COMMAND {
  SET_AGREEMENT_STATUS = 'setAgreementStatus',
  CONTINUE_LOGIN = 'continueLogin'
}

@Component
export struct RNHuaweiAuthButton {
  public static readonly NAME = RNC.RNHuaweiAuthButton.NAME
  public ctx!: RNComponentContext
  public tag: number = 0
  @State private descriptorWrapper: RNC.RNHuaweiAuthButton.DescriptorWrapper =
    {} as RNC.RNHuaweiAuthButton.DescriptorWrapper
  private eventEmitter: RNC.RNHuaweiAuthButton.EventEmitter | undefined = undefined
  private cleanUpCallbacks: (() => void)[] = []
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        hilog.info(domainId, logTag, "OnClickLoginWithHuaweiIDButton");
        if (error) {
          hilog.error(domainId, logTag,
            `Failed to login with LoginWithHuaweiIDButton. errCode is ${error?.code}, errMessage is ${error?.message}`);
          this.eventEmitter?.emit("loginFailure", {
            errorCode: error.code,
            errorMessage: error.message,
          })
        } else {
          hilog.info(domainId, logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          this.eventEmitter?.emit("loginSuccess", {
            authorizationCode: response?.authorizationCode
          })
        }
      })
      .onClickEvent((error: BusinessError, clickEvent: loginComponentManager.ClickEvent) => {
        if (error) {
          hilog.error(domainId, logTag, `Failed in onClickEvent, error: ${JSON.stringify(error)}`);
          this.eventEmitter?.emit("clickEventResult", {
            errorCode: error.code,
            errorMessage: error.message,
            eventType: DEFAULT_EVENT_TYPE,
          })
        } else {
          this.eventEmitter?.emit("clickEventResult", {
            errorCode: SUCCESS_STATUS,
            errorMessage: '',
            eventType: clickEvent,
          })
        }
      });

  aboutToAppear() {
    // RN
    hilog.info(domainId, logTag, "aboutToAppear");
    this.eventEmitter = new RNC.RNHuaweiAuthButton.EventEmitter(this.ctx.rnInstance, this.tag)
    this.onDescriptorWrapperChange(
      this.ctx.descriptorRegistry.findDescriptorWrapperByTag<RNC.RNHuaweiAuthButton.DescriptorWrapper>(this.tag)!)
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (_descriptor, newDescriptorWrapper) => {
        this.onDescriptorWrapperChange(newDescriptorWrapper! as RNC.RNHuaweiAuthButton.DescriptorWrapper)
      }
    ))
    // Define the callback for component property updates, including the agreement status and the tap event.
    this.cleanUpCallbacks.push(this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: (boolean | number | string)[]) => {
        if (command === COMMAND.SET_AGREEMENT_STATUS) {
          // Implement the setAgreementStatus command on the HarmonyOS side.
          hilog.info(domainId, logTag, `Command: setAgreementStatus, args: ${JSON.stringify(args)}`);
          this.controller.setAgreementStatus((args.length !== 0 && args[0] === 'ACCEPTED') ?
          loginComponentManager.AgreementStatus.ACCEPTED : loginComponentManager.AgreementStatus.NOT_ACCEPTED);
        } else if (command === COMMAND.CONTINUE_LOGIN) {
          // Implement the continueLogin command on the HarmonyOS side.
          hilog.info(domainId, logTag, "Command: continueLogin");
          this.controller.continueLogin((error: BusinessError) => {
            hilog.info(domainId, logTag, "ContinueLogin");
            if (error) {
              hilog.error(domainId, logTag, `Failed in continueLogin, error: ${JSON.stringify(error)}`);
              this.eventEmitter?.emit("loginFailure", {
                errorCode: error.code,
                errorMessage: error.message,
              })
            } else {
              hilog.info(domainId, logTag, "Succeeded in continueLogin");
            }
          });
        }
      }))
  }

  // Modify the status of the checkbox for accepting the agreements.
  private onDescriptorWrapperChange(descriptorWrapper: RNC.RNHuaweiAuthButton.DescriptorWrapper) {
    this.descriptorWrapper = descriptorWrapper
    hilog.info(domainId, logTag,
      `OnDescriptorWrapperChange, input parameter: ${JSON.stringify(this.descriptorWrapper.props)}`);
    this.controller.setAgreementStatus(this.descriptorWrapper.props.agreementStatus === 'ACCEPTED' ?
    loginComponentManager.AgreementStatus.ACCEPTED : loginComponentManager.AgreementStatus.NOT_ACCEPTED)
  }

  aboutToDisappear() {
    this.cleanUpCallbacks.forEach(cb => cb())
  }

  // One-tap sign-in button (UI).
  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      LoginWithHuaweiIDButton({
        params: {
          style: this.descriptorWrapper.props.buttonStyle,
          extraStyle: {
            buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({show: true})
          },
          borderRadius: this.descriptorWrapper.props.buttonBorderRadius ?? 24,
          loginType: this.descriptorWrapper.props.loginType ?? loginComponentManager.LoginType.QUICK_LOGIN,
          supportDarkMode: this.descriptorWrapper.props.supportDarkMode ?? true,
          customButtonParams: {
            fontColor: this.descriptorWrapper.props.customButtonParams?.fontColor ?? 0,
            backgroundColor: this.descriptorWrapper.props.customButtonParams?.backgroundColor ?? '',
          },
          verifyPhoneNumber: this.descriptorWrapper.props.verifyPhoneNumber ?? true,
        },
        controller: this.controller
      })
        .height(this.descriptorWrapper.height) // Obtain the height from the RN side (property example).
    }

  }
}
