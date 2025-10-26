/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { common } from '@kit.AbilityKit';
import { walletPass } from '@kit.WalletKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonComp } from '../../components/CommonComp';
import { CommonTitle } from '../../components/CommonTitle';
import {
  selectListQueryPassDeviceInfo,
  selectListCanAddPass,
  selectListInitWalletEnvironment,
  selectListAddPass,
  selectListQueryPass,
  selectListUpdatePass,
  selectListDeletePass,
  selectListViewPass,
  selectListQueryICCEConnectionState,
  selectListStartICCEConnection,
  selectListRegisterICCEListener,
  selectListUnregisterICCEListener,
  selectListSendICCERKEMessage,
} from '../../common/ConstUtil'
import { CommonCompAddPass } from '../../components/CommonCompAddPass';
import { ICCECallBack } from './ICCECallBack';
import { rpc } from '@kit.IPCKit';


@Entry
@Component
struct Pass {
  // Initialize
  private walletPassClient: walletPass.WalletPassClient =
    new walletPass.WalletPassClient(getContext(this) as common.UIAbilityContext);
  private callback: rpc.RemoteObject | null = null;
  // Interface parameters
  @State jweContent: string = '' // JWE data. The pass card is unique. The actual data needs to be obtained from the DK server.
  private passType: string = 'hwpass.stdcarkey.bluecarkey.mgqa' // Service ID. Common access card: hwpass.ac.common; super access card: hwpass.pass.superaccesscard.src
  private targetDeviceType: string = '' // Indicates the target device type. The options are mobile phone and wearable. The default value is mobile phone and wearable. All: mobile phone and wearable.
  private serialNumber: string = '' // Unique ID of pass. Actual data needs to be obtained from the DK server.
  private registerName: string = '' // Name of the package for registering ICCE listening
  private rkeCommand: string = '' // ICCE vehicle control command
  // Content displayed on the page
  @State textQueryPassDeviceInfo: string = ''
  @State textCanAddPass: string = ''
  @State textInitWalletEnvironment: string = ''
  @State textAddPass: string = ''
  @State textQueryPass: string = ''
  @State textUpdatePass: string = ''
  @State textDeletePass: string = ''
  @State textViewPass: string = ''
  @State textQueryICCEConnectionState: string = ''
  @State textStartICCEConnection: string = ''
  @StorageLink('ICCEData') @Watch('onICCEDataUpdate') ICCEData: string = ''
  @State textRegisterICCEListener: string = ''
  @State textSendICCERKEMessage: string = ''
  @State textUnregisterICCEListener: string = ''
  // Interface type. This parameter is used only for tests
  @State codeQueryPassDeviceInfo: string = '0'
  @State codeCanAddPass: string = '0'
  @State codeInitWalletEnvironment: string = '0'
  @State codeAddPass: string = '0'
  @State codeQueryPass: string = '0'
  @State codeUpdatePass: string = '0'
  @State codeDeletePass: string = '0'
  @State codeViewPass: string = '0'
  @State codeQueryICCEConnectionState: string = '0'
  @State codeStartICCEConnection: string = '0'
  @State codeRegisterICCEListener: string = '0'
  @State codeSendICCERKEMessage: string = '0'
  @State codeUnregisterICCEListener: string = '0'

  onICCEDataUpdate(propName: string): void {
    if (this.ICCEData) {
      this.textRegisterICCEListener = `The data from the wallet is received successfully：${this.ICCEData}`;
      return
    }
    this.textRegisterICCEListener = `Connection data reset successfully`;
  }

