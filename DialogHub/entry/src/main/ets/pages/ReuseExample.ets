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
import { AnimationType, DialogHub, InfToast } from "@hadss/dialoghub"
import CommonConstant from "../utils/CommonConstant"
import { ItemHead } from "../utils/ItemHead"
import { ItemButtonModifier, ItemGroupModifier, ItemListModifier, ItemTextModifier } from "../utils/SampleModifier"

@Builder
export function ReuseBuilder(name: string, param: Object) {
  ReuseExample();
}

@Component
export struct ReuseExample {
  // [Start original]
  originalTemplateDialog?: InfToast;
  // [End original]
  changeTemplateDialog?: InfToast;
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {

        List() {
          // Using custom dialog template
          ListItem() {
            ItemHead(CommonConstant.REUSEEXAMPLE_ITEMHEAD)
          }

          ListItemGroup() {
            // create template
            ListItem() {
              Row() {
                Text(CommonConstant.CREATE_DIALOG_TEMPLATE)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_CREATE)
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    // [Start click_create]
                    DialogHub.createToastTemplate(CommonConstant.MY_TEMPLATE_NAME)
                      .setTextContent(CommonConstant.TOAST_DISPLAYED_CONTENT)
                        // [StartExclude click_create]
                      .setStyle({
                        radius: $r('app.float.vp_18'),
                        shadow: {
                          radius: $r('app.float.vp_20'),
                          color: $r('app.color.toast_template_shadow_color'),
                          offsetY: $r('app.float.vp_8')
                        }
                      })
                      .setConfig({
                        dialogPosition: {
                          alignment: DialogAlignment.Bottom,
                          offset: { dx: $r('app.float.vp_0'), dy: $r('app.float.toast_position_offset_y') }
                        }
                      })
                        // [EndExclude click_create]
                      .setDuration(CommonConstant.TOAST_DISPLAY_DURATION)
                      .register();
                    // [End click_create]

                    // [Start original_dialog]
                    this.originalTemplateDialog =
                      DialogHub.getToastTemplate(CommonConstant.MY_TEMPLATE_NAME)?.build();
                    // [End original_dialog]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // remove template
            ListItem() {
              Row() {
                Text(CommonConstant.DELETE_TEMPLATE)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_DELETE)
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    // [Start remove_late]
                    DialogHub.removeTemplate(CommonConstant.MY_TEMPLATE_NAME);
                    // [End remove_late]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // update template
            ListItem() {
              Row() {
                Text(CommonConstant.RANDOMIZE_TEMPLATE_BACKGROUND)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_MODIFY)
                  .attributeModifier(new ItemButtonModifier())

                  .onClick(() => {
                    // [Start ceil_toString]
                    let r = (Math.ceil(Math.random() * 239 + 16) % 255).toString(16);
                    let g = (Math.ceil(Math.random() * 239 + 16) % 255).toString(16);
                    let b = (Math.ceil(Math.random() * 239 + 16) % 255).toString(16);
                    let color = '#ff' + r + g + b;
                    DialogHub.updateToastTemplate(CommonConstant.MY_TEMPLATE_NAME)?.setStyle({
                      backgroundColor: color
                    }).register();
                    // [End ceil_toString]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // get template to show dialog
            ListItem() {
              Row() {
                Text(CommonConstant.DIRECTLY_POPUP_DIALOG)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_DEMONSTRATE)
                  .id(CommonConstant.POPUP_DIRECTLY_BUTTON_ID)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start get_toast_late]
                    DialogHub.getToastTemplate(CommonConstant.MY_TEMPLATE_NAME)?.build().show();
                    // [End get_toast_late]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Use the template and define the dialog animation to show dialog
            ListItem() {
              Row() {
                Text(CommonConstant.POPUP_WITH_ANIMATION)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_DEMONSTRATE)
                  .id(CommonConstant.POPUP_WITH_ANIMATION_BUTTON_ID)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start dial_animation]
                    DialogHub.getToastTemplate(CommonConstant.MY_TEMPLATE_NAME)?.setAnimation({
                      dialogAnimation: AnimationType.UP_DOWN
                    }).build().show();
                    // [End dial_animation]
                  })
              }
            }.attributeModifier(new ItemListModifier())

            // Use the template and define the dialog position to show dialog
            ListItem() {
              Row() {
                Text(CommonConstant.POPUP_AFTER_DEFINING_POSITION)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_DEMONSTRATE)
                  .id(CommonConstant.POPUP_WITH_CUSTOM_POSITION_BUTTON_ID)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    DialogHub.getToastTemplate(CommonConstant.MY_TEMPLATE_NAME)?.setConfig({
                      dialogPosition: {
                        alignment: DialogAlignment.Top,
                        offset: { dx: $r('app.float.vp_0'), dy: CommonConstant.Y_OFFSET }
                      }
                    }).build().show();
                  })
              }
            }.attributeModifier(new ItemListModifier())
          }.attributeModifier(new ItemGroupModifier())


          // The same object for dialog show
          ListItem() {
            ItemHead(CommonConstant.CREATE_DIALOG_FROM_SAME_INSTANCE)
          }

          ListItemGroup() {
            // The same object for dialog show
            ListItem() {
              Row() {
                Text(CommonConstant.DIALOG_TEXT)
                  .attributeModifier(new ItemTextModifier())

                Button(CommonConstant.CLICK_TO_DEMONSTRATE)
                  .id(CommonConstant.SINGLETON_DIALOG_ID)
                  .attributeModifier(new ItemButtonModifier())
                  .onClick(() => {
                    // [Start dia_log]
                    this.originalTemplateDialog?.show();
                    // [End dia_log]
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
    .title($r('app.string.ReusableDialogExamples'))
    .width(CommonConstant.FULL_LENGTH)
    .height(CommonConstant.FULL_LENGTH)
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