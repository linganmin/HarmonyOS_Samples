/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMAnimator, HMAnimatorHandle, HMRouter, HMRouterMgr, IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption } from '@hadss/hmrouter';
import { CommonConstants } from '../common/constants/CommonConstants';
import { DetailConstants } from '../common/constants/DetailConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { ProductMsg } from '../product/elements/ProductUtilView';
import { PayCardViewModel, SelectItem, SelectProjectItem } from '../viewmodel/PayCardViewModel';
import { PageConstant } from '../../constant/PageConstant';

interface PriceParamType {
  product: ProductMsg;
  pageUrl: string;
}

@Observed
export class ColorOption {
  color: ResourceStr = 'rgba(0,0,0,0)';
}

@HMAnimator({ animatorName: 'PayCardDialog' })
export class DialogAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      translateOption.y = '100%';
      colorOption.color = 'rgba(0, 0, 0, 0)';
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      translateOption.y = '0';
      colorOption.color = 'rgba(0, 0, 0, 0.7)';
    }).passiveStart(() => {
    }).passiveFinish(() => {
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      translateOption.y = '0';
      colorOption.color = 'rgba(0, 0, 0, 0.7)';
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      translateOption.y = '100%';
      colorOption.color = 'rgba(0, 0, 0, 0)';
    }).passiveStart(() => {
    }).passiveFinish(() => {
    });
  }
}

@HMRouter({ pageUrl: PageConstant.PAY_CARD, dialog: true,animator:'PayCardDialog' })
@Preview
@Component
export struct PayCard {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State color: number | undefined = this.colorNumber((HMRouterMgr.getCurrentParam() as PriceParamType).product.color);
  @State memory: number | undefined =
    this.memoryNumber((HMRouterMgr.getCurrentParam() as PriceParamType).product.memory);
  @State payState: string = DetailConstants.PAY_INFO[3];
  @State totalPrice: number = 0;
  pageUrl: string = '';
  private payCardSelectList: SelectProjectItem[] = new PayCardViewModel().getPayCardSelectList();

