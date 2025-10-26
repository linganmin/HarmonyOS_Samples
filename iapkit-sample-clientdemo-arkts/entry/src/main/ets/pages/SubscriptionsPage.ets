/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { iap } from '@kit.IAPKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { JWSUtil } from '../common/JWSUtil';
import Logger from '../common/Logger';
import {
  FinishStatus,
  PurchaseData,
  PurchaseOrderPayload,
  SubGroupStatusPayload,
  SubStatus
} from '../common/IapDataModel';

const TAG: string = 'SubscriptionsPage';

@Builder
export function SubscriptionsPageBuilder() {
  SubscriptionsPage();
}

@Entry
@Component
struct SubscriptionsPage {
  private context: common.UIAbilityContext = {} as common.UIAbilityContext;
  private vpValue = this.getUIContext().px2vp(136);
  @State querying: boolean = true;
  @State queryingFailed: Boolean = false;
  @State productInfoArray: ProductInfo[] = [];
  @State queryFailedText: string = 'Query failed';

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.onCase();
  }

  async onCase() {
    this.showLoadingPage();
    const queryEnvCode = await this.queryEnv();
    if (queryEnvCode !== 0) {
      let queryEnvFailedText = 'This app does not support iap';
      if (queryEnvCode === iap.IAPErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        queryEnvFailedText = 'Go to Settings and log in to your Huawei ID and try again.';
      }
      this.showFailedPage(queryEnvFailedText);
      return;
    }
    const queryProductsCode = await this.queryProducts();
    queryProductsCode === 0 && this.queryPurchases(iap.PurchaseQueryType.CURRENT_ENTITLEMENT);
  }

  async queryEnv(): Promise<number> {
    return new Promise<number>((resolve) => {
      iap.queryEnvironmentStatus(this.context).then(() => {
        Logger.info(TAG, 'Succeeded in querying environment status.');
        resolve(0);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to query environment status. Code is ${err.code}, message is ${err.message}`);
        resolve(err.code);
      })
    });
  }

  queryPurchases(queryType: iap.PurchaseQueryType): Promise<void> {
    return new Promise<void>((resolve) => {
      const param: iap.QueryPurchasesParameter = {
        productType: iap.ProductType.AUTORENEWABLE,
        queryType: queryType
      };
      iap.queryPurchases(this.context, param).then((res: iap.QueryPurchaseResult) => {
        Logger.info(TAG, 'Succeeded in querying purchases.');
        const purchaseDataList: string[] = res.purchaseDataList;
        if (purchaseDataList === undefined || purchaseDataList.length <= 0) {
          Logger.info(TAG, 'queryPurchases, purchaseDataList empty');
          resolve();
          return;
        }
        for (let i = 0; i < purchaseDataList.length; i++) {
          this.dealPurchaseData(purchaseDataList[i]);
        }
        resolve();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to query purchases. Code is ${err.code}, message is ${err.message}`);
        resolve();
      }).finally(() => {
        this.showNormalPage();
      });
    });
  }

  dealPurchaseData(purchaseData: string) {
    try {
      // You are advised to send purchaseData to the app server for signature verification.
      const jwsSubscriptionStatus = (JSON.parse(purchaseData) as PurchaseData).jwsSubscriptionStatus;
      if (!jwsSubscriptionStatus) {
        Logger.error(TAG, 'dealPurchaseData, jwsSubscriptionStatus invalid');
        return;
      }
      // Decode jwsSubscriptionStatus and perform signature verification.
      const subscriptionStatus = JWSUtil.decodeJwsObj(jwsSubscriptionStatus);
      if (!subscriptionStatus) {
        Logger.error(TAG, 'dealPurchaseData, subscriptionStatus invalid');
        return;
      }
      const subGroupStatusPayload = JSON.parse(subscriptionStatus) as SubGroupStatusPayload;
      const lastSubscriptionStatus = subGroupStatusPayload.lastSubscriptionStatus;
      if (!lastSubscriptionStatus) {
        Logger.error(TAG, 'dealPurchaseData, lastSubscriptionStatus is invalid');
        return;
      }
      if (lastSubscriptionStatus.status === SubStatus.ACTIVE) {
        // The subscription has taken effect, you need to deliver the product.
        const productId = lastSubscriptionStatus.renewalInfo?.productId;
        if (productId) {
          this.setProductInfoStatus(subGroupStatusPayload.subGroupId, productId, lastSubscriptionStatus.status);
        }
        // Ensure that the delivery is successful before performing the following steps.
      }
      const purchaseOrderPayload = lastSubscriptionStatus.lastPurchaseOrder;
      if (purchaseOrderPayload && purchaseOrderPayload.finishStatus !== FinishStatus.FINISHED) {
        // Send a finishPurchase request to IAP Kit to acknowledge the delivery and complete the purchase.
        this.finishPurchase(purchaseOrderPayload);
      }
    } catch (e) {
      Logger.error(TAG, 'dealPurchaseData json error');
    }
  }

  finishPurchase(purchaseOrder: PurchaseOrderPayload) {
    if (!purchaseOrder.productType) {
      Logger.error(TAG, 'finishPurchase but productType is empty');
      return;
    }
    const finishPurchaseParam: iap.FinishPurchaseParameter = {
      productType: Number(purchaseOrder.productType),
      purchaseToken: purchaseOrder.purchaseToken,
      purchaseOrderId: purchaseOrder.purchaseOrderId
    };
    iap.finishPurchase(this.context, finishPurchaseParam).then(() => {
      Logger.info(TAG, 'Succeeded in finishing purchase.');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to finish purchase. Code is ${err.code}, message is ${err.message}`);
    });
  }

  private setProductInfoStatus(groupId: string, productId: string, status: string) {
    for (let i = 0; i < this.productInfoArray.length; i++) {
      if (groupId !== this.productInfoArray[i].subscriptionInfo?.groupId) {
        continue;
      }
      const curProduct: ProductInfo = JSON.parse(JSON.stringify(this.productInfoArray[i]));
      if (this.productInfoArray[i].id === productId) {
        curProduct.subStatus = status;
      } else {
        curProduct.subStatus = '';
      }
      this.productInfoArray[i] = curProduct;
    }
  }

  async queryProducts(): Promise<number> {
    return new Promise<number>((resolve) => {
      const queryProductParam: iap.QueryProductsParameter = {
        productType: iap.ProductType.AUTORENEWABLE,
        productIds: ['Sub001', 'KH003', 'FH301']
      };
      iap.queryProducts(this.context, queryProductParam).then((result) => {
        Logger.info(TAG, 'Succeeded in querying products.');
        // show product details
        this.productInfoArray = result;
        resolve(0);
      }).catch((err: BusinessError) => {
        // queryProducts error
        Logger.error(TAG, `Failed to query products. Code is ${err.code}, message is ${err.message}`);
        this.showFailedPage();
        resolve(err.code);
      });
    });
  }

  subscribe(id: string, type: iap.ProductType) {
    try {
      const createPurchaseParam: iap.PurchaseParameter = {
        productId: id,
        productType: type,
      }
      iap.createPurchase(this.context, createPurchaseParam).then((result) => {
        const msg: string = 'Succeeded in creating purchase.';
        Logger.info(TAG, msg);
        promptAction.openToast({
          message:  msg,
          duration: 2000,
        });
        this.dealPurchaseData(result.purchaseData);
      }).catch((err: BusinessError) => {
        const msg: string = `Failed to create purchase. Code is ${err.code}, message is ${err.message}`;
        Logger.error(TAG, msg);
        promptAction.openToast({
          message:  msg,
          duration: 2000,
        });
        if (err.code === iap.IAPErrorCode.PRODUCT_OWNED || err.code === iap.IAPErrorCode.SYSTEM_ERROR) {
          this.queryPurchases(iap.PurchaseQueryType.UNFINISHED);
        }
      })
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      const msg: string = `Failed to create purchase. Code is ${e.code}, message is ${e.message}`;
      Logger.error(TAG, msg);
      promptAction.openToast({
        message:  msg,
        duration: 2000,
      });
    }
  }

  showLoadingPage() {
    this.queryingFailed = false;
    this.querying = true;
  }

  showFailedPage(failedText?: string) {
    if (failedText) {
      this.queryFailedText = failedText;
    }
    this.queryingFailed = true;
    this.querying = false;
  }

  showNormalPage() {
    this.queryingFailed = false;
    this.querying = false;
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        Column() {
        }
        .backgroundColor('#F1F3F5')
        .width("100%")
        .height(this.vpValue)

        Column() {
          Row() {
            Text('Subscriptions')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 24, right: 24 })
          }
          .margin({ top: 16, bottom: 12 })
          .height(48)
          .justifyContent(FlexAlign.Start)
          .width('100%')

          List({ space: 0, initialIndex: 0 }) {
            ForEach(this.productInfoArray, (item: ProductInfo) => {
              ListItem() {
                Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                  Image($r('app.media.fortune'))
                    .height(48)
                    .width(48)
                    .objectFit(ImageFit.Contain)

                  Text(item.name)
                    .width('100%')
                    .height(48)
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .padding({ left: 12, right: 12 })

                  Button(item?.subStatus === '1' ? 'Effected' : (item.localPrice ? item.localPrice : 'Buy'))
                    .width(200)
                    .fontSize(16)
                    .height(30)
                    .onClick(() => {
                      if (item?.subStatus === '1') {
                        this.showSubManaged(iap.WindowScreenMode.DIALOG_BOX, item?.subscriptionInfo?.groupId);
                        return;
                      }
                      this.subscribe(item.id, item.type)
                    })
                    .stateEffect(true)
                }
                .borderRadius(16)
                .backgroundColor('#FFFFFF')
                .alignSelf(ItemAlign.Auto)
              }
            })
          }
          .divider({ strokeWidth: 1, startMargin: 2, endMargin: 2 })
          .padding({ left: 12, right: 12 })
          .margin({ left: 12, right: 12 })
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .alignSelf(ItemAlign.Auto)

          Column() {
            Button('Show Subscriptions List')
              .width('100%')
              .fontSize(16)
              .height(30)
              .onClick(() => {
                this.showSubManaged(iap.WindowScreenMode.FULLSCREEN);
              })
              .stateEffect(true)
              .margin({ top: 12 })
          }.margin({ left: 24, right: 24 })
        }
        .backgroundColor('#F1F3F5')
        .width('100%')
        .height('100%')
        .visibility(this.querying || this.queryingFailed ? Visibility.None : Visibility.Visible)

        Stack() {
          LoadingProgress()
            .width(96)
            .height(96)
        }
        .backgroundColor('#F1F3F5')
        .width('100%')
        .height('100%')
        .visibility(this.querying ? Visibility.Visible : Visibility.None)

        Stack({ alignContent: Alignment.Center }) {
          Text(this.queryFailedText)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 24, right: 24 })
        }
        .backgroundColor('#F1F3F5')
        .width('100%')
        .height('100%')
        .visibility(this.queryingFailed ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.onCase();
        })
      }
    }.hideTitleBar(true)
  }

  private showSubManaged(windowMode: number, groupId: string = '') {
    const winParam: iap.UIWindowParameter = {
      windowScreenMode: windowMode
    };
    iap.showManagedSubscriptions(this.getUIContext().getHostContext(), winParam, groupId).then(() => {
      Logger.info(TAG, 'Succeeded in showing subscription page.');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to show subscription page. Code is ${err.code}, message is ${err.message}`);
    });
  }
}

interface ProductInfo extends iap.Product {
  subStatus?: string;
}