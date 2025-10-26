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
/**
 * 最佳实践：基于StateStore的全局状态管理开发实践
 */
import {
  InfCustomDialog,
  DialogHub,
  TopDialogPriority,
  DialogStatus,
  InfDialog,
  InfToast,
  AnimationType
} from "@hadss/dialoghub"
import { SimpleCustomBuilder, SimpleCustomParams } from "../component/SimpleCustomBuilder"
import { TextToastBuilder, TextToastParams } from "../component/TextToastBuilder"
import { TimeToastBuilder, TimeToastParams } from "../component/TimeToastBuilder"
import CommonConstant from "../utils/CommonConstant"
import { ItemHead } from "../utils/ItemHead"
import { ItemButtonModifier, ItemGroupModifier, ItemListModifier, ItemTextModifier } from "../utils/SampleModifier"

@Builder
export function MultiDialogBuilder(name: string, param: Object) {
  MultiDialogExample();
}

@Component
export struct MultiDialogExample {
  pageInfos: NavPathStack = new NavPathStack();
  tipsToast?: InfToast;
  dialogA?: InfCustomDialog;
  dialogB?: InfCustomDialog;
  dialogC?: InfCustomDialog;
  dialogD?: InfCustomDialog;
  dialogE?: InfCustomDialog;
  dialogF?: InfCustomDialog;
  dialogG?: InfCustomDialog;
  dialogH?: InfCustomDialog;

  aboutToAppear(): void {
    this.tipsToast = DialogHub.getToast()
      .setContent(wrapBuilder(TextToastBuilder),
        new TextToastParams(CommonConstant.DIALOG_B_SUPPRESSION))
      .setConfig({
        dialogPosition: {
          alignment: DialogAlignment.Bottom,
          offset: { dx: 0, dy: $r('app.float.text_toast_offset') }
        }
      })
      .setStyle({
        backgroundColor: Color.White,
        radius: $r('app.float.text_toast_radius'), shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
      })
      .setDuration(CommonConstant.DURATION_3000)
      .build();
    this.dialogA = DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setStyle({
      radius: $r('app.float.custom_template_radius'), shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
    })?.setContent(wrapBuilder(SimpleCustomBuilder),
      new SimpleCustomParams(CommonConstant.DIALOG_A, CommonConstant.DIALOG_A_CONTENT, () => {
        this.dialogA?.dismiss();
      }))?.build();
    this.dialogB = DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setStyle({
      radius: $r('app.float.custom_template_radius'), shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
    })?.setContent(wrapBuilder(SimpleCustomBuilder),
      new SimpleCustomParams(CommonConstant.DIALOG_B, CommonConstant.DIALOG_B_CONTENT, () => {
        this.dialogB?.dismiss();
      }))?.build();
    this.dialogC = DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setStyle({
      radius: $r('app.float.custom_template_radius'), shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
    })?.setContent(wrapBuilder(SimpleCustomBuilder),
      new SimpleCustomParams(CommonConstant.DIALOG_C, CommonConstant.DIALOG_C_CONTENT, () => {
        this.dialogC?.dismiss();
      }))?.build();
  }

  private createMessageBuilder(title: string, content: string): ESObject {
    let params: TimeToastParams = new TimeToastParams(title, content)
    return DialogHub.getCustomDialog()
      .setContent(wrapBuilder(TimeToastBuilder), params)
      .setStyle({
        radius: $r('app.float.time_toast_builder_radius'),
        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
      })
      .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
      .setConfig({
        dialogBehavior: { isModal: false, passThroughGesture: true },
        dialogPosition: {
          alignment: DialogAlignment.Top,
          offset: { dy: $r('app.float.time_toast_builder_offset'), dx: 0 }
        }
      });
  }

