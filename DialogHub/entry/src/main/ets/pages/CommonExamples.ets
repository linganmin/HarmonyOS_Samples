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
  AnimationType,
  CustomKeyboardAvoidMode,
  DialogAction,
  DialogDismissReason,
  DialogHub,
  InfCustomDialog,
  InfPopup,
  InfSheet,
} from "@hadss/dialoghub"
import { ActiveCloseBuilder, ActiveCloseParams } from '../component/ActiveCloseBuilder'
import { AutoDismissBuilder, AutoDismissParams } from '../component/AutoDismissBuilder'
import { InputBuilder, InputParams } from '../component/InputBuilder'
import { SheetBuilder, SheetParams } from '../component/SheetBuilder'
import { SnackbarBuilder, SnackbarParams } from '../component/SnackbarBuilder'
import { TextToastBuilder } from '../component/TextToastBuilder'
import { TimeToastBuilder, TimeToastParams } from '../component/TimeToastBuilder'
import { ItemHead } from '../utils/ItemHead'
import { ItemButtonModifier, ItemGroupModifier, ItemListModifier, ItemTextModifier } from '../utils/SampleModifier'
import { ImagePopupBuilder, ImagePopupParams } from '../component/ImagePopupBuilder'
import CommonConstant from "../utils/CommonConstant"

@Builder
export function CommonBuilder(name: string, param: Object) {
  CommonExamples();
}

@Component
export struct CommonExamples {
  pageInfos: NavPathStack = new NavPathStack();
  specifiedLocationDialog?: InfCustomDialog;
  intervalsDisappearsDialog?: InfCustomDialog;
  avoidKeyboardDialog?: InfCustomDialog;
  arrowPointingPopup?: InfPopup;
  maskCloseDialog?: InfCustomDialog;
  adjustSheetDialog?: InfSheet;
  sensorDialog?: InfCustomDialog;
  activelyCloseDialog?: InfCustomDialog;
  @State isSensorDialogShow: boolean = false;

  aboutToAppear(): void {
    this.sensorDialog = DialogHub.getCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)?.setStyle({
      radius: $r('app.float.custom_template_sample_radius'),
      shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
    }).setConfig(CommonConstant.CUSTOM_SAMPLE_CONFIG).build();

    // [Start sensor]
    this.sensorDialog?.addLifeCycleListener({
      onWillShow: () => {
        this.isSensorDialogShow = true
        return true;
      },
      onWillDismiss: (reason: DialogDismissReason) => {
        this.isSensorDialogShow = false
        return true;
      }
    })
    // [End sensor]

    // [Start sensor_log]
    // SHOW: 显示，HIDE: 隐藏， DEFAULT: 默认状态
    this.sensorDialog?.getStatus();
    // [End sensor_log]

    let sheetParams = new SheetParams();

    // [Start adjust]
    this.adjustSheetDialog = DialogHub.getSheet()
      .setContent(wrapBuilder(SheetBuilder), sheetParams)
      .setStyle({ detents: [CommonConstant.SHEET_MIDDLE, CommonConstant.SHEET_LARGE] })
      .setConfig({ enableOutsideInteractive: false, scrollSizeMode: ScrollSizeMode.CONTINUOUS })
      .setComponentTargetId(CommonConstant.ADJUST_SHEET_DIALOG_ID)
      .build();
    // [End adjust]

    // [Start adjust_log]
    this.adjustSheetDialog.addLifeCycleListener({
      onHeightDidChange: (h: number) => {
        let vpValue = this.getUIContext().px2vp(h)
        if (vpValue <= CommonConstant.SHEET_MIDDLE && sheetParams.type != 0) {
          sheetParams.type = 0
          this.adjustSheetDialog?.updateContent(sheetParams)
        } else if (vpValue > CommonConstant.SHEET_MIDDLE && sheetParams.type != 1) {
          sheetParams.type = 1
          this.adjustSheetDialog?.updateContent(sheetParams)
        }
      },
      // [StartExclude adjust_log]
      onWillDismiss: (reason: DialogDismissReason) => {
        if (reason === DialogDismissReason.TOUCH_OUTSIDE) {
          return false
        }
        return true;
      }
      // [EndExclude adjust_log]
    });
    // [End adjust_log]
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          // Modal dialog
          ListItem() {
            ItemHead($r("app.string.ModelDialog"))
          }

