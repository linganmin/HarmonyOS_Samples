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

import { STYLE_CONFIG, Constant } from '../common/Constants';
import { ToDo } from '../model/ToDo';

@Component
export struct ToDoListItem {
  UIContext = this.getUIContext()
  @Link achieveData: ToDo[];
  @Link toDoData: ToDo[];
  @ObjectLink toDoItem: ToDo;
  @State isEdited: boolean = false;

  /**
   * Add a completed data item.
   */
  addAchieveData() {
    this.toDoItem.isCompleted = !this.toDoItem.isCompleted;
    this.UIContext.animateTo({ duration: STYLE_CONFIG.ANIMATION_DURATION }, () => {
      if (this.toDoItem.isCompleted) {
        let tempData = this.toDoData.filter(item => item.key !== this.toDoItem.key);
        this.toDoData = tempData;
        this.achieveData.push(this.toDoItem);
      } else {
        let tempData = this.achieveData.filter(item => item.key !== this.toDoItem.key);
        this.achieveData = tempData;
        this.toDoData.push(this.toDoItem);
      }
    });
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: STYLE_CONFIG.ICON_GUTTER }) {
        if (!this.isEdited) {
          Row() {
            if (this.toDoItem.isCompleted) {
              Image($r('app.media.ic_public_ok_filled'))
                .width(STYLE_CONFIG.IMAGE_ICON_OK_SIZE)
                .aspectRatio(1)
                .borderRadius(STYLE_CONFIG.IMAGE_ICON_OK_SIZE)
                .fillColor(Color.White)
                .transition(TransitionEffect.IDENTITY)
            }
          }
          .width(STYLE_CONFIG.CUSTOM_CHECKBOX_SIZE)
          .justifyContent(FlexAlign.Center)
          .aspectRatio(1)
          .borderRadius(STYLE_CONFIG.CUSTOM_CHECKBOX_SIZE)
          .backgroundColor(this.toDoItem.isCompleted ? $r('sys.color.ohos_id_color_floating_button_bg_normal') :
            Color.Transparent)
          .borderWidth(1)
          .borderColor($r('sys.color.ohos_id_color_focused_content_tertiary'))
          .onClick(() => {
            this.addAchieveData();
          })

          Text(`${this.toDoItem.name}`)
            .maxLines(1)
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .layoutWeight(1)
            .decoration({ type: this.toDoItem.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
        } else {
          TextInput({ text: `${this.toDoItem.name}` })
            .maxLines(1)
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .id('textEdit')
            .onChange((value: string) => {
              // Update to-do data.
              this.toDoItem.name = value;
            })
            .onAppear(() => {
              // Requests the input box to obtain the focus.
              focusControl.requestFocus('textEdit');
            })
        }
        Blank()
        if (this.isEdited) {
          Image($r('app.media.ic_public_ok_filled'))
            .width(STYLE_CONFIG.MENU_IMAGE_SIZE)
            .aspectRatio(1)
            .onClick(() => {
              this.isEdited = false;
            })
        } else {
          Text($r('app.string.edit'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .onClick(() => {
              this.isEdited = true;
            })
        }
      }
      .width(Constant.PERCENT_FULL)
    }
    .width(Constant.PERCENT_FULL)
    .height(STYLE_CONFIG.TODO_ITEM_HEIGHT)
    .padding({
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      top: STYLE_CONFIG.TODO_ITEM_PADDING_VERTICAL,
      bottom: STYLE_CONFIG.TODO_ITEM_PADDING_VERTICAL
    })
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
    .backgroundColor(Color.White)
  }
}