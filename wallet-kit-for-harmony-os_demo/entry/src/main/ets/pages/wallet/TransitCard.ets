/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { common } from '@kit.AbilityKit';
import { walletTransitCard } from '@kit.WalletKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonComp } from '../../components/CommonComp';
import { CommonTitle } from '../../components/CommonTitle';
import {
  selectListGetCardMetadataInDevice,
  selectListGetTransitCardInfo,
  selectListCanAddTransitCard,
  selectListSetupWalletEnvironment,
  selectListAddTransitCard,
  selectListRechargeTransitCard,
  selectListUpdateTransitCard,
  selectListDeleteTransitCard
} from '../../common/ConstUtil'


@Entry
@Component
struct TransitCard {
  // Initialize
  private callerId = 'callerId'
  private callerToken = 'callerToken'
  private transitCardClient = new walletTransitCard.TransitCardClient(getContext(this) as common.UIAbilityContext, this.callerId)
  // Interface parameters
  private specifiedDeviceType = walletTransitCard.DeviceType.DEVICE_PHONE
  private logicalCardNumber: string = ''
  private specifiedDeviceId: string = ''
  private issuerId: string = ''
  private addCardOpaqueData: string = ''
  private serverOrderId: string = ''
  // Content displayed on the page
  @State textGetCardMetadataInDevice: string = ''
  @State textGetTransitCardInfo: string = ''
  @State textCanAddTransitCard: string = ''
  @State textSetupWalletEnvironment: string = ''
  @State textAddTransitCard: string = ''
  @State textRechargeTransitCard: string = ''
  @State textUpdateTransitCard: string = ''
  @State textDeleteTransitCard: string = ''
  // Interface type. This parameter is used only for tests
  @State codeGetCardMetadataInDevice: string = '0'
  @State codeGetTransitCardInfo: string = '0'
  @State codeCanAddTransitCard: string = '0'
  @State codeSetupWalletEnvironment: string = '0'
  @State codeAddTransitCard: string = '0'
  @State codeRechargeTransitCard: string = '0'
  @State codeUpdateTransitCard: string = '0'
  @State codeDeleteTransitCard: string = '0'

  // Querying card meta information
  async getCardMetadataInDevice() {
    console.info(`DEMO getCardMetadataInDevice called`);
    this.transitCardClient.getCardMetadataInDevice(this.specifiedDeviceType, this.callerToken).then((result) => {
      // Perform a successful operation...
      console.info(`DEMO getCardMetadataInDevice Promise success,result:${JSON.stringify(result)}`);
      this.textGetCardMetadataInDevice = 'success,result:' + JSON.stringify(result)
    })
      .catch((err: BusinessError) => {
        console.error(`DEMO getCardMetadataInDevice Promise failed,code:${err.code},message:${err.message}`);
        this.textGetCardMetadataInDevice = `failed,code:${err.code} message:${err.message} `
      })
  }

  async getTransitCardInfo() {
    console.info(`DEMO getTransitCardInfo called`);
    this.logicalCardNumber = this.codeGetTransitCardInfo  // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.getTransitCardInfo(this.logicalCardNumber, this.specifiedDeviceId, this.callerToken)
      .then((result) => {
        // Perform a successful operation...
        console.info(`DEMO getTransitCardInfo Promise success,result:${JSON.stringify(result)}`);
        this.textGetTransitCardInfo = 'success,result:' + JSON.stringify(result)
      })
      .catch((err: BusinessError) => {
        console.error(`DEMO getTransitCardInfo Promise failed,code:${err.code},message:${err.message}`);
        this.textGetTransitCardInfo = `failed,code:${err.code} message:${err.message} `
      })
  }

