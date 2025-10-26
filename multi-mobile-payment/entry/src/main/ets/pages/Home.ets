/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { generateBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { Constants } from '../common/Constants';
import { FunctionCard } from '../view/FunctionCard';
import { QuickFunctionCardSquare } from '../view/QuickFunctionCardSquare';
import { QuickFunctionCardCircle } from '../view/QuickFunctionCardCircle';
import { PayHubViewModel, QuickFunctionItem } from '../viewmodel/PayHubViewModel';
import { FortunePicksViewModel } from '../viewmodel/FortunePicksViewModel';
import { ServiceCardViewModel } from '../viewmodel/ServiceCardViewModel';
import { ReceiveMoneyCardViewModel, ReceiveMoneyServiceCardItem } from '../viewmodel/ReceiveMoneyCardViewModel';
import { QuickFunctionsViewModel } from '../viewmodel/QuickFunctionsViewModel';
import { ScanQRCodeDialog } from '../view/ScanQRCodeDialog';
import { Logger } from '../common/Logger';
import { JSON } from '@kit.ArkTS';

export const getValueByBreakpoint =
  (value: Record<string, Resource | number | string>, bp: string): Resource | number | string => value[bp];

@Component
export struct Home {
  // [Start current_breakpoint_change]
  @StorageProp('currentBreakpoint') @Watch('onBreakpointChange') curBp: string = 'sm';
  @State @Watch('onDialogStatusChange') isDialogOpen: boolean = false;
  // [StartExclude current_breakpoint_change]
  @State @Watch('onScanDialogStatusChange') isScanDialogOpen: boolean = false;
  @State quickFunctions: Array<QuickFunctionItem> = new QuickFunctionsViewModel().getQuickFunctions();
  @State functions: Array<QuickFunctionItem> = new PayHubViewModel().getFunctionsByBreakpoints(this.curBp);
  @State sampleImages: Array<Resource> = new ServiceCardViewModel().getImagesByBreakpoints(this.curBp);
  @State fortunePicks: Array<Resource> = new FortunePicksViewModel().getFortunePicks();
  @Consume('pathInfos') pathInfos: NavPathStack;
  private city: string = Constants.CITY_NAME;
  private scroller: Scroller = new Scroller();
  private scanQRCode = () => {
    if (this.curBp === 'sm') {
      this.pathInfos.pushPath({ name: 'ScanQRCodePage' });
    } else {
      this.isScanDialogOpen = true;
    }
  };
  // [Start receive_payment]
  private receivePayment = () => {
    if (this.curBp === 'sm') {
      this.pathInfos.pushPath({ name: 'ReceivePaymentPage' });
    } else if (!this.isDialogOpen) {
      this.isDialogOpen = true;
    }
  };
  // [End receive_payment]
  private onCancel = () => {
    if (this.isDialogOpen) {
      this.isDialogOpen = false;
    }
  };
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ReceivePayment({ isDialogOpen: this.isDialogOpen }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    customStyle: true,
    cornerRadius: Constants.CORNER_RADIUS,
    isModal: true,
    cancel: this.onCancel
  });
  private scanDialogController: CustomDialogController = new CustomDialogController({
    builder: ScanQRCodeDialog({ receivePayment: this.receivePayment, isScanDialogOpen: this.isScanDialogOpen }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    customStyle: true,
    cornerRadius: Constants.CORNER_RADIUS,
    isModal: true,
    cancel: () => {
      if (this.isScanDialogOpen) {
        this.isScanDialogOpen = false;
      }
    }
  });
  // [EndExclude current_breakpoint_change]
  onDialogStatusChange() {
    if (this.isDialogOpen) {
      this.dialogController.open();
    } else {
      this.dialogController.close();
    }
  }

  onScanDialogStatusChange() {
    if (this.isScanDialogOpen) {
      this.scanDialogController.open();
    } else {
      this.scanDialogController.close();
    }
  }

  onBreakpointChange() {
    const allPath = this.pathInfos.getAllPathName();
    const currentName: string = allPath[this.pathInfos.size() - 1];

    if (this.curBp !== 'sm' && currentName === 'ReceivePaymentPage') {
      this.pathInfos.clear();
      setTimeout(() => {
        this.isDialogOpen = true;
      }, 1000);
    }

    if (this.isDialogOpen && this.curBp === 'sm') {
      this.isDialogOpen = false;
      this.pathInfos.pushPath({ name: 'ReceivePaymentPage' });
    }
    // [StartExclude current_breakpoint_change]

    if (this.isScanDialogOpen && this.curBp === Constants.BREAKPOINTS[0]) {
      this.isScanDialogOpen = false;
      this.pathInfos.pushPath({ name: 'ScanQRCodePage' });
    }

    if (this.curBp !== Constants.BREAKPOINTS[0] && currentName === 'ScanQRCodePage') {
      this.pathInfos.pop();
      setTimeout(() => {
        this.isScanDialogOpen = true;
      }, 1000);
    }
    // [EndExclude current_breakpoint_change]
  }
  // [End current_breakpoint_change]

  aboutToAppear(): void {
    this.quickFunctions[0].setClickCallback(this.scanQRCode);
    this.quickFunctions[1].setClickCallback(this.receivePayment);
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_public_gps'))
              .width($r('app.float.icon_size'))
              .height($r('app.float.icon_size'))
              .fillColor(Color.White)
              .margin({ right: Constants.CONTENT_SPACE[0] })
            Text($r('app.string.city_name'))
              .fontColor(Color.White)
              .fontSize($r('app.float.bigger_font_size'))
              .fontFamily($r('app.string.normal_font_family'))
              .fontWeight(Constants.FONT_WEIGHT[0])
          }

          Blank()

          Row() {
            Search({ placeholder: $r('app.string.search_box_placeholder') })
              .enableKeyboardOnFocus(false)
              .placeholderColor(Color.White)
              .placeholderFont({
                family: $r('app.string.normal_font_family'),
                size: $r('app.float.middle_font_size'),
                weight: Constants.FONT_WEIGHT[0]
              })
              .borderColor($r('app.color.five_percent_white'))
              .searchIcon({ color: Color.White })
              .fontColor(Color.White)
              .width(this.curBp === Constants.BREAKPOINTS[0] ?
              $r('app.float.search_box_width_in_small_device') :
              $r('app.float.search_box_width_in_big_device'))
              .margin({
                right: this.curBp === Constants.BREAKPOINTS[0] ?
                Constants.CONTENT_SPACE[5] :
                Constants.CONTENT_SPACE[7],
              })

            Image($r('app.media.ic_public_more'))
              .width($r('app.float.icon_size'))
              .height($r('app.float.icon_size'))

          }

        }
        .width('100%')
        .height($r('app.float.header_height'))
        .margin({ bottom: Constants.CONTENT_SPACE[6] })
        .padding({
          left: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_25'),
            'lg': $r('app.float.space_32')
          }, this.curBp),
          right: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_25'),
            'lg': $r('app.float.space_32')
          }, this.curBp)
        })
        // [Start home_grid_row]
        GridRow({
          columns: 12,
          gutter: {
            x: {
              sm: '30vp',
              md: '41vp',
              lg: '58vp'
            }
          }
        }) {
          ForEach(this.quickFunctions, (item: QuickFunctionItem) => {
            GridCol({ span: 3 }) {
              if (this.curBp === 'sm') {
                QuickFunctionCardCircle({ quickFunctionItem: item })
              } else {
                QuickFunctionCardSquare({ quickFunctionItem: item })
              }
            }
            // [StartExclude home_grid_row]
            .onClick(() => {
              if (item.getClickCallback()) {
                item.getClickCallback()();
              }
            })
            // [EndExclude home_grid_row]
          }, (item: QuickFunctionItem, index: number) => JSON.stringify(item.getText()) + index)
        }
        // [End home_grid_row]
        .width('100%')
        .height(getValueByBreakpoint({
          'sm': $r('app.float.quick_function_card_height_sm'),
          'md': $r('app.float.quick_function_card_height_md'),
          'lg': $r('app.float.quick_function_card_height_lg')
        }, this.curBp))
        .height(getValueByBreakpoint({
          'sm': $r('app.float.quick_function_card_height_sm'),
          'md': $r('app.float.quick_function_card_height_md'),
          'lg': $r('app.float.quick_function_card_height_lg')
        }, this.curBp))
        .margin({ bottom: $r('app.float.quick_function_margin_bottom') })
        .padding({
          left: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_45'),
            'lg': $r('app.float.space_62')
          }, this.curBp),
          right: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_45'),
            'lg': $r('app.float.space_62')
          }, this.curBp)
        })

        Column() {
          // [Start home_grid_row_list]
          GridRow({
            columns: {
              sm: 4,
              md: 6,
              lg: 8
            },
            gutter: {
              x: {
                sm: '45vp',
                md: '50vp',
                lg: '55vp'
              },
              y: {
                sm: '16vp',
                md: '24vp',
                lg: '28vp'
              }
            }
          }) {
            ForEach(this.functions, (item: QuickFunctionItem) => {
              GridCol() {
                FunctionCard({ data: item })
              }
            }, (item: QuickFunctionItem, index: number) => index + JSON.stringify(item))
          }
          // [StartExclude home_grid_row_list]
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius('16vp')
          // [EndExclude home_grid_row_list]
          .onBreakpointChange((breakpoints: string) => {
            this.functions = new PayHubViewModel().getFunctionsByBreakpoints(breakpoints);
            // close dialog.
            if (this.isDialogOpen) {
              this.isDialogOpen = false;
            }
          })
          // [End home_grid_row_list]
          .backgroundImageSize(ImageSize.Cover)
          .padding({
            top: getValueByBreakpoint({
              'sm': '16vp',
              'md': '16vp',
              'lg': '24vp'
            }, this.curBp),
            bottom: getValueByBreakpoint({
              'sm': '16vp',
              'md': '16vp',
              'lg': '24vp'
            }, this.curBp),
            left: getValueByBreakpoint({
              'sm': 0,
              'md': 0,
              'lg': '32vp'
            }, this.curBp),
            right: getValueByBreakpoint({
              'sm': 0,
              'md': 0,
              'lg': '32vp'
            }, this.curBp)
          })
          // [Start home_grid_row_image]
          GridRow({
            columns: 12,
            gutter: { x: { sm: '15vp' } }
          }) {
            ForEach(this.sampleImages, (item: Resource) => {
              GridCol({
                span: {
                  sm: 12,
                  md: 6,
                  lg: 3
                }
              }) {
                Image(item)
                  .width('100%')
              }
            }, (item: Resource, index: number) => index + JSON.stringify(item))
          }
          // [StartExclude home_grid_row_image]
          .width('100%')
          .margin({
            top: getValueByBreakpoint({
              'sm': $r('app.float.space_16'),
              'md': $r('app.float.space_12'),
              'lg': $r('app.float.space_16')
            }, this.curBp)
          })
          // [EndExclude home_grid_row_image]
          .onBreakpointChange((breakpoints: string) => {
            this.sampleImages = new ServiceCardViewModel().getImagesByBreakpoints(breakpoints);
          })
          // [End home_grid_row_image]
          Text($r('app.string.fortune_pick'))
            .width('100%')
            .height($r('app.float.fortune_pick_height'))
            .fontFamily($r('app.string.medium_font_family'))
            .fontSize($r('app.float.middle_font_size'))
            .fontColor($r('app.color.fortune_pick_font_color'))
            .textAlign(TextAlign.Start)
            .lineHeight($r('app.float.fortune_pick_height'))
            .fontWeight(Constants.FONT_WEIGHT[1])
            .margin({ top: $r('app.float.fortune_pick_margin'), bottom: $r('app.float.fortune_pick_margin') })

          // [Start home_grid_row_image_no_change]
          GridRow({
            columns: 12,
            gutter: { x: { sm: '15vp' }, y: { sm: '15vp' } }
          }) {
            ForEach(this.fortunePicks, (item: Resource) => {
              GridCol({
                span: {
                  sm: 12,
                  md: 6,
                  lg: 3
                }
              }) {
                Image(item)
                  .width('100%')
              }
            }, (item: Resource, index: number) => index + JSON.stringify(item))

          }
          // [End home_grid_row_image_no_change]
          .width('100%')
        }
        .width('100%')
        .borderRadius($r('app.float.bigger_border_radius'))
        .backgroundColor(this.curBp === Constants.BREAKPOINTS[2] ? Color.Transparent : Color.White)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .padding({
          left: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_25'),
            'lg': $r('app.float.space_32')
          }, this.curBp),
          right: getValueByBreakpoint({
            'sm': $r('app.float.space_16'),
            'md': $r('app.float.space_25'),
            'lg': $r('app.float.space_32')
          }, this.curBp)
        })
      }
      .width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.On)
    .scrollBarColor(Color.Gray)
    .scrollBarWidth(Constants.SCROLL_BAR_WIDTH)
    .edgeEffect(EdgeEffect.Fade)
  }
}

