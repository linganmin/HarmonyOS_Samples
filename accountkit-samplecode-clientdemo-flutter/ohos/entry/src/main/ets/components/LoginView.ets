/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */
import MethodChannel, { MethodCallHandler, } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MessageCodec,
  PlatformViewFactory,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { AvoidRepeatClick, dealAllError, showNetWorkError } from '../common/Utils';
import { ErrorCode } from '../common/ErrorCodeEntity';
import { connection } from '@kit.NetworkKit';

const logTag: string = 'ButtonComponent';
const domainId: number = 0x0000;

class LoginInfo {
  public authCode: string;

  constructor(authCode: string) {
    this.authCode = authCode;
  }
}

// Define the one-tap sign-in component.
@Component
struct ButtonComponent {
  @StorageLink('agreementStatus') @Watch('watchAgreementStatus') agreementStatus: boolean = false;
  @StorageLink('reOpenDialog') @Watch('reOpenDialogChange') reOpenDialog: boolean = false;
  @StorageLink('loginLoading') loading: boolean = false;
  @Prop params: Params;
  private privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: $r('app.string.agree'),
      type: loginComponentManager.TextType.PLAIN_TEXT
    }, {
    text: $r('app.string.shopping_user_agreement'),
    type: loginComponentManager.TextType.RICH_TEXT,

    // Change the link to that of your own privacy policy.
    // ...
  }, {
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.shopping_privacy_policy'),
    type: loginComponentManager.TextType.RICH_TEXT,

    // Change the link to that of your own privacy policy.
    // ...
  }, {
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.and'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.huaweiId_user_authentication_protocol'),
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: 'tag'
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }
  ];
  customView: CustomView = this.params?.platformView as CustomView;
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.agreementDialog.close();
      },
      confirm: () => {
        this.agreementDialog.close();
        this.customView.sendMessage('AgreementStatusChanged', '1');
        this.customView.sendMessage('loginStart', '');
        this.loading = true;
        this.agreementStatus = true;
        // Set the agreement status to ACCEPTED.
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        /*
         * Call this method to complete accepting the agreements and signing in at the same time.
         * There is no need to tap the sign-in button again.
         * */
        this.controller.continueLogin((error: BusinessError) => {
          if (error) {
            hilog.error(domainId, logTag,
              `Failed to login with agreementDialog. errCode is ${error.code}, message is ${error.message}`);
          } else {
            hilog.info(domainId, logTag, 'Succeeded in clicking agreementDialog continueLogin.');
            // After the sign-in is successful, the server processes the response result.
            // ...
          }
        });
      },
      openDialog: () => {
        this.agreementDialog.open();
      },
      closeDialog: () => {
        this.agreementDialog.close();

      },
      jumpToPrivacyWebView: () => {
        const hasNet: boolean = connection.hasDefaultNetSync();
        if (hasNet) {
          this.customView.sendMessage('openPrivacy', '');
          this.agreementDialog.close();
        } else {
          showNetWorkError();
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  watchAgreementStatus(): void {
    hilog.info(domainId, logTag, `this.agreementStatus is ${this.agreementStatus}`);
    if (this.agreementStatus) {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
    } else {
      this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
    }
  }

  reOpenDialogChange() {
    if (this.reOpenDialog) {
      this.agreementDialog.open();
      this.reOpenDialog = false;
    }
  }

  controller = new loginComponentManager.LoginWithHuaweiIDButtonController()
    .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
    .onClickEvent(() => {
      this.customView.sendMessage('loginStart', '');
      this.loading = true;
    })
    .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
      this.customView.sendMessage('loginEnd', '');
      this.loading = false;
      // Process the sign-in result.
      if (error) {
        if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
          // The user does not accept the agreement, and an agreement pop-up is displayed.
          this.agreementDialog.open();
        } else {
          dealAllError(error);
        }
        return;
      }
      // Obtain sign-in information.
      const authCode = response.authorizationCode;

      // Send data to the Dart side. Encrypt sensitive data in your actual development.
      this.customView.sendMessage('loginSuccess', JSON.stringify(new LoginInfo(authCode)));
    });

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
        supportDarkMode: true
      },
      controller: this.controller
    }).id('login_with_huaweiId_button')
  }
}

// Define the builder method and add the one-tap sign-in component to the builder method.
@Builder
function ButtonBuilder(params: Params) {
  ButtonComponent({ params: params })
}

