/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { ComponentContent, LoadingDialog } from '@kit.ArkUI';
import { PromptActionManager } from '../common/utils/PromptActionManager';
import { ConsigneeInfo, Params } from '../viewmodel/DataModel';
import { AddressParse } from '../common/utils/AddressParse';
import CommonConstants from '../common/constants/CommonConstants';
import { ConsigneeInfoItem } from '../views/ConsigneeInfoItem';
import { dialogBuilder } from '../views/DialogBuilder';


@Entry
@Component
struct Index {
  private uiContext: UIContext = this.getUIContext();
  @State consigneeInfos: ConsigneeInfo[] = [];
  @State saveAvailable: boolean = false;
  @State ocrResult: string = '';
  private resultController: TextAreaController = new TextAreaController();
  private loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: $r('app.string.loading_content')
    }),
    autoCancel: false
  });
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.uiContext, wrapBuilder(dialogBuilder),
      new Params(this.uiContext, this.resultController, this.loadingController));

  aboutToAppear(): void {
    this.consigneeInfos = [
      new ConsigneeInfo(CommonConstants.NAME_LABEL, CommonConstants.NAME_PLACEHOLDER, ''),
      new ConsigneeInfo(CommonConstants.PHONE_LABEL, CommonConstants.PHONE_PLACEHOLDER, ''),
      new ConsigneeInfo(CommonConstants.ADDRESS_LABEL, CommonConstants.ADDRESS_LABEL, ''),
    ];
    PromptActionManager.setCtx(this.uiContext);
    PromptActionManager.setContentNode(this.contentNode);
    PromptActionManager.setOptions({
      alignment: DialogAlignment.Center,
    });
  }

  build() {
    RelativeContainer() {
      Column() {
        Text($r('app.string.page_title'))
          .id('title')
          .width('100%')
          .font({ size: 26, weight: 700 })
          .fontColor($r('app.color.title_color'))
          .opacity(0.9)
          .height(64)
          .align(Alignment.TopStart)
        Text($r('app.string.page_subtitle'))
          .width('100%')
          .padding({ left: 12, right: 12 })
          .font({ size: 14, weight: 400 })
          .fontColor($r('app.color.title_color'))
          .opacity(0.6)
          .lineHeight(19)
          .margin({ bottom: 8 })
        Column() {
          TextArea({
            placeholder: $r('app.string.input_placeholder'),
            controller: this.resultController,
            text: $$this.ocrResult
          })
            .height(73)
            .margin({ bottom: 12 })
            .backgroundColor($r('app.color.light_background'))
          Row({ space: 12 }) {
            Button() {
              Row({ space: 8 }) {
                Text() {
                  SymbolSpan($r('sys.symbol.camera'))
                    .fontSize(26)
                    .fontColor([$r('app.color.btn_font_color')])
                }

                Text($r('app.string.open_dialog_btn'))
                  .fontSize(16)
                  .fontColor($r('app.color.btn_font_color'))
              }
            }
            .height(40)
            .layoutWeight(1)
            .backgroundColor($r('app.color.app_background'))
            .onClick(() => {
              PromptActionManager.openCustomDialog();
            })

            Button($r('app.string.parse_btn'))
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                if (!this.ocrResult || !this.ocrResult.trim()) {
                  this.uiContext.getPromptAction().showToast({ message: $r('app.string.empty_toast') });
                  return;
                }
                this.consigneeInfos = AddressParse.extractInfo(this.ocrResult, this.consigneeInfos);
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
          })
        }
        .backgroundColor($r('app.color.light_background'))
        .borderRadius(16)
        .padding({
          top: 16,
          bottom: 16
        })

        Column() {
          List() {
            ForEach(this.consigneeInfos, (item: ConsigneeInfo) => {
              ListItem() {
                ConsigneeInfoItem(
                  item, () => {
                  if (this.consigneeInfos[0].value && this.consigneeInfos[1].value && this.consigneeInfos[2].value) {
                    this.saveAvailable = true;
                  } else {
                    this.saveAvailable = false;
                  }
                })
              }
            }, (item: ConsigneeInfo, index: number) => JSON.stringify(item) + index)
          }
          .width('100%')
          .height(LayoutPolicy.matchParent)
          .scrollBar(BarState.Off)
          .divider({ strokeWidth: 0.5, color: $r('app.color.divider_color') })
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4
          })
          .borderRadius(16)
          .backgroundColor($r('app.color.light_background'))
        }
        .borderRadius(16)
        .margin({ top: 12 })
        .constraintSize({ minHeight: 150, maxHeight: '50%' })
        .backgroundColor($r('app.color.light_background'))
      }

      if (this.saveAvailable) {
        Button($r('app.string.save_btn'), { stateEffect: true })
          .width('100%')
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .onClick(() => {
            if (this.consigneeInfos[0].value && this.consigneeInfos[1].value && this.consigneeInfos[2].value) {
              this.uiContext.getPromptAction().showToast({ message: $r('app.string.save_success_toast') });
              this.clearConsigneeInfos();
            }
          })
      } else {
        Button($r('app.string.save_btn'), { stateEffect: false })
          .width('100%')
          .opacity(0.4)
          .backgroundColor($r('app.color.save_btn_disabled'))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
      }
    }
    .height('100%')
    .width('100%')
    .alignRules({
      left: { anchor: '__container__', align: HorizontalAlign.Start }
    })
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24
    })
    .backgroundColor($r('app.color.app_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  clearConsigneeInfos() {
    for (const item of this.consigneeInfos) {
      item.value = '';
    }
    this.ocrResult = '';
  }
}



