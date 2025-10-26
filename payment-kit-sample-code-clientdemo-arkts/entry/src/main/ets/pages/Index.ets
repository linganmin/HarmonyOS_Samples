/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  requestPaymentPromise() {
    // use your own orderStr
    const orderStr = '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
    paymentService.requestPayment(this.context, orderStr)
      .then(() => {
        // succeeded in paying
        console.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        // failed to pay
        console.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }

  requestPaymentCallBack() {
    // use your own orderStr
    const orderStr = '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
    paymentService.requestPayment(this.context, orderStr, (error: BusinessError) => {
      if (error) {
        // failed to pay
        console.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        return;
      }
      // succeeded in paying
      console.info('succeeded in paying');
    })
  }

  requestContractPromise() {
    // use your own contractStr
    const contractStr = '{"appId":"***","preSignNo":"***"}';
    paymentService.requestContract(this.context, contractStr)
      .then(() => {
        // succeed in signing
        console.info('succeeded in signing');
      })
      .catch((error: BusinessError) => {
        // failed to sign
        console.error(`failed to sign, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }

  requestContractCallBack() {
    // use your own contractStr
    const contractStr = '{"appId":"***","preSignNo":"***"}';
    paymentService.requestContract(this.context, contractStr, (error: BusinessError) => {
      if (error) {
        // failed to sign
        console.error(`failed to sign, error.code: ${error.code}, error.message: ${error.message}`);
        return;
      }
      // succeed in signing
      console.info('succeeded in signing');
    })
  }

  build() {
    Column() {
      Button('requestPaymentPromise')
        .type(ButtonType.Capsule)
        .width('50%')
        .margin(20)
        .onClick(() => {
          this.requestPaymentPromise();
        })
      Button('requestPaymentCallBack')
        .type(ButtonType.Capsule)
        .width('50%')
        .margin(20)
        .onClick(() => {
          this.requestPaymentCallBack();
        })
      Button('requestContractPromise')
        .type(ButtonType.Capsule)
        .width('50%')
        .margin(20)
        .onClick(() => {
          this.requestContractPromise();
        })
      Button('requestContractCallBack')
        .type(ButtonType.Capsule)
        .width('50%')
        .margin(20)
        .onClick(() => {
          this.requestContractCallBack();
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}