  aboutToAppear(): void {
    let param = HMRouterMgr.getCurrentParam() as PriceParamType;
    this.totalPrice = Number(param.product.price);
    this.pageUrl = param.pageUrl;
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Image($r('app.media.pay_main_shop'))
              .height(ResourceUtil.getCommonImgSize()[4])
              .width(ResourceUtil.getCommonImgSize()[4])
              .margin({ right: 8 });
            Text('￥')
              .fontColor($r('app.color.pay_card_price_color'))
              .fontSize(24);
            Text(this.totalPrice.toString())
              .fontColor($r('app.color.pay_card_price_color'))
              .fontSize(24);
            Blank();
            Image($r('app.media.icon_close_1'))
              .width(ResourceUtil.getCommonImgSize()[0])
              .height(ResourceUtil.getCommonImgSize()[0])
              .alignSelf(ItemAlign.Start)
              .margin({ top: $r('app.float.pay_card_icon_margin'), right: $r('app.float.pay_card_right_margin') })
              .onClick(() => {
                HMRouterMgr.popAsync({
                  navigationId: this.queryNavigationInfo()?.navigationId,
                  param: new ProductMsg(DetailConstants.COLOR_SELECT_NAME_LIST[this.color!],
                    DetailConstants.CAPACITY_SELECT_NAME_LIST[this.memory!],
                    this.totalPrice!.toString())
                });
              });
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.pay_card_top_margin'), top: 6 });

          Row() {
            Image($r('app.media.icon_position'))
              .height(ResourceUtil.getCommonImgSize()[5])
              .width(ResourceUtil.getCommonImgSize()[5])
              .margin({ right: $r('app.float.pay_position_margin') });
            Column() {
              Text(DetailConstants.PAY_INFO[0])
                .fontSize($r('app.float.pay_address_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500)
                .width(CommonConstants.FULL_PERCENT)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ bottom: $r('app.float.pay_address_margin') });
              Text(DetailConstants.PAY_INFO[1])
                .fontSize($r('app.float.pay_contact_font'))
                .fontColor($r('app.color.pay_contact_color'))
                .width(CommonConstants.FULL_PERCENT)
                .maxLines(1);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .margin({ bottom: $r('app.float.pay_info_margin') })
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor($r('app.color.pay_card_background_color_1'))
          .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
          .padding({
            top: $r('app.float.pay_info_padding_top_bottom'),
            bottom: $r('app.float.pay_info_padding_top_bottom'),
            left: $r('app.float.pay_info_padding_left_right'),
            right: $r('app.float.pay_info_padding_left_right')
          });

          Column() {
            ForEach(this.payCardSelectList, (item: SelectProjectItem, index: number) => {
              Column() {
                Text(item.getName())
                  .fontSize($r('app.float.pay_config_title_font'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: $r('app.float.pay_config_title_margin') })
                  .lineHeight($r('app.float.pay_config_title_line'))
                  .fontWeight(CommonConstants.FONT_WEIGHT_500);
                Flex({
                  wrap: FlexWrap.Wrap,
                  justifyContent: FlexAlign.Start
                }) {
                  ForEach(item.getSelectItemList(), (selectItem: SelectItem, selectIndex: number) => {
                    Row() {
                      Image(selectItem.getImage())
                        .height(ResourceUtil.getCommonImgSize()[1])
                        .width(ResourceUtil.getCommonImgSize()[1])
                        .visibility(selectItem.getImage() === null ? Visibility.None : Visibility.Visible);
                      Text(selectItem.getName())
                        .fontColor(this.getShowColor(item.getName(), selectIndex,
                          $r('app.color.pay_card_item_color_selected'), $r('app.color.pay_card_item_color_1')))
                        .fontSize($r('app.float.pay_config_name_font'))
                        .textAlign(TextAlign.Center)
                        .margin({
                          left: $r('app.float.pay_config_name_margin'),
                          right: $r('app.float.pay_config_name_margin')
                        });
                    }
                    .onClick(() => {
                      PayMgr.getInstance().setProductChoose(item.getName(), selectIndex);
                      if (item.getName() === DetailConstants.SELECT_NAME_LIST[0]) {
                        this.color = PayMgr.getInstance().getProductChoose(DetailConstants.SELECT_NAME_LIST[0]);
                      } else if (item.getName() === DetailConstants.SELECT_NAME_LIST[1]) {
                        this.totalPrice = Number(DetailConstants.CUSTOMER_SERVICE_CONTENTS[selectIndex + 1]);
                        this.memory = PayMgr.getInstance().getProductChoose(DetailConstants.SELECT_NAME_LIST[1]);
                      }
                    })
                    .backgroundColor(this.getShowColor(item.getName(), selectIndex,
                      $r('app.color.pay_card_item_background_color_selected'),
                      $r('app.color.pay_card_item_background_color')))
                    .border({
                      color: this.getShowColor(item.getName(), selectIndex,
                        $r('app.color.pay_card_item_color_selected'), $r('app.color.pay_card_item_color_2')),
                      width: index === 0 ? $r('app.float.pay_config_border_width') : 0,
                      radius: ResourceUtil.getCommonBorderRadius()[3]
                    })
                    .height($r('app.float.pay_config_height'))
                    .margin({
                      right: $r('app.float.pay_config_margin'),
                      bottom: $r('app.float.pay_config_margin')
                    });
                  }, (selectItem: SelectItem, selectIndex: number) => JSON.stringify(selectItem) + selectIndex);
                }
                .width(CommonConstants.FULL_PERCENT);
              }
              .margin({ top: $r('app.float.pay_config_col_margin_top') })
              .width(CommonConstants.FULL_PERCENT);
            }, (item: SelectProjectItem, index: number) => JSON.stringify(item) + index);
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('app.float.pay_config_col_margin_bottom') })
          .backgroundColor($r('app.color.pay_card_background_color_1'))
          .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
          .padding({
            left: $r('app.float.pay_config_col_padding'),
            right: $r('app.float.pay_config_col_padding')
          });

          Row() {
            Image($r('app.media.icon_pay'))
              .height(ResourceUtil.getCommonImgSize()[5])
              .width(ResourceUtil.getCommonImgSize()[5])
              .margin({ right: $r('app.float.pay_wallet_icon_margin') });
            Text(DetailConstants.PAY_INFO[2])
              .fontSize($r('app.float.pay_wallet_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500);
            Blank();
            Checkbox()
              .select(true)
              .selectedColor($r('app.color.util_button_2'))
              .shape(CheckBoxShape.CIRCLE)
              .width($r('app.float.checkbox_width'));
          }
          .padding({
            top: $r('app.float.wallet_row_padding_1'),
            left: $r('app.float.wallet_row_padding_2'),
            bottom: $r('app.float.wallet_row_padding_1'),
            right: $r('app.float.wallet_row_padding_2')
          })
          .margin({ bottom: $r('app.float.wallet_row_margin') })
          .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
          .backgroundColor($r('app.color.pay_card_background_color_1'))
          .width(CommonConstants.FULL_PERCENT);
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({ left: 24, right: 24 });
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Top)
      .width(CommonConstants.FULL_PERCENT);

      Button(this.payState)
        .onClick(() => {
          if (this.payState === DetailConstants.PAY_INFO[3]) {
            HMRouterMgr.to('PayDialogContent')
              .withParam({totalPrice: this.totalPrice, pageUrl: this.pageUrl})
              .onResult((info)=>{
                if (info.result === DetailConstants.PAY_INFO[4]) {
                  this.payState = info.result.toString();
                }
              })
              .pushAsync()
          } else if (this.payState === DetailConstants.PAY_INFO[4]) {
            HMRouterMgr.popAsync({
              navigationId: this.queryNavigationInfo()?.navigationId,
              param: new ProductMsg(DetailConstants.COLOR_SELECT_NAME_LIST[this.color!],
                DetailConstants.CAPACITY_SELECT_NAME_LIST[this.memory!],
                this.totalPrice!.toString())
            });
          }
        })
        .width('90%')
        .backgroundColor($r('app.color.util_button_2'))
        .height($r('app.float.pay_button_height'))
        .margin(12);
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? { topLeft: 40, topRight: 40 } : 40)
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '100%' : '72%')
    .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '70%' : '72%')
    .border({
      radius: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? { topLeft: 20, topRight: 20 } : 20
    })
    .backgroundColor($r('app.color.pay_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  getShowColor(itemName: string, selectIndex: number, onFocusColor: Resource, outFocusColor: Resource): Resource {
    if ((itemName === DetailConstants.SELECT_NAME_LIST[0] && selectIndex === this.color) ||
      (itemName === DetailConstants.SELECT_NAME_LIST[1] && selectIndex === this.memory) ||
      itemName === DetailConstants.SELECT_NAME_LIST[2]) {
      return onFocusColor;
    }
    return outFocusColor;
  }

  colorNumber(color: string): number {
    return DetailConstants.COLOR_SELECT_NAME_LIST.indexOf(color);
  }

  memoryNumber(memory: string): number {
    return DetailConstants.CAPACITY_SELECT_NAME_LIST.indexOf(memory);
  }
}


export class PayMgr {
  // maintain displayed parameters(color, capacity)
  private static productChooseMap: Map<string, number> =
    new Map([[DetailConstants.SELECT_NAME_LIST[0], 0], [DetailConstants.SELECT_NAME_LIST[1], 0]]);
  private static instance: PayMgr = new PayMgr();

  static getInstance(): PayMgr {
    return PayMgr.instance;
  }

  setProductChoose(options: string, kinds: number) {
    PayMgr.productChooseMap.set(options, kinds);
  }

  getProductChoose(options: string): number | undefined {
    return PayMgr.productChooseMap.get(options);
  }

  has(options: string): boolean {
    return PayMgr.productChooseMap.has(options);
  }
}