          ListItemGroup() {
            // Plain text has a duration prompt window
            ListItem() {
              Row() {
                Text($r('app.string.Tooltip_with_duration'))
                  .attributeModifier(new ItemTextModifier())
                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start dia_hub]
                    DialogHub.getToast()
                      .setContent(wrapBuilder(TextToastBuilder))
                        // [StartExclude dia_hub]
                      .setConfig(CommonConstant.CUSTOM_SAMPLE_CONFIG)
                      .setStyle({
                        backgroundColor: Color.White,
                        radius: $r('app.float.custom_template_sample_radius'),
                        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
                      })
                        // [EndExclude dia_hub]
                      .setDuration(CommonConstant.DURATION_3000)
                      .build()
                      .show();
                    // [Start dia_hub]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // A modal dialog for a specified location
            ListItem() {
              Row() {
                Text($r('app.string.Popup_specified_location'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start location]
                    this.specifiedLocationDialog = this.specifiedLocationDialog ?? DialogHub.getCustomDialog()
                      .setOperableContent(wrapBuilder(SnackbarBuilder), (action: DialogAction) => {
                        let param = new SnackbarParams(() => {
                          action.dismiss()
                        }, this.pageInfos)
                        return param
                      })
                        // [StartExclude location]
                      .setStyle({
                        radius: $r('app.float.custom_template_sample_radius'),
                        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
                      })
                        // [EndExclude location]
                      .setConfig({
                        dialogBehavior: { isModal: false, passThroughGesture: true },
                        dialogPosition: {
                          alignment: DialogAlignment.Bottom,
                          offset: { dx: 0, dy: $r('app.float.specified_location_offset') }
                        }
                      })
                      .build();
                    this.specifiedLocationDialog.show();
                    // [End location]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // It disappears on a regular basis with a dialog effect
            ListItem() {
              Row() {
                Text($r('app.string.Popup_disappears_intervals'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    let intervalID: number = -1;
                    let time: number = CommonConstant.TIMED_DIALOG_DURATION;
                    let params: TimeToastParams =
                      new TimeToastParams(CommonConstant.TIMED_DIALOG, time + CommonConstant.TIMED_CLOSED);
                    // [Start interval]
                    this.intervalsDisappearsDialog = this.intervalsDisappearsDialog ?? DialogHub.getCustomDialog()
                      .setContent(wrapBuilder(TimeToastBuilder), params)
                      .setStyle({
                        radius: $r('app.float.popup_disappears_intervals_radius'),
                        shadow: CommonConstant.CUSTOM_SAMPLE_STYLE_SHADOW
                      })
                      .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
                      .setConfig({
                        dialogBehavior: { isModal: false, passThroughGesture: true },
                        dialogPosition: {
                          alignment: DialogAlignment.Top,
                          offset: { dy: $r('app.float.popup_disappears_intervals_offset'), dx: 0 }
                        }
                      })
                      .build();

                    this.intervalsDisappearsDialog.show();

                    intervalID = setInterval(() => {
                      time -= 1;
                      params.content = time + CommonConstant.TIMED_CLOSED;
                      this.intervalsDisappearsDialog?.updateContent(params)
                      if (time <= 0 && intervalID) {
                        this.intervalsDisappearsDialog?.dismiss();
                        clearInterval(intervalID);
                      }
                    }, CommonConstant.DURATION_1000);
                    // [End interval]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Avoids keyboard dialog
            ListItem() {
              Row() {
                Text($r('app.string.Avoid_keyboard_dialog'))
                  .attributeModifier(new ItemTextModifier())
                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    let param = new InputParams((inputValue) => {
                      this.avoidKeyboardDialog?.dismiss();
                      DialogHub.getToast()
                        .setTextContent(inputValue)
                        .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
                        .setDuration(CommonConstant.DURATION_2000)
                        .build()
                        .show();
                    }, CommonConstant.INPUT_DEFAULT_VALUE);
                    // [Start avoid_log]
                    this.avoidKeyboardDialog = this.avoidKeyboardDialog ?? DialogHub.getCustomDialog()
                      .setContent(wrapBuilder(InputBuilder), param)
                        // [StartExclude avoid_log]
                      .setStyle({
                        height: $r('app.float.avoid_keyboard_dialog_height'),
                        backgroundColor: Color.White
                      })
                        // [EndExclude avoid_log]
                      .setConfig({
                        dialogBehavior: {
                          isModal: false,
                          passThroughGesture: true,
                          requestFocusWhenShow: true,
                          keyboardAvoidMode: CustomKeyboardAvoidMode.CONTENT_AVOID
                        },
                        dialogPosition: { alignment: DialogAlignment.Bottom }
                      })
                      .build();
                    this.avoidKeyboardDialog.show();
                    // [End avoid_log]
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())

          // Not modal dialog
          ListItem() {
            ItemHead($r('app.string.ModelessDialog'))
          }

          ListItemGroup() {
            // Arrow dialog to selected components
            ListItem() {
              Row() {
                Text($r('app.string.Arrow_pointing_dialog'))
                  .attributeModifier(new ItemTextModifier())
                  .id('PopupDialog1')
                  .onClick(() => {
                    // [Start pop_up]
                    DialogHub.getPopup()
                      // [StartExclude pop_up]
                      .setOperableContent(wrapBuilder(ImagePopupBuilder), (action: DialogAction) => {
                        let param = new ImagePopupParams(() => {
                          action.dismiss()
                        })
                        return param
                      })
                        // [EndExclude pop_up]
                      .setComponentTargetId('PopupDialog1')
                      .setStyle({
                        radius: $r('app.float.image_popup_builder_borderRadius'),
                        backgroundColor: Color.White,
                        shadow: {
                          radius: $r('app.float.image_popup_shadow_radius'),
                          color: $r('app.color.image_popup_shadow_color')
                        },
                      })
                      .setConfig({
                        dialogPosition: {
                          preferPlacement: Placement.Bottom
                        }
                      })
                      .build()
                      .show();
                    // [End pop_up]
                  })


                Button($r('app.string.Click_to_show'))
                  .id('PopupDialog')
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    this.arrowPointingPopup = this.arrowPointingPopup ?? DialogHub.getPopup()
                      .setOperableContent(wrapBuilder(ImagePopupBuilder), (action: DialogAction) => {
                        let param = new ImagePopupParams(() => {
                          action.dismiss()
                        })
                        return param
                      })
                      .setComponentTargetId('PopupDialog')
                      .setStyle({
                        // borderWidth: 10,
                        borderColor: Color.Red,
                        radius: $r('app.float.image_popup_builder_borderRadius'),
                        backgroundColor: Color.White,
                        shadow: {
                          radius: $r('app.float.image_popup_shadow_radius'),
                          color: $r('app.color.image_popup_shadow_color')
                        },
                      })
                      .setConfig({
                        dialogPosition: {
                          preferPlacement: Placement.Bottom
                        }
                      })
                      .build();
                    this.arrowPointingPopup.show();
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Click the dialog window that automatically closes the mask
            ListItem() {
              Row() {
                Text($r('app.string.Mask_automatically_close_dialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start mask_log]
                    this.maskCloseDialog = this.maskCloseDialog ?? DialogHub.getCustomDialog()
                      // [StartExclude mask_log]
                      .setOperableContent(wrapBuilder(AutoDismissBuilder), (action: DialogAction) => {
                        let param = new AutoDismissParams(() => {
                          action.dismiss()
                        })
                        return param
                      })
                      .setStyle({
                        radius: $r('app.float.auto_dismiss_builder_borderRadius'),
                        backgroundColor: Color.White,
                        maskColor: $r('app.color.mask_automatically_close_dialog_maskColor')
                      })
                        // [EndExclude mask_log]
                      .setConfig({ dialogBehavior: { isModal: true, autoDismiss: true, passThroughGesture: false } })
                      .build();
                    this.maskCloseDialog.show();
                    // [End mask_log]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // dialog window that can be actively closed
            ListItem() {
              Row() {
                Text($r('app.string.Actively_close_dialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start active_close]
                    this.activelyCloseDialog = this.activelyCloseDialog ?? DialogHub.getCustomDialog()
                      .setOperableContent(wrapBuilder(ActiveCloseBuilder), (action: DialogAction) => {
                        let param =
                          new ActiveCloseParams(CommonConstant.LOGOUT, CommonConstant.LOGOUT_TIPS,
                            CommonConstant.CANCEL, CommonConstant.OUT, () => {
                              action.dismiss();
                            }, () => {
                              this.activelyCloseDialog?.dismiss();
                            })
                        return param;
                      })
                      .setConfig({ dialogBehavior: { isModal: true, autoDismiss: false, passThroughGesture: false } })
                      .setStyle({
                        radius: $r('app.float.active_close_builder_borderRadius'),
                        backgroundColor: Color.White,
                      })
                      .build();
                    this.activelyCloseDialog.show();
                    // [End active_close]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Bottom dialog window with dynamic height adjustment
            ListItem() {
              Row() {
                Text($r('app.string.Adjust_height_dialog'))
                  .attributeModifier(new ItemTextModifier())

                Button($r('app.string.Click_to_show'))
                  .id(CommonConstant.ADJUST_SHEET_DIALOG_ID)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start adjust_log]
                    this.adjustSheetDialog?.show();
                    // [End adjust_log]
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // Sense non-modal dialog
          ListItem() {
            Row() {
              ItemHead($r('app.string.ModelessDialog'))

              Text(this.isSensorDialogShow ? $r('app.string.DialogStateOpen') : $r('app.string.DialogStateClose'))
                .fontSize($r('app.float.font_size_regular'))
                .textAlign(TextAlign.End)
                .fontColor($r('app.color.base_blue'))
                .fontWeight(FontWeight.Medium)
                .margin({ top: $r('app.float.item_head_top_margin'), bottom: $r('app.float.item_head_bottom_margin') })
            }
          }

          ListItemGroup() {
            ListItem() {
              Row() {
                Text($r('app.string.Perceive_status_dialog'))
                  .attributeModifier(new ItemTextModifier())

                Toggle({ type: ToggleType.Switch, isOn: false })
                  .width($r('app.float.Perceive_status_dialog_width'))
                  .height($r('app.float.perceive_status_dialog_height'))
                  .backgroundColor(Color.White)
                  .onChange((isOn: boolean) => {
                    if (isOn) {
                      this.sensorDialog?.show();
                    } else {
                      this.sensorDialog?.dismiss();
                    }
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())
        }
        .onDidScroll(() => {
          this.arrowPointingPopup?.updateDialogPosition();
        })
      }
      .width(CommonConstant.FULL_LENGTH)
      .height(CommonConstant.FULL_LENGTH)
      .padding({
        left: $r('app.float.page_padding'),
        right: $r('app.float.page_padding'),
        bottom: $r('app.float.page_padding')
      })
    }
    .title($r('app.string.CommonDialogExamples'))
    .backgroundColor($r('app.color.page_bg_color'))
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true;
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}