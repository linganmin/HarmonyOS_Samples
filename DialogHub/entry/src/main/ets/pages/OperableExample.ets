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
  DialogAction,
  DialogBackPressResult,
  DialogDismissReason,
  DialogHub,
  DialogStatus,
  InfCustomDialog,
  InfToast
} from "@hadss/dialoghub"
import { IconToastBuilder } from "../component/IconToastBuilder"
import { InputCallbackBuilder, InputCallbackParams } from "../component/InputCallbackBuilder"
import { SimpleCustomBuilder, SimpleCustomParams } from "../component/SimpleCustomBuilder"
import { ItemHead } from "../utils/ItemHead"
import { ProgressBuilder, ProgressParams } from "../component/ProgressBuilder"
import { SkipBuilder, SkipParams } from "../component/SkipBuilder"
import { ItemButtonModifier, ItemGroupModifier, ItemListModifier, ItemTextModifier } from "../utils/SampleModifier"
import { ActiveCloseBuilder, ActiveCloseParams } from "../component/ActiveCloseBuilder"
import CommonConstant from "../utils/CommonConstant"

@Builder
export function OperableBuilder(name: string, param: Object) {
  OperableExample();
}

@Component
export struct OperableExample {
  @StorageProp(CommonConstant.CURRENT_BREAK_POINT) curBp: string = CommonConstant.CURRENT_BREAK_POINT_SM;
  pageInfos: NavPathStack = new NavPathStack();
  simpleDialog1?: InfCustomDialog;
  simpleDialog2?: InfCustomDialog;
  simpleDialog3?: InfCustomDialog;
  passThroughGestureDialog?: InfToast;
  returnDataDialog?: InfCustomDialog;
  updateByParentDialog?: InfCustomDialog;
  skipDialog?: InfCustomDialog;
  // [Start back_close]
  @State backCloseDialog: boolean = false;
  // [End back_close]
  @State tagName: string = CommonConstant.TAG_NAME;
  intervalID: number = -1;
  @State dialogNum: number = 0; // Number of dialogs on the current page

  aboutToAppear(): void {
    this.simpleDialog3 =
      DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setContent(wrapBuilder(SimpleCustomBuilder),
        new SimpleCustomParams(CommonConstant.DIALOG_3, CommonConstant.DIALOG_3_NO_RESPONSE, () => {
          this.simpleDialog3?.dismiss()
        }))?.setStyle({
        radius: $r('app.float.dialog_3_radius'),
        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
      })?.build();
    this.simpleDialog3?.addLifeCycleListener({
      onWillDismiss: (reason: DialogDismissReason) => {
        if (this.backCloseDialog && reason === DialogDismissReason.PRESS_BACK) {
          return false;
        }
        return true;
      }
    })
    let params = new SkipParams(() => {
      this.skipDialog?.dismiss();
    }, 0, this.pageInfos);
    this.skipDialog = DialogHub.getCustomDialog()
      .setContent(wrapBuilder(SkipBuilder), params)
      .setStyle({ radius: $r('app.float.SkipBuilderBorderRadius') })
      .setConfig({ dialogBehavior: { isModal: true, autoDismiss: false } })
      .build();

    // [Start add_event]
    DialogHub.addEventListener({
      OnCurentPageDialogNumberChange: (newNum: number, oldNum: number) => {
        this.dialogNum = newNum;
      }
    })
    // [End add_event]
  }