  build() {
    NavDestination() {
      Column() {

        List() {
          // New dialogs are suppressed by existing dialog
          ListItem() {
            ItemHead(CommonConstant.EXISTING_DIALOG_TITLE)
          }

          ListItemGroup() {
            // dialogA
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_A'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_A_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    this.dialogA?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // If dialog A exists, dialog B cannot be popped up
            ListItem() {
              Row() {
                Text($r('app.string.Suppression_tips'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_B_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start get_status]
                    if (this.dialogA?.getStatus() != DialogStatus.SHOW) {
                      this.dialogB?.show();
                    }
                    // [End get_status]
                    else {
                      this.tipsToast?.updateContent(new TextToastParams(CommonConstant.DIALOG_B_SUPPRESSION));
                      this.tipsToast?.show();
                    }
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Dialog C is available only when the current page does not have dialog
            ListItem() {
              Row() {
                Text(CommonConstant.DIALOG_C_SUPPRESSION_TIPS)
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_C_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start current_page]
                    if (DialogHub.getCurrentPageDialogs().length === 0) {
                      this.dialogC?.show();
                    }
                    // [End current_page]
                    else {
                      this.tipsToast?.updateContent(new TextToastParams(CommonConstant.DIALOG_C_SUPPRESSION));
                      this.tipsToast?.show();
                    }
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // Developers can control the dialog level to achieve mutual coverage of dialog
          ListItem() {
            ItemHead(CommonConstant.CONTROL_DIALOG_COVERAGE_EACH_OTHER)
          }

          ListItemGroup() {
            // Normal dialog D
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_D'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_D_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    this.dialogD = this.dialogD ??
                    this.createMessageBuilder(CommonConstant.DIALOG_D, CommonConstant.DIALOG_D_CONTENT).build();
                    this.dialogD?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Normal dialog E
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_E'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_E_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    this.dialogE = this.dialogE ??
                    this.createMessageBuilder(CommonConstant.DIALOG_E, CommonConstant.DIALOG_E_CONTENT).build();
                    this.dialogE?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // dialog F at level 10
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_F'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_F_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start create_message]
                    this.dialogF = this.dialogF ??
                    this.createMessageBuilder(CommonConstant.DIALOG_F, CommonConstant.DIALOG_F_CONTENT)
                      .setLayerIndex(CommonConstant.DIALOG_F_LAYER_INDEX)
                      .build();
                    // [End create_message]
                    this.dialogF?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Top dialog (Old_First)G
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_G'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_G_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start create_builder]
                    this.dialogG = this.dialogG ??
                    this.createMessageBuilder(CommonConstant.DIALOG_G, CommonConstant.DIALOG_G_CONTENT).setConfig({
                      dialogBehavior: {
                        layerPolicy: { alwaysTop: true, topDialogPriority: TopDialogPriority.OLD_FIRST }
                      }
                    }).build();
                    // [End create_builder]
                    this.dialogG?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Top dialog (New_First)H
            ListItem() {
              Row() {
                Text($r('app.string.Dialog_H'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.DIALOG_H_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start layer_policy]
                    this.dialogH = this.dialogH ??
                    this.createMessageBuilder(CommonConstant.DIALOG_H, CommonConstant.DIALOG_H_CONTENT).setConfig({
                      dialogBehavior: {
                        layerPolicy: { alwaysTop: true, topDialogPriority: TopDialogPriority.NEW_FIRST }
                      }
                    }).build();
                    // [End layer_policy]
                    this.dialogH?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // Close all dialog on the current page
          ListItem() {
            ItemHead(CommonConstant.SHUT_DOW_ALL_DIALOG)
          }

          ListItemGroup() {
            ListItem() {
              Row() {
                Text($r('app.string.Shut_down'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_shut_down'))
                  .id(CommonConstant.DIALOG_MULTI_BINDING_BUTTON)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    let dialogs: InfDialog[] = DialogHub.getCurrentPageDialogs();
                    for (let index = 0; index < dialogs.length; index++) {
                      dialogs[index].dismiss();
                    }
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())
        }

      }
      .width(CommonConstant.FULL_LENGTH)
      .height(CommonConstant.FULL_LENGTH)
      .padding({
        left: $r('app.float.page_padding'),
        right: $r('app.float.page_padding'),
        bottom: $r('app.float.page_padding')
      })
    }
    .title($r('app.string.MultipleDialogExamples'))
    .backgroundColor($r('app.color.page_bg_color'))
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true;
    }).onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}