  // Initializing the Wallet Environment
  async canAddTransitCard() {
    console.info(`DEMO canAddTransitCard called`);
    this.issuerId = this.codeCanAddTransitCard // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.canAddTransitCard(this.issuerId, this.specifiedDeviceId).then((result) => {
      // Perform a successful operation...
      console.info(`DEMO canAddTransitCard Promise success`);
      this.textCanAddTransitCard = 'Can Add'
    }).catch((err: BusinessError) => {
      console.error(`DEMO canAddTransitCard Promise failed,code:${err.code},message:${err.message}`);
      this.textCanAddTransitCard = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Card opening
  async setupWalletEnvironment() {
    console.info(`DEMO setupWalletEnvironment called`);
    this.transitCardClient.setupWalletEnvironment().then(() => {
      // Perform a successful operation...
      this.textSetupWalletEnvironment = 'Initialization succeeded'
    }).catch((err: BusinessError) => {
      console.error(`DEMO setupWalletEnvironment Promise failed,code:${err.code},message:${err.message}`);
      this.textSetupWalletEnvironment = `failed,code:${err.code} message:${err.message} `
    })
  }

  // Query card
  async addTransitCard() {
    console.info(`DEMO addTransitCard called`);
    this.addCardOpaqueData = this.codeAddTransitCard // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.addTransitCard(this.addCardOpaqueData, this.serverOrderId).then((result) => {
      // Perform a successful operation...
      console.info(`DEMO addTransitCard Promise success,result: ${JSON.stringify(result)}`);
      this.textAddTransitCard = 'success,result: ' + JSON.stringify(result)
    }).catch((err: BusinessError) => {
      console.error(`DEMO addTransitCard Promise failed,code:${err.code},message:${err.message}`);
      this.textAddTransitCard = `failed,code:${err.code} message:${err.message} `
    })
  }

  // View card
  async rechargeTransitCard() {
    console.info(`DEMO rechargeTransitCard called`);
    this.logicalCardNumber = this.codeRechargeTransitCard // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.rechargeTransitCard(this.logicalCardNumber, this.specifiedDeviceId, this.serverOrderId)
      .then((result) => {
        // Perform a successful operation...
        console.info(`DEMO rechargeTransitCard Promise success,result: ${result}`);
        this.textRechargeTransitCard = 'success,result: ' + result
      })
      .catch((err: BusinessError) => {
        console.error(`DEMO rechargeTransitCard Promise failed,code:${err.code},message:${err.message}`);
        this.textRechargeTransitCard = `failed,code:${err.code} message:${err.message} `
      })
  }

  // Update card
  async updateTransitCard() {
    console.info(`DEMO updateTransitCard called`);
    this.logicalCardNumber = this.codeUpdateTransitCard // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.updateTransitCard(this.logicalCardNumber, this.specifiedDeviceId, this.serverOrderId)
      .then(() => {
        // Perform a successful operation...
        console.info(`DEMO updateTransitCard Promise success`);
        this.textUpdateTransitCard = 'success'
      })
      .catch((err: BusinessError) => {
        console.error(`DEMO updateTransitCard Promise failed,code:${err.code},message:${err.message}`);
        this.textUpdateTransitCard = `failed,code:${err.code} message:${err.message} `
      })
  }

  // Delete card
  async deleteTransitCard() {
    console.info(`DEMO deleteTransitCard called`);
    this.logicalCardNumber = this.codeDeleteTransitCard // This parameter is required only when the sample demo is tested. Ignore it during actual development.
    this.transitCardClient.deleteTransitCard(this.logicalCardNumber, this.specifiedDeviceId, this.serverOrderId)
      .then(() => {
        // Perform a successful operation...
        console.info(`DEMO deleteTransitCard Promise success`);
        this.textDeleteTransitCard = 'success'
      })
      .catch((err: BusinessError) => {
        console.error(`DEMO deleteTransitCard Promise failed,code:${err.code},message:${err.message}`);
        this.textDeleteTransitCard = `failed,code:${err.code} message:${err.message} `
      })
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
      CommonTitle({ title: $r('app.string.Prerequisites') })
      CommonComp({
        mText: 'getCardMetadataInDevice',
        isEnabled: false,
        selectList: selectListGetCardMetadataInDevice,
        code: this.codeGetCardMetadataInDevice,
        text: this.textGetCardMetadataInDevice,
        handleClick: () => {
          this.getCardMetadataInDevice()
        }
      })
      CommonComp({
        mText: 'getTransitCardInfo',
        selectList: selectListGetTransitCardInfo,
        code: this.codeGetTransitCardInfo,
        text: this.textGetTransitCardInfo,
        handleClick: () => {
          this.getTransitCardInfo()
        }
      })
      CommonTitle({ title: $r('app.string.Initialize') })
      CommonComp({
        mText: 'canAddTransitCard',
        selectList: selectListCanAddTransitCard,
        code: this.codeCanAddTransitCard,
        text: this.textCanAddTransitCard,
        handleClick: () => {
          this.canAddTransitCard()
        }
      })
      CommonComp({
        mText: 'setupWalletEnvironment',
        isEnabled: false,
        selectList: selectListSetupWalletEnvironment,
        code: this.codeSetupWalletEnvironment,
        text: this.textSetupWalletEnvironment,
        handleClick: () => {
          this.setupWalletEnvironment()
        }
      })
      CommonTitle({ title: $r('app.string.Public_Card_Operation') })
      CommonComp({
        mText: 'addTransitCard',
        selectList: selectListAddTransitCard,
        code: this.codeAddTransitCard,
        text: this.textAddTransitCard,
        handleClick: () => {
          this.addTransitCard()
        }
      })
      CommonComp({
        mText: 'rechargeTransitCard',
        selectList: selectListRechargeTransitCard,
        code: this.codeRechargeTransitCard,
        text: this.textRechargeTransitCard,
        handleClick: () => {
          this.rechargeTransitCard()
        }
      })
      CommonComp({
        mText: 'updateTransitCard',
        selectList: selectListUpdateTransitCard,
        code: this.codeUpdateTransitCard,
        text: this.textUpdateTransitCard,
        handleClick: () => {
          this.updateTransitCard()
        }
      })
      CommonComp({
        mText: 'deleteTransitCard',
        selectList: selectListDeleteTransitCard,
        code: this.codeDeleteTransitCard,
        text: this.textDeleteTransitCard,
        handleClick: () => {
          this.deleteTransitCard()
        }
      })

    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, top: 20, right: 10 })
  }
}