  private createSensorDialog(title: string): InfCustomDialog | undefined {
    let sensorDialog: InfCustomDialog | undefined =
      DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setOperableContent(wrapBuilder(ActiveCloseBuilder),
        (action: DialogAction) => {
          let param = new ActiveCloseParams(
            title,
            "",
            CommonConstant.CANCEL,
            ((this.simpleDialog1?.getStatus() === DialogStatus.SHOW ||
              this.simpleDialog2?.getStatus() === DialogStatus.SHOW) ? CommonConstant.CLOSE : CommonConstant.OPEN +
              (title === CommonConstant.DIALOG_1 ? CommonConstant.DIALOG_2 : CommonConstant.DIALOG_1)),
            () => {
              action.dismiss()
            },
            () => {
              if ((this.simpleDialog1?.getStatus() === DialogStatus.SHOW &&
                this.simpleDialog2?.getStatus() === DialogStatus.SHOW)) {
                for (let i = DialogHub.getCurrentPageDialogs().length - 1; i >= 0; i--) {
                  DialogHub.getCurrentPageDialogs()[i].dismiss()
                }
              } else {
                if (title === CommonConstant.DIALOG_1) {
                  this.simpleDialog2 = this.createSensorDialog(CommonConstant.DIALOG_2);
                  this.simpleDialog2?.show();
                } else {
                  this.simpleDialog1 = this.createSensorDialog(CommonConstant.DIALOG_1);
                  this.simpleDialog1?.show();
                }
              }
            },
            ((this.simpleDialog1?.getStatus() === DialogStatus.SHOW ||
              this.simpleDialog2?.getStatus() === DialogStatus.SHOW) ? undefined : $r('app.color.base_blue')));
          return param;
        })
        .setStyle({
          radius: $r('app.float.dialog_3_radius'),
          shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
        })
        .setConfig({ dialogBehavior: { isModal: true, autoDismiss: false, passThroughGesture: false } })
        .build();
    return sensorDialog;
  }

