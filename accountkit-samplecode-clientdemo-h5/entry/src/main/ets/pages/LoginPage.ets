/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { webview } from '@kit.ArkWeb';
import { NodeRenderType } from "@kit.ArkUI";
import { loginComponentManager } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginComponentNodeController } from '../components/SameLayerRendering';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ErrorCode } from '../common/ErrorCodeEntity';
import { dealAllError, showNetWorkError } from '../common/Utils';
import { connection } from '@kit.NetworkKit';

interface EventData {
  eventId: string,
  value?: string
}

enum EventID {
  AGREE_LOGIN = 'agreeLogin',
  OPEN_PRIVACY = 'openPrivacy',
  AGREE_PRIVACY = 'agreePrivacy',
  HIDDEN_PRIVACY_MODEL = 'hiddenPrivacyModel',
  BACK_PRESS = 'backPress',
}

@Component
export struct LoginPage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  private logTag: string = "LoginPage";
  private domainId: number = 0x0000;
  private browserTabController: WebviewController = new webview.WebviewController();
  private isShowPrivacyModel: boolean = false;
  @State nodeController?: LoginComponentNodeController = undefined;
  @State componentIdArr: Array<string> = [];
  private ports: webview.WebMessagePort[] = [];
  @StorageProp('quickLoginAnonymousPhone') quickLoginAnonymousPhone: string = '';
  @State clickPrivacy: boolean = false;
  private loginController: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickEvent(() => {
        // The user has tapped the one-tap sign-in button.
        this.postMessage('loginStart');
      })
      .onClickLoginWithHuaweiIDButton((err: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // Return the one-tap sign-in result.
        this.postMessage('loginEnd');
        if (err) {
          hilog.error(this.domainId, this.logTag, `login Error: errCode is ${err.code}, message is ${err.message}`);
          /*
           * If the user does not check the box for accepting the agreements,
           * send the message to the HTML5 side and display a pop-up, asking the user to check the agreements.
           * */
          if (err.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
            this.postMessage('notAccepted');
            // The pop-up is shown, and will be closed if the back gesture is triggered.
            this.isShowPrivacyModel = true;
            return;
          }
          dealAllError(err, this.getUIContext());
        } else {
          // Obtain sign-in information.
          const authorizationCode = response.authorizationCode;
          // Process code.
          // ...

          // Redirect to the personal information screen.
          this.pageInfos.pushPathByName('PersonalInfoPage', null, true);
        }
        return;
      });

  aboutToAppear() {
    hilog.info(this.domainId, this.logTag, 'LoginPage aboutToAppear');
    // Configure Web to start the debug mode. Disable the debug mode during official use.
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  // Send data to the HTML5 side.
  postMessage(eventId: string, value = '') {
    if (this.ports && this.ports[1]) {
      // Encrypt sensitive data for transfer.
      const eventData: EventData = { eventId, value }
      this.ports[1].postMessageEvent(JSON.stringify(eventData));
    } else {
      console.error('Ports is null, Please initialize first');
    }
  }

  // Receive data sent from the HTML5 side.
  private async handleMessage(result: webview.WebMessage) {
    if (typeof result === 'string') {
      hilog.info(this.domainId, this.logTag, `Get message from H5: ${result}`);
      const eventData = JSON.parse(result) as EventData;
      switch (eventData.eventId) {
        case EventID.AGREE_LOGIN:
          // Accept & sign in.
          this.loginController.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
          this.loginController.continueLogin((err: BusinessError) => {
            if (err) {
              dealAllError(err, this.getUIContext());
            }
          });
          break;

        case EventID.OPEN_PRIVACY:
          // Redirect to the screen that contains the privacy agreement.
          const hasNet: boolean = connection.hasDefaultNetSync();
          if (!hasNet) {
            // Show a pop-up message indicating that the network is unavailable.
            showNetWorkError(this.getUIContext());
            break;
          }
          const params: Record<string, Object> = {
            'protocolUrl': eventData.value as string
          }
          this.pageInfos.pushDestinationByName('ProtocolWebView', params, true);
          break;

        case EventID.AGREE_PRIVACY:
          // Change of the checkbox status for accepting the privacy agreement.
          if (eventData.value) {
            this.loginController.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
          } else {
            this.loginController.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
          }
          break;

        case EventID.HIDDEN_PRIVACY_MODEL:
          // The user taps Cancel to close the pop-up.
          this.isShowPrivacyModel = false;
          break;

        case EventID.BACK_PRESS:
          // The user triggers the back gesture.
          this.pageInfos.pop();
          break;

        default:
          hilog.info(this.domainId, this.logTag, `eventId is ${eventData.eventId}`);
      }
    }
  }

  build() {
    NavDestination() {
      Stack() {
        // The custom node BuilderNode is returned in NodeController and is mounted on a node in NodeContainer.
        NodeContainer(this.nodeController)
        // Load the local HTML page using the Web component.
        Web({
          src: $rawfile("html/login.html"),
          controller: this.browserTabController,
          renderMode: RenderMode.SYNC_RENDER
        })
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .enableNativeEmbedMode(true) // Enable same-layer rendering.
          .overScrollMode(OverScrollMode.NEVER)
          .onPageEnd(() => {
            try {
              // Create two message ports.
              this.ports = this.browserTabController.createWebMessagePorts(true);
              /*
               * Send a message port to the HTML side. The HTML side saves and uses the port.
               * You can pass the URI that can receive the message through the third parameter.
               * The asterisk (*) indicates that all URIs are matched.
               * */
              this.browserTabController.postMessage('__init_port__', [this.ports[0]], '*');
              // Register a callback for the other message port on the app side.
              this.ports[1].onMessageEvent((result: webview.WebMessage) => {
                this.handleMessage(result);
              })
            } catch (err) {
              hilog.error(this.domainId, this.logTag,
                `Failed to create the message channel. Code is ${err.code}, message is ${err.message}.`
              );
            }
            // Send the anonymous mobile number to the HTML5 page.
            this.postMessage('quickLoginAnonymousPhone', this.quickLoginAnonymousPhone);
          })
          // Obtain the lifecycle change data of the embed tag.
          .onNativeEmbedLifecycleChange((embed) => {
            hilog.info(this.domainId, this.logTag, 'status is' + embed.status)
            // Create the same-layer tag.
            if (embed.status === NativeEmbedStatus.CREATE || embed.status === NativeEmbedStatus.UPDATE) {
              // Create a node controller, set parameters, and implement rebuild.
              this.nodeController = new LoginComponentNodeController(this.loginController);
              /*
               * The unit of embed.info.width and embed.info.height is px,
               * which needs to be converted to the default unit vp on the ETS side.
               * */
              this.nodeController.setRenderOption({
                surfaceId: embed.surfaceId as string,
                type: embed.info?.type as string,
                renderType: NodeRenderType.RENDER_TYPE_TEXTURE,
                width: this.getUIContext().px2vp(embed.info?.width),
                height: this.getUIContext().px2vp(embed.info?.height)
              });
            } else if (embed.status == NativeEmbedStatus.DESTROY) {
              console.log("NativeEmbed status" + embed.status);
              this.nodeController?.setDestroy(true)
              this.nodeController = undefined;
            } else {
              console.log("NativeEmbed status" + embed.status);
            }
          })
          .onNativeEmbedGestureEvent((touch) => {
            hilog.info(this.domainId, this.logTag, `ativeEmbed onNativeEmbedGestureEvent ${touch.touchEvent?.type}`);
            let ret = this.nodeController?.postEvent(touch.touchEvent)
            if (touch.result) {
              // Notify the Web component of the gesture event consumption result.
              touch.result.setGestureEventResult(ret);
            }
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.isShowPrivacyModel) {
        // The pop-up is shown. If the back gesture is triggered, close the pop-up.
        this.postMessage('hiddenPrivacyModel');
        this.isShowPrivacyModel = false;
        return true;
      } else {
        return false;
      }
    })
  }
}