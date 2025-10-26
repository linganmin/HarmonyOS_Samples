/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { iap } from '@kit.IAPKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { JWSUtil } from '../common/JWSUtil';
import Logger from '../common/Logger';
import { FinishStatus, PurchaseData, PurchaseOrderPayload } from '../common/IapDataModel';

const TAG: string = 'NonConsumablesPage';

@Builder
export function NonConsumablesPageBuilder() {
  NonConsumablesPage();
}

@Entry
@Component
struct NonConsumablesPage {
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
    queryProductsCode === 0 && this.queryPurchases();
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

  queryPurchases(): Promise<void> {
    return new Promise<void>((resolve) => {
      const param: iap.QueryPurchasesParameter = {
        productType: iap.ProductType.NONCONSUMABLE,
        queryType: iap.PurchaseQueryType.CURRENT_ENTITLEMENT
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
      const jwsPurchaseOrder = (JSON.parse(purchaseData) as PurchaseData).jwsPurchaseOrder;
      if (!jwsPurchaseOrder) {
        Logger.error(TAG, 'dealPurchaseData, jwsPurchaseOrder invalid');
        return;
      }
      // Decode jwsPurchaseOrder and perform signature verification.
      const purchaseOrderStr = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
      const purchaseOrderPayload = JSON.parse(purchaseOrderStr) as PurchaseOrderPayload;
      if (!purchaseOrderPayload) {
        Logger.error(TAG, 'dealPurchaseData, purchaseOrderPayload invalid');
        return;
      }
      // If the verification is successful, deliver the product.
      this.setProductInfoConsume(purchaseOrderPayload.productId, true);
      // After the delivery is successful, send a finishPurchase request to IAP Kit to acknowledge the delivery
      // and complete the purchase.
      if (purchaseOrderPayload && purchaseOrderPayload.finishStatus !== FinishStatus.FINISHED) {
        this.finishPurchase(purchaseOrderPayload);
      }
    } catch (e) {
      Logger.error(TAG, 'dealPurchaseData json error');
    }
  }

  finishPurchase(purchaseOrder: PurchaseOrderPayload) {
    Logger.info(TAG, 'finishPurchase begin');
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

  private setProductInfoConsume(productId: string, isConsume: boolean) {
    for (let i = 0; i < this.productInfoArray.length; i++) {
      if (this.productInfoArray[i].id === productId) {
        const curProduct: ProductInfo = JSON.parse(JSON.stringify(this.productInfoArray[i]));
        curProduct.isConsume = isConsume;
        this.productInfoArray[i] = curProduct;
        return;
      }
    }
    Logger.info(TAG, `setProductInfoConsume, result productId is not match`);
  }

  async queryProducts(): Promise<number> {
    return new Promise<number>((resolve) => {
      Logger.info(TAG, 'queryProducts begin.');
      const queryProductParam: iap.QueryProductsParameter = {
        productType: iap.ProductType.NONCONSUMABLE,
        productIds: ['NC00001']
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

  buy(id: string, type: iap.ProductType, isConsumables?: boolean) {
    if (isConsumables) {
      promptAction.openToast({
        message:  `aready owned`,
        duration: 2000,
      });
      return;
    }
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
          this.queryPurchases();
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
            Text('Non-consumables')
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

                  Button(item?.isConsume ? 'owned' : (item.localPrice ? item.localPrice : 'Buy'))
                    .width(200)
                    .fontSize(16)
                    .height(30)
                    .enabled(!item?.isConsume)
                    .onClick(() => {
                      this.buy(item.id, item.type, item?.isConsume)
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
}

interface ProductInfo extends iap.Product {
  isConsume?: boolean;
}