  build() {
    NavDestination() {
      Row() {
        List() {
          // The custom return gesture is to exit the page or close the popup
          ListItem() {
            if (this.backCloseDialog) {
              ItemHead($r('app.string.currentlyAllocatedDialog'))
            } else {
              ItemHead($r('app.string.currentlyAllocatedPage'))
            }
          }

          ListItemGroup() {
            // Return gesture to the page
            ListItem() {
              Row() {
                Text($r('app.string.break_on_page'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_update'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    this.backCloseDialog = false;
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Return gesture to the dialog
            ListItem() {
              Row() {
                Text($r('app.string.break_on_dialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_update'))
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    this.backCloseDialog = true;
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Simple dialog_1
            ListItem() {
              Row() {
                Text($r('app.string.SHOW_SIMPLE_DIALOG_1'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    this.simpleDialog1 = this.createSensorDialog(CommonConstant.DIALOG_1);
                    this.simpleDialog1?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Simple dialog_2
            ListItem() {
              Row() {
                Text($r('app.string.SHOW_SIMPLE_DIALOG_2'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    this.simpleDialog2 = this.createSensorDialog(CommonConstant.DIALOG_2);
                    this.simpleDialog2?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Non-response Return gesture dialog_3
            ListItem() {
              Row() {
                Text($r('app.string.SHOW_SIMPLE_DIALOG_3'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    this.simpleDialog3?.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // Users can manipulate the page through the dialog content
          ListItem() {
            ItemHead($r('app.string.passThroughGestureDialog'))
          }

          ListItemGroup() {
            // A dialog with passThroughGesture
            ListItem() {
              Row() {
                Text($r('app.string.passThroughGestureDialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start pass_through]
                    this.passThroughGestureDialog = DialogHub.getToast()
                      .setContent(wrapBuilder(IconToastBuilder))
                      // [StartExclude pass_through]
                      .setStyle({
                        backgroundColor: Color.White,
                        radius: $r('app.float.passThroughGestureDialogRadius'),
                        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
                      })
                      // [EndExclude pass_through]
                      .setDuration(CommonConstant.DURATION_2000)
                      .build();
                    this.passThroughGestureDialog.show();
                    // [End pass_through]
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // Dialogs interact with the page for data
          ListItem() {
            ItemHead($r('app.string.dialog_interacts_with_page'))
          }

          ListItemGroup() {
            ListItem() {
              Row() {
                Text($r('app.string.tagName'))
                  .margin(CommonConstant.TOP_BOTTOM_MARGIN)
                  // .width(CommonConstant.FULL_LENGTH)
                  .textAlign(TextAlign.Center)
                Text(this.tagName)
                  .margin(CommonConstant.TOP_BOTTOM_MARGIN)
                  // .width(CommonConstant.FULL_LENGTH)
                  .textAlign(TextAlign.Center)
              }
              .alignSelf(ItemAlign.Center)
              .justifyContent(FlexAlign.SpaceAround)
              .alignItems(VerticalAlign.Center)

            }.attributeModifier(new ItemListModifier())

            // A dialog that needs to return data to the page
            ListItem() {
              Row() {
                Text($r('app.string.ReturnDataDialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start return_content]
                    this.returnDataDialog = DialogHub.getCustomDialog()
                      .setOperableContent(wrapBuilder(InputCallbackBuilder), (action: DialogAction) => {
                        let parms = new InputCallbackParams(CommonConstant.UPDATE_TAG, () => {
                          action.dismiss();
                        }, (value) => {
                          this.tagName = value;
                        })
                        return parms;
                      })
                      .setStyle({
                        radius: $r('app.float.InputCallbackBuilderBorderRadius')
                      })
                      .setConfig({ dialogBehavior: { isModal: true, autoDismiss: false } })
                      .build();
                    this.returnDataDialog.show();
                    // [End return_content]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // The parent page can refresh the dialog content
            ListItem() {
              Row() {
                Text($r('app.string.FatherPageUpdateDialogContent'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start pro_param]
                    let params = new ProgressParams(CommonConstant.ProgressName, CommonConstant.ProgressNameStart,
                      CommonConstant.ProgressNameTotal);

                    this.updateByParentDialog = DialogHub.getCustomDialog()
                      .setContent(wrapBuilder(ProgressBuilder), params)
                      .setStyle({ radius: $r('app.float.ProgressBuilderProgressBorderRadius') })
                      .setConfig({ dialogBehavior: { isModal: true, autoDismiss: false } })
                      .build();
                    this.updateByParentDialog.show();

                    this.intervalID = setInterval(() => {
                      params.value += 1
                      if (params.value >= CommonConstant.ProgressNameTotal && this.intervalID >= 0) {
                        this.updateByParentDialog?.dismiss();
                        clearInterval(this.intervalID);
                      }
                      this.updateByParentDialog?.updateContent(params);
                    }, CommonConstant.Interval_20);
                    // [End pro_param]
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())

          if (this.curBp === CommonConstant.CURRENT_BREAK_POINT_SM) {
            // The relationship between dialogs and pages
            ListItem() {
              ItemHead($r('app.string.DialogWithPage'))
            }

            ListItem() {
              Row() {
                Text($r('app.string.numbersOfDialogInCurrentPage'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.font_size_regular'))
                  .fontColor($r('app.color.now_dialogs_font_color'))
                  .margin({ bottom: $r('app.float.now_dialogs_bottom_margin') })
                Text(this.dialogNum.toString())
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.font_size_regular'))
                  .fontColor($r('app.color.now_dialogs_font_color'))
                  .margin({ bottom: $r('app.float.now_dialogs_bottom_margin') })
              }
            }

            ListItemGroup() {
              // There is dialog for jump link(Router)
              ListItem() {
                Row() {
                  Text($r('app.string.SkipRouter'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 0, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: { dx: 0, dy: 0 } }
                      });
                      this.skipDialog?.show();
                    })
                }
              }.attributeModifier(new ItemListModifier())

              // There is dialog for jump link(Navigation)
              ListItem() {
                Row() {
                  Text($r('app.string.SkipNavigation'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      // [Start skip_miss]
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 1, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: { dx: 0, dy: 0 } }
                      });
                      this.skipDialog?.show();
                      // [End skip_miss]
                    })
                }
              }.attributeModifier(new ItemListModifier())

              // (widescreen)Display dialog in specific split screens
              ListItem() {
                Row() {
                  Text($r('app.string.DifferentPositionShow'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 1, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: { dx: 0, dy: 0 } }
                      });
                      this.skipDialog?.show();
                    })
                }
              }.attributeModifier(new ItemListModifier())
            }.attributeModifier(new ItemGroupModifier())
          }

          ListItem() {
            Stack().width(CommonConstant.FULL_LENGTH).height($r('app.float.item_button_height'))
          }
        }
        .width(this.curBp === CommonConstant.CURRENT_BREAK_POINT_SM ? CommonConstant.FULL_LENGTH :
          CommonConstant.HALF_FULL_LENGTH)
        .padding({
          right: this.curBp === CommonConstant.CURRENT_BREAK_POINT_SM ? 0 : $r('app.float.DifferentPositionShowPadding')
        })
        .position({
          x: $r('app.float.DifferentPositionShowPositionX'),
          y: $r('app.float.DifferentPositionShowPositionY')
        })

        if (this.curBp === CommonConstant.CURRENT_BREAK_POINT_md ||
          this.curBp === CommonConstant.CURRENT_BREAK_POINT_lg) {
          List() {
            // The relationship between dialogs and pages
            ListItem() {
              ItemHead($r('app.string.DialogWithPage'))
            }

            ListItem() {
              Row() {
                Text($r('app.string.numbersOfDialogInCurrentPage'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.font_size_regular'))
                  .fontColor($r('app.color.now_dialogs_font_color'))
                  .margin({ bottom: $r('app.float.now_dialogs_bottom_margin') })
                Text(this.dialogNum.toString())
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.font_size_regular'))
                  .fontColor($r('app.color.now_dialogs_font_color'))
                  .margin({ bottom: $r('app.float.now_dialogs_bottom_margin') })
              }
            }


            ListItemGroup() {
              // There is dialog for jump link(Router)
              ListItem() {
                Row() {
                  Text($r('app.string.SkipRouter'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 0, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: { dx: 0, dy: 0 } }
                      });
                      this.skipDialog?.show();
                    })
                }
              }.attributeModifier(new ItemListModifier())

              // There is dialog for jump link(Navigation)
              ListItem() {
                Row() {
                  Text($r('app.string.SkipNavigation'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 1, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: { dx: 0, dy: 0 } }
                      });
                      this.skipDialog?.show();
                    })
                }
              }.attributeModifier(new ItemListModifier())

              // (left)Display dialog in specific split screens
              ListItem() {
                Row() {
                  Text($r('app.string.LeftDialog'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      // [Start skip_config]
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss()
                      }, 1, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: CommonConstant.LEFT_DIALOG_OFFSET }
                      });
                      this.skipDialog?.show();
                      // [End skip_config]
                    })
                }
              }.attributeModifier(new ItemListModifier())

              // (right)Display dialog in specific split screens
              ListItem() {
                Row() {
                  Text($r('app.string.RightDialog'))
                    .attributeModifier(new ItemTextModifier())

                  Button($r('app.string.Click_to_show'))
                    .attributeModifier(new ItemButtonModifier())
                    .onClick(() => {
                      // [Start new_skip]
                      let parms = new SkipParams(() => {
                        this.skipDialog?.dismiss();
                      }, 1, this.pageInfos);
                      this.skipDialog?.updateContent(parms);
                      this.skipDialog?.updateConfig({
                        dialogPosition: { offset: CommonConstant.RIGHT_DIALOG_OFFSET }
                      });
                      this.skipDialog?.show();
                      // [End new_skip]
                    })
                }
              }.attributeModifier(new ItemListModifier())
            }.attributeModifier(new ItemGroupModifier())
          }
          .padding({ left: $r('app.float.OperableExampleListPadding') })
          .width(CommonConstant.HALF_FULL_LENGTH)
          .position({ x: CommonConstant.HALF_FULL_LENGTH, y: 0 })
        }
      }
      .width(CommonConstant.FULL_LENGTH)
      .height(CommonConstant.FULL_LENGTH)
      .padding({ left: $r('app.float.page_padding'), right: $r('app.float.page_padding') })
    }
    .title($r('app.string.OperableDialogExamples'))
    .backgroundColor($r('app.color.page_bg_color'))
    // [Start back_press]
    .onBackPressed(() => {
      if (this.backCloseDialog) {
        let tmp: DialogBackPressResult = DialogHub.dispatchBackPressToDialog();
        if (tmp !== DialogBackPressResult.NO_DIALOG) {
          return true;
        }
      }
      this.pageInfos.pop();
      return true;
    })
    // [End back_press]
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}