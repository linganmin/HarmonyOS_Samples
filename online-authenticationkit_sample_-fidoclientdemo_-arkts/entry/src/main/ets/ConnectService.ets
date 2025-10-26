import { common, Want } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { FidoReg } from './bean/FidoReg';
import { FidoAuth } from './bean/FidoAuth';
import { FidoDereg } from './bean/FidoDereg';
import { Util } from './util/Util';
import { hilog } from '@kit.PerformanceAnalysisKit';

export enum AuthType {
  Face = '16',
  Fingerprint = '2',
}

const SERVER_URL = 'FIDO服务器地址' //FIDO 服务器地址，http://xxxx
const AUTHTYPE = AuthType.Face; // fido使用生物类型

export class ConnectService {
  static base64 = new util.Base64Helper;
  static url = SERVER_URL;
  static userAuthType = AUTHTYPE;

  async connectService(uiContext: common.UIAbilityContext, strUAFConnectType: string) {
    let want: Want = {
      bundleName: 'com.huawei.hmos.fido',
      abilityName: 'ServiceExtAbility'
    };

    let options: common.ConnectOptions = {
      onConnect(elementName, remote) {
        elementName;
        hilog.info(0x0000, 'TAG', 'onConnect...');
        let option: rpc.MessageOption = new rpc.MessageOption(0);
        let data: rpc.MessageSequence = rpc.MessageSequence.create();
        let reply: rpc.MessageSequence = rpc.MessageSequence.create();

        data.writeString(strUAFConnectType);
        hilog.info(0x0000, 'TAG', 'before sendMessage...');
        remote.sendMessageRequest(0, data, reply, option)
          .then(async (result: rpc.RequestResult) => {
            if (result.errCode != 0) {
              hilog.error(0x0000, 'TAG', `send request failed, errCode: ${result.errCode}`);
              return;
            }
            hilog.info(0x0000, 'TAG', 'get result');
          })
          .catch((err: BusinessError) => {
            console.error(`Failed to send request. Code: ${err.code}, message: ${err.message}`);
          })
          .finally(() => {
            data.reclaim();
            reply.reclaim();
          })
      },
      onDisconnect(elementName) {
        elementName;
        hilog.info(0x0000, 'TAG', 'onDisconnect...');
      },
      onFailed(code) {
        code;
        hilog.info(0x0000, 'TAG', 'onFailed...');
      }
    };
    try {
      uiContext.connectServiceExtensionAbility(want, options);
    } catch (err) {
      console.error(`Failed to connectServiceExtensionAbility. Code: ${err.code}, message: ${err.message}`);
    }
  }

  async selectType(strUAFConnectType: string): Promise<string> {
    let uafMessage: string = ''
    switch (strUAFConnectType) {
      case 'DISCOVER': // discover
        strUAFConnectType = 'DISCOVER';
        break;
      case 'UAF_REG': // register
        strUAFConnectType = 'UAF_REG';
        let regReq = Util.fidoParameter('regReq', ConnectService.userAuthType);
        let reg: string = await Util.connectFidoServer(ConnectService.url + 'fidoreg', regReq);
        let isReg = reg.includes('fidoreg');
        if (isReg) {
          let regPar: FidoReg = JSON.parse(reg);
          let fidoreg = ConnectService.base64.decodeSync(regPar.fidoreg);
          uafMessage = Util.uint8ArrayToString(fidoreg);
        }
        break;
      case 'UAF_AUTH': // authenticate
        strUAFConnectType = 'UAF_AUTH';
        let authReq = Util.fidoParameter('authReq', ConnectService.userAuthType);
        let auth: string = await Util.connectFidoServer(ConnectService.url + 'fidoauth', authReq);
        let isAuth = auth.includes('fidoauth');
        if (isAuth) {
          let authPar: FidoAuth = JSON.parse(auth);
          let fidoAuth = ConnectService.base64.decodeSync(authPar.fidoauth);
          uafMessage = Util.uint8ArrayToString(fidoAuth);
        }
        break;
      case 'UAF_DEREG': // deregister
        strUAFConnectType = 'UAF_DEREG';
        let deReg = Util.fidoParameter('deReg', ConnectService.userAuthType);
        let dereg: string = await Util.connectFidoServer(ConnectService.url + 'fidodereg', deReg);
        let isDereg = dereg.includes('fidodereg');
        if (isDereg) {
          let deregPar: FidoDereg = JSON.parse(dereg);
          let fidoDereg = ConnectService.base64.decodeSync(deregPar.fidodereg);
          uafMessage = Util.uint8ArrayToString(fidoDereg);
          hilog.error(0x0000, 'TAG', `UAF_DEREG---uafMessage: ${uafMessage}`);
        }
        break;
      case 'CHECK_POLICY': // checkpolicy
        strUAFConnectType = 'CHECK_POLICY';
        break;
    }
    return uafMessage
  }
}