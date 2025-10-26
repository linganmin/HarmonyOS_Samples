import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { fido } from '@kit.OnlineAuthenticationKit';
import { ConnectService } from '../ConnectService';
import { Util } from '../util/Util';
import { FidoReg } from '../bean/FidoReg';

@Entry
@Component
struct Index {
  con = new ConnectService();
  uiContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Row() {
      Column() {
        Button('discover')
          .margin(20)
          .width(200)
          .onClick(async () => {
            try {
              let discoverData: fido.DiscoveryData = await fido.discover(this.uiContext);
              hilog.info(0x0000, 'TAG', `FidoTest-Index------discover: ${JSON.stringify(discoverData)}`);
              try {
                promptAction.openToast({
                  message: JSON.stringify(discoverData),
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
            } catch (error) {
              hilog.error(0x0000, 'TAG', `FidoTest-Index------discover: ${error}`);
              try {
                const err = error as BusinessError;
                promptAction.openToast({
                  message: '' + err.code + err.message,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
            }
          })

        Button('开启')
          .margin(20)
          .width(200)
          .onClick(async () => {
            // 访问FIDO服务端策略检查请求报文
            hilog.info(0x0000, 'TAG', 'FidoTest-Index------开启 start');
            let message: string = await this.con.selectType('UAF_REG');
            let uafMessage: fido.UAFMessage = {
              uafProtocolMessage: message,
              additionalData: ''
            };
            // 传连接通道参数（可选）
            let channelBinding: fido.ChannelBinding = {};
            try {
              hilog.info(0x0000, 'TAG', 'FidoTest-Index------开启 call processUAFOperation');
              let messageResp: fido.UAFMessage = await fido.processUAFOperation(this.uiContext, uafMessage, channelBinding);
              let uafProtocolMessage: string = messageResp.uafProtocolMessage;
              hilog.info(0x0000, 'TAG', `FidoTest-Index------uafProtocolMessage: ${uafProtocolMessage}`);
              let par = Util.SpP('regResp', uafProtocolMessage);
              let regResp: string = await Util.connectFidoServer1(ConnectService.url + 'fidoreg', par);
              let isReg = regResp.includes('fidoreg');
              if (isReg) {
                let regPar: FidoReg = JSON.parse(regResp);
                let fidoreg = ConnectService.base64.decodeSync(regPar.fidoreg);
                if (fidoreg.length > 0) {
                  let uafMess = Util.uint8ArrayToString(fidoreg);
                  let uafMessage: fido.UAFMessage = {
                    uafProtocolMessage: uafMess,
                    additionalData: ''
                  };
                  try {
                    // 调用notifyUAFResult进行注册结果通知
                    fido.notifyUAFResult(this.uiContext, uafMessage).then(() => {
                      hilog.info(0x0000, 'TAG', 'FidoTest-Index------notify:成功');
                    });
                  } catch (error) {
                    hilog.error(0x0000, 'TAG', `notify: ${error}`);
                  }

                  try {
                    promptAction.openToast({
                      message: 'UAF_REG:成功',
                      duration: 2000
                    });
                  } catch (error) {
                    let message = (error as BusinessError).message;
                    let code = (error as BusinessError).code;
                    hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
                  }
                  hilog.info(0x0000, 'TAG', 'UAF_REG:成功');
                }
              }
            } catch (error) {
              try {
                const err = error as BusinessError;
                promptAction.openToast({
                  message: '' + err.code + err.message,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
              hilog.error(0x0000, 'TAG', `processUAFOperation args error code is ${error.code}, message is ${error.message}`);
            }
          });

        Button('认证')
          .margin(20)
          .width(200)
          .onClick(async () => {
            let message: string = await this.con.selectType('UAF_AUTH');
            let uafMessage: fido.UAFMessage = {
              uafProtocolMessage: message,
              additionalData: ''
            };
            let channelBinding: fido.ChannelBinding = {};
            try {
              let messageResp: fido.UAFMessage = await fido.processUAFOperation(this.uiContext, uafMessage, channelBinding);
              let uafProtocolMessage: string = messageResp.uafProtocolMessage;
              hilog.info(0x0000, 'TAG', `FidoTest-Index------uafProtocolMessage: ${uafProtocolMessage}`);
              let par = Util.SpP('loginAuthResp', uafProtocolMessage);
              let authResp: string = await Util.connectFidoServer1(ConnectService.url + 'fidoauth', par);
              let isAuth = authResp.includes('userinfo');
              if (isAuth) {
                try {
                  promptAction.openToast({
                    message: 'UAF_AUTH:成功',
                    duration: 2000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
                }
                hilog.info(0x0000, 'TAG', 'UAF_AUTH:成功');
              }
            } catch (error) {
              try {
                const err = error as BusinessError;
                promptAction.openToast({
                  message: '' + err.code + err.message,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
              hilog.error(0x0000, 'TAG', `processUAFOperation args error code is ${error.code}, message is ${error.message}`);
            }
          });

        Button('关闭')
          .margin(20)
          .width(200)
          .onClick(async () => {
            let message: string = await this.con.selectType('UAF_DEREG');
            let uafMessage: fido.UAFMessage = {
              uafProtocolMessage: message,
              additionalData: ''
            };
            let channelBinding: fido.ChannelBinding = {};
            try {
              let messageResp: fido.UAFMessage = await fido.processUAFOperation(this.uiContext, uafMessage, channelBinding);
              let uafProtocolMessage: string = messageResp.uafProtocolMessage;
              hilog.info(0x0000, 'TAG', `FidoTest-Index------uafProtocolMessage: ${uafProtocolMessage}`);
              try {
                promptAction.openToast({
                  message: 'UAF_DEREG:成功',
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
            } catch (error) {
              try {
                const err = error as BusinessError;
                promptAction.openToast({
                  message: '' + err.code + err.message,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
              hilog.error(0x0000, 'TAG', `processUAFOperation args error code is ${error.code}, message is ${error.message}`);
            }
          });

        Button('check policy')
          .margin(20)
          .width(200)
          .onClick(async () => {
            let message: string = await this.con.selectType('UAF_AUTH');
            let uafMessage: fido.UAFMessage = {
              uafProtocolMessage: message,
              additionalData: ''
            };
            try {
              await fido.checkPolicy(this.uiContext, uafMessage).then(() => {
                hilog.info(0x0000, 'TAG', 'FidoTest-Index------check policy-成功');
                try {
                  promptAction.openToast({
                    message: '已开启',
                    duration: 2000
                  });
                } catch (error) {
                  let message = (error as BusinessError).message;
                  let code = (error as BusinessError).code;
                  hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
                }
                ;
              })
            } catch (error) {
              try {
                const err = error as BusinessError;
                promptAction.openToast({
                  message: '' + err.code + err.message,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                hilog.error(0x0000, 'TAG', `openToast args error code is ${code}, message is ${message}`);
              }
              hilog.error(0x0000, 'TAG', `checkPolicy args error code is ${error.code}, message is ${error.message}`);
            }
          });
      }
      .width('100%')
    }
    .height('100%')
  }
}