@CustomDialog
struct ReceivePayment {
  controller?: CustomDialogController;
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State receiveMoneyServiceCard: ReceiveMoneyServiceCardItem[] =
    new ReceiveMoneyCardViewModel().getReceiveMoneyServiceCards();
  @Link isDialogOpen: boolean;
  // [Start home_timer]
  private timer: number | null = null;
  private getQRCode = () => (new Date()).valueOf().toString();

  aboutToAppear(): void {
    this.getAndUpdateQRCode();
    this.timer = setInterval(() => {
      this.getAndUpdateQRCode();
    }, 60 * 1000);
  }

  private getAndUpdateQRCode(): void {
    // [StartExclude home_timer]
    // [Start get_and_update_QRCode]
    let content: string = this.getQRCode();
    const options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: Constants.QRCODE_SIZE,
      width: Constants.QRCODE_SIZE
    };
    generateBarcode.createBarcode(content, options, (error: BusinessError, pixelMap: image.PixelMap) => {
      if (error) {
        Logger.error(`Callback error: ${JSON.stringify(error)}`);
        return;
      }
      this.pixelMap = pixelMap;
    });
    // [End get_and_update_QRCode]
    // [EndExclude home_timer]
  }

  aboutToDisappear(): void {
    this.pixelMap = undefined;
    this.timer = null;
  }
  // [End home_timer]

  build() {
    Column() {
      Row() {
        Text($r('app.string.personal_receive_money'))
          .fontFamily($r('app.string.bold_font_family'))
          .fontSize($r('app.float.biggest_font_size'))
          .fontColor(Color.Black)
          .fontWeight(Constants.FONT_WEIGHT_700)

        Image($r('app.media.ic_close'))
          .width($r('app.float.icon_close_size'))
          .height($r('app.float.icon_close_size'))
          .onClick(() => {
            this.isDialogOpen = false;
          })
      }
      .width('100%')
      .height($r('app.float.title_line_height'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Text($r('app.string.slogan'))
        .fontFamily($r('app.string.normal_font_family'))
        .fontSize($r('app.float.smaller_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontWeight(Constants.FONT_WEIGHT[0])

      Text($r('app.string.user_name'))
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize($r('app.float.middle_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontWeight(Constants.FONT_WEIGHT[1])

      Stack({ alignContent: Alignment.Center }) {
        Row() {
          Image(this.pixelMap)
            .width('100%')
            .height(Constants.FULL_HEIGHT)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Image($r('app.media.avatar'))
          .width($r('app.float.avatar_size'))
          .height($r('app.float.avatar_size'))

      }
      .width($r('app.float.receive_money_container_size'))
      .height($r('app.float.receive_money_container_size'))
      .margin({
        top: $r('app.float.receive_money_container_margin_top'),
        bottom: $r('app.float.receive_money_container_margin_bottom')
      })

      Row() {
        Text($r('app.string.set_amount'))
          .fontFamily($r('app.string.normal_font_family'))
          .fontSize($r('app.float.smaller_font_size'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
          .fontWeight(Constants.FONT_WEIGHT[1])
          .width($r('app.float.receive_money_card_bottom_text_width'))
          .height($r('app.float.set_amount_height'))
          .textAlign(TextAlign.Center)
        Divider()
          .vertical(true)
          .color($r('app.color.divider_color'))
          .height($r('app.float.divider_height'))
        Text($r('app.string.save_image'))
          .fontFamily($r('app.string.normal_font_family'))
          .fontSize($r('app.float.smaller_font_size'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
          .fontWeight(Constants.FONT_WEIGHT[1])
          .width($r('app.float.receive_money_card_bottom_text_width'))
          .height($r('app.float.save_image_height'))
          .textAlign(TextAlign.Center)
      }

      Column() {
        ForEach(this.receiveMoneyServiceCard, (item: ReceiveMoneyServiceCardItem) => {
          Row() {
            Image(item.getImage())
              .width($r('app.float.receive_money_service_card_image_width'))
              .height($r('app.float.receive_money_service_card_image_height'))
              .margin({ right: Constants.CONTENT_SPACE[6] })
              .objectFit(ImageFit.Contain)

            Row() {
              Text(item.getText())
                .fontFamily($r('app.string.medium_font_family'))
                .fontSize($r('app.float.middle_font_size'))
                .fontColor(Color.Black)
                .textAlign(TextAlign.Start)
                .lineHeight($r('app.float.receive_money_service_card_text_line_height'))
                .fontWeight(Constants.FONT_WEIGHT[1])

              Row() {
                if (item.getBrief()) {
                  Text(item.getBrief())
                    .opacity(Constants.OPACITY)
                    .fontFamily($r('app.string.normal_font_family'))
                    .fontSize($r('app.float.smaller_font_size'))
                    .fontColor(Color.Black)
                    .textAlign(TextAlign.End)
                    .lineHeight($r('app.float.brief_line_height'))
                    .fontWeight(Constants.FONT_WEIGHT[0])
                    .margin({ right: $r('app.float.brief_margin_right') })
                }
                Image($r('app.media.right_arrow'))
                  .width($r('app.float.right_arrow_width'))
                  .height($r('app.float.right_arrow_height'))
              }
            }
            .layoutWeight(Constants.LAYOUT_WEIGHT)
            .height(Constants.FULL_HEIGHT)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .border({
              width: { bottom: $r('app.float.divider_border_width') },
              color: { bottom: $r('app.color.border_divider_color') },
            })
          }
          .width('100%')
          .height($r('app.float.receive_money_bottom_card_height'))
        })
      }
      .width('100%')
      .margin({ top: $r('app.float.receive_money_bottom_card_margin_top') })
    }
    .width($r('app.float.receive_money_card_width'))
    .height($r('app.float.receive_money_card_height'))
    .padding({
      top: $r('app.float.dialog_padding_top'),
      left: $r('app.float.dialog_padding_normal'),
      right: $r('app.float.dialog_padding_normal'),
      bottom: $r('app.float.dialog_padding_normal')
    })
    .backgroundColor(Color.White)
    .opacity(Constants.PERCENT_90_OPACITY)
    .backdropBlur(Constants.BACK_DROP_BLUR_60)
    .borderRadius($r('app.float.br24'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }
}