// Extend PlatformView to implement a custom view, implement the getView API, and return WrappedBuilder (ButtonBuilder) through getView.
@Observed
class CustomView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;
  context?: common.Context;
  args?: Object;

  constructor(context: common.Context, viewId: number, args: Object, message: BinaryMessenger) {
    super();
    this.context = context;
    this.args = args;
    // Register the message channel.
    this.methodChannel =
      new MethodChannel(message, `com.example.flutter_login/loginView${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);

    // Send the anonymous mobile number.
    this.sendMessage('quickLoginAnonymousPhone', AppStorage.get('quickLoginAnonymousPhone') as string);
  }

  onMethodCall(call: MethodCall): void {
    // Receive messages from the Dart side.
    let method: string = call.method;
    hilog.info(domainId, logTag, method);
    switch (method) {
      case 'AgreementStatusChanged': {
        let value: boolean = call.args;
        let link: SubscribedAbstractProperty<boolean> = AppStorage.link('agreementStatus');
        link.set(value);
        break;
      }

      case 'openPrivacy': {
        const hasNet: boolean = connection.hasDefaultNetSync();
        if (hasNet) {
          this.sendMessage('openPrivacy', '0');
        } else {
          showNetWorkError();
        }
        break;
      }

      case 'reOpenDialog': {
        const link: SubscribedAbstractProperty<boolean> = AppStorage.link('reOpenDialog');
        link.set(true);
        break;
      }

      default: {
        // Unprocessed messages.
        break;
      }
    }
  }

  public sendMessage = (method: string, data: string) => {
    // Send messages to the Dart side.
    hilog.info(domainId, logTag, `method = ${method}`);
    this.methodChannel.invokeMethod(method, data);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ButtonBuilder);
  }

  dispose(): void {
  }
}

// Implement PlatformViewFactory and create a CustomView instance in the create method.
class CustomFactory extends PlatformViewFactory {
  message: BinaryMessenger;

  constructor(message: BinaryMessenger, createArgsCodes: MessageCodec<Object>) {
    super(createArgsCodes);
    this.message = message;
  }

  public create(context: common.Context, viewId: number, args: Object): PlatformView {
    return new CustomView(context, viewId, args, this.message);
  }
}

// Create a plugin that extends FlutterPlugin and register CustomFactory in onAttachedToEngine.
export default class LoginPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'LoginPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory('com.example.flutter_login/loginView', new CustomFactory(binding.getBinaryMessenger(),
      StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(): void {
  }
}

@CustomDialog
struct AgreementDialog {
  dialogController?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  openDialog: () => void = () => {
  };
  closeDialog: () => void = () => {
  };
  jumpToPrivacyWebView: () => void = () => {
  };
  privacyText: loginComponentManager.PrivacyText[] = [];

  build() {
    Column() {
      Row() {
        Text($r('app.string.user_agreement_and_privacy_policy'))
          .id('loginPanel_agreement_dialog_privacy_title')
          .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
          .minFontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 56, maxWidth: 400 })
      .margin({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Row() {
        Text() {
          if (this.privacyText && this.privacyText.length > 0) {
            ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
              if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                Span(item?.text)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
              } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                Span(item?.text)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('app.color.activity_color'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .focusable(true)
                  .focusOnTouch(true)
                  .id('protocolUrlToPrivacyWebViewSpan')
                  .onClick(() => {
                    hilog.info(domainId, logTag, 'protocol url click');
                    AvoidRepeatClick.avoidRepeatClick(() => {
                      if (item?.tag) {
                        this.jumpToPrivacyWebView();
                      }
                    });
                  })
              }
            }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
          }
        }
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(10)
        .textAlign(TextAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
      }
      .width('100%')
      .padding({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Flex({
        direction: FlexDirection.Row
      }) {
        Button($r('app.string.cancel'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .backgroundColor(Color.Transparent)
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .margin({ right: 8 })
          .width('50%')
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .id('cancelAgreementDialogButton')
          .onClick(() => {
            hilog.info(domainId, logTag, 'AgreementDialog cancel');
            AvoidRepeatClick.avoidRepeatClick(() => {
              this.cancel();
            });
          })

        Button($r('app.string.agree_and_sign_in'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_dialog_huawei_id_login_btn')
          .fontColor(Color.White)
          .backgroundColor($r('app.color.activity_color'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .margin({ left: 8 })
          .width('50%')
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .id('agreeAndSignInButton')
          .onClick(() => {
            hilog.info(domainId, logTag, 'AgreementDialog confirm');
            AvoidRepeatClick.avoidRepeatClick(() => {
              this.confirm();
            });
          })
      }
      .margin({
        top: 8,
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        bottom: 16
      })
    }.backgroundColor($r('sys.color.ohos_id_color_dialog_default_bg'))
  }
}