  // Querying Pass Information
  async queryPassDeviceInfo() {
    console.info(`DEMO queryPassDeviceInfo called`);
    let passStr = JSON.stringify({
      type: Number(this.codeQueryPassDeviceInfo),
      passType: this.passType,
      targetDeviceType: this.targetDeviceType,
    })
    this.walletPassClient.queryPassDeviceInfo(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO queryPassDeviceInfo Promise success,result:${result}`);
      this.textQueryPassDeviceInfo = 'success,result:' + result

    }).catch((err: BusinessError) => {
      console.error(`DEMO queryPassDeviceInfo Promise failed,code:${err.code},message:${err.message}`);
      this.textQueryPassDeviceInfo = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Check whether a pass card can be added
  async canAddPass() {
    console.info(`DEMO canAddPass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeCanAddPass),
      passType: this.passType,
      targetDeviceType: this.targetDeviceType,
    })
    this.walletPassClient.canAddPass(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO canAddPass Promise success,result:${result}`);
      this.textCanAddPass = 'success,result:' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO canAddPass Promise failed,code:${err.code},message:${err.message}`);
      this.textCanAddPass = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Initializing the Wallet Environment
  async initWalletEnvironment() {
    console.info(`DEMO initWalletEnvironment called`);
    let passStr = JSON.stringify({
      type: Number(this.codeInitWalletEnvironment),
      targetDeviceType: this.targetDeviceType,
    })
    this.walletPassClient.initWalletEnvironment(passStr).then(() => {
      // Perform a successful operation...
      console.info(`DEMO initWalletEnvironment Promise success`);
      this.textInitWalletEnvironment = 'success'
    }).catch((err: BusinessError) => {
      console.error(`DEMO initWalletEnvironment Promise failed,code:${err.code},message:${err.message}`);
      this.textInitWalletEnvironment = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Card opening
  async addPass() {
    console.info(`DEMO addPass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeAddPass),
      jweContent: this.jweContent,
    })
    this.walletPassClient.addPass(passStr).then((result: string) => {
      // Perform a successful operation...
      if (result) {
        console.info(`DEMO addPass Promise success,result:${result}`);
        this.textAddPass = 'success!! serialNumber: ' + result
        this.serialNumber = JSON.parse(result).result
      }
    }).catch((err: BusinessError) => {
      console.error(`DEMO addPass Promise failed,code:${err.code},message:${err.message}`);
      this.textAddPass = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Query card
  async queryPass() {
    console.info(`DEMO queryPass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeQueryPass),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    this.walletPassClient.queryPass(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO queryPass Promise success,result: ${result}`);
      this.textQueryPass = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO queryPass Promise failed,code:${err.code},message:${err.message}`);
      this.textQueryPass = `failed,code:${err.code} message:${err.message} `
    })
  }

  // View card
  async viewPass() {
    console.info(`DEMO viewPass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeViewPass),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    try {
      await this.walletPassClient.viewPass(passStr);
      console.info(`DEMO viewPass success`);
    } catch (err) {
      console.info(`DEMO viewPass failed,code:${err.code} message:${err.message}`);
      this.textViewPass = `failed,code:${err.code} message:${err.message} `
    }
  }

  // Update card
  async updatePass() {
    console.info(`DEMO updatePass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeUpdatePass),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    this.walletPassClient.updatePass(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO updatePass Promise success,result: ${result}`);
      this.textUpdatePass = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO updatePass Promise failed,code:${err.code},message:${err.message}`);
      this.textUpdatePass = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Delete card
  async deletePass() {
    console.info(`DEMO deletePass called`);
    let passStr = JSON.stringify({
      type: Number(this.codeDeletePass),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    this.walletPassClient.deletePass(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO deletePass Promise success,result: ${result}`);
      this.textDeletePass = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO deletePass Promise failed,code:${err.code},message:${err.message}`);
      this.textDeletePass = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Querying the ICCE Connection Status
  async queryICCEConnectionState() {
    console.info(`DEMO queryICCEConnectionState called`);
    let passStr = JSON.stringify({
      type: Number(this.codeQueryICCEConnectionState),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    this.walletPassClient.queryICCEConnectionState(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO queryICCEConnectionState Promise success,result: ${result}`);
      this.textQueryICCEConnectionState = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO queryICCEConnectionState Promise failed,code:${err.code},message:${err.message}`);
      this.textQueryICCEConnectionState = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Start the ICCE Connection
  async startICCEConnection() {
    console.info(`DEMO startICCEConnection called`);
    let passStr = JSON.stringify({
      type: Number(this.codeStartICCEConnection),
      passType: this.passType,
      serialNumber: this.serialNumber,
    })
    this.walletPassClient.startICCEConnection(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO startICCEConnection Promise success,result: ${result}`);
      this.textStartICCEConnection = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO startICCEConnection Promise failed,code:${err.code},message:${err.message}`);
      this.textStartICCEConnection = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Registering the ICCE Listening
  async registerICCEListener() {
    console.info(`DEMO registerICCEListener called`);
    let passStr = JSON.stringify({
      type: Number(this.codeRegisterICCEListener),
      passType: this.passType,
      registerName: this.registerName,
    })

    this.callback = new ICCECallBack();
    this.walletPassClient.registerICCEListener(passStr, this.callback).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO registerICCEListener Promise success,result: ${result}`);
      this.textRegisterICCEListener = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO registerICCEListener Promise failed,code:${err.code},message:${err.message}`);
      this.textRegisterICCEListener = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Sending the ICCE Messages
  async sendICCERKEMessage() {
    console.info(`DEMO sendICCERKEMessage called`);
    let passStr = JSON.stringify({
      type: Number(this.codeSendICCERKEMessage),
      passType: this.passType,
      serialNumber: this.serialNumber,
      rkeCommand: this.rkeCommand,
      encryptFlag: '0',
      directionFlag: '1'
    })
    this.walletPassClient.sendICCERKEMessage(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO sendICCERKEMessage Promise success,result: ${result}`);
      this.textSendICCERKEMessage = 'success,result: ' + result
    }).catch((err: BusinessError) => {
      console.error(`DEMO sendICCERKEMessage Promise failed,code:${err.code},message:${err.message}`);
      this.textSendICCERKEMessage = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Destroying the ICCE Listening
  async unregisterICCEListener() {
    console.info(`DEMO unregisterICCEListener called`);
    let passStr = JSON.stringify({
      type: Number(this.codeUnregisterICCEListener),
      passType: this.passType,
      registerName: this.registerName,
    })

    this.walletPassClient.unregisterICCEListener(passStr).then((result: string) => {
      // Perform a successful operation...
      console.info(`DEMO unregisterICCEListener Promise success,result: ${result}`);
      this.textUnregisterICCEListener = 'success,result: ' + result
      this.callback = null;
      AppStorage.setOrCreate<string>('ICCEData', '')
    }).catch((err: BusinessError) => {
      console.error(`DEMO unregisterICCEListener Promise failed,code:${err.code},message:${err.message}`);
      this.textUnregisterICCEListener = `failed,code:${err.code} message:${err.message} `
    })
  }

  build() {
    Scroll() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
        CommonTitle({ title: $r('app.string.Prerequisites') })
        CommonComp({
          mText: 'queryPassDeviceInfo',
          selectList: selectListQueryPassDeviceInfo,
          code: this.codeQueryPassDeviceInfo,
          text: this.textQueryPassDeviceInfo,
          handleClick: () => {
            this.queryPassDeviceInfo()
          }
        })
        CommonComp({
          mText: 'canAddPass',
          selectList: selectListCanAddPass,
          code: this.codeCanAddPass,
          text: this.textCanAddPass,
          handleClick: () => {
            this.canAddPass()
          }
        })
        CommonTitle({ title: $r('app.string.Initialize') })
        CommonComp({
          mText: 'initWalletEnvironment',
          selectList: selectListInitWalletEnvironment,
          code: this.codeInitWalletEnvironment,
          text: this.textInitWalletEnvironment,
          handleClick: () => {
            this.initWalletEnvironment()
          }
        })
        CommonTitle({ title: $r('app.string.Public_Card_Operation') })
        CommonCompAddPass({
          mText: 'addPass',
          selectList: selectListAddPass,
          code: this.codeAddPass,
          text: this.textAddPass,
          jwe: this.jweContent,
          handleClick: () => {
            this.addPass()
          }
        })
        CommonComp({
          mText: 'queryPass',
          selectList: selectListQueryPass,
          code: this.codeQueryPass,
          text: this.textQueryPass,
          handleClick: () => {
            this.queryPass()
          }
        })
        CommonComp({
          mText: 'updatePass',
          selectList: selectListUpdatePass,
          code: this.codeUpdatePass,
          text: this.textUpdatePass,
          handleClick: () => {
            this.updatePass()
          }
        })
        CommonComp({
          mText: 'deletePass',
          selectList: selectListDeletePass,
          code: this.codeDeletePass,
          text: this.textDeletePass,
          handleClick: () => {
            this.deletePass()
          }
        })
        CommonComp({
          mText: 'viewPass',
          selectList: selectListViewPass,
          code: this.codeViewPass,
          text: this.textViewPass,
          handleClick: () => {
            this.viewPass()
          }
        })
        CommonTitle({ title: 'ICCE' })
        CommonComp({
          mText: 'queryICCEConnectionState',
          selectList: selectListQueryICCEConnectionState,
          code: this.codeQueryICCEConnectionState,
          text: this.textQueryICCEConnectionState,
          handleClick: () => {
            this.queryICCEConnectionState()
          }
        })
        CommonComp({
          mText: 'startICCEConnection',
          selectList: selectListStartICCEConnection,
          code: this.codeStartICCEConnection,
          text: this.textStartICCEConnection,
          handleClick: () => {
            this.startICCEConnection()
          }
        })
        CommonComp({
          mText: 'registerICCEListener',
          selectList: selectListRegisterICCEListener,
          code: this.codeRegisterICCEListener,
          text: this.textRegisterICCEListener,
          handleClick: () => {
            this.registerICCEListener()
          }
        })
        CommonComp({
          mText: 'sendICCERKEMessage',
          selectList: selectListSendICCERKEMessage,
          code: this.codeSendICCERKEMessage,
          text: this.textSendICCERKEMessage,
          handleClick: () => {
            this.sendICCERKEMessage()
          }
        })
        CommonComp({
          mText: 'unregisterICCEListener',
          selectList: selectListUnregisterICCEListener,
          code: this.codeUnregisterICCEListener,
          text: this.textUnregisterICCEListener,
          handleClick: () => {
            this.unregisterICCEListener()
          }
        })
      }

    }
    .scrollable(ScrollDirection.Vertical)
    .width('100%')
    .height('100%')
    .padding({ left: 10, top: 20, right: 10 })
  }
}