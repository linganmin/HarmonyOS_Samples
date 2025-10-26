/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { TodoItemData } from '../model/TodoListModel';
import TodoListActions from '../store/TodoListActions';
import { TodoStore } from '../store/TodoListStore';

// [Start todo_list_item]
@ComponentV2
export struct TodoItem {
  @Param @Require itemData: TodoItemData;
  // [StartExclude todo_list_item]
  @Local isEdit: boolean = false;
  @Local editTextInput: string = '';

  // [EndExclude todo_list_item]

  build() {
    Row({ space: 8 }) {
      Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
        .select(this.itemData.selected)
        .shape(CheckBoxShape.CIRCLE)
        .onChange((_value) => {
          // The child component changes the global state by sending a CompleteTodoItem event through the dispatch method, setting the current item to complete
          TodoStore.dispatch(TodoListActions.completeTodoItem.setPayload({ id: this.itemData.id, value: _value }));
        });
      // [StartExclude todo_list_item]
      Row() {
        if (this.isEdit) {
          TextInput({ text: this.itemData.taskDetail, placeholder: $r('app.string.to_do_task') })
            .layoutWeight(1)
            .margin({ right: $r('app.float.vp_10') })
            .enableKeyboardOnFocus(true)
            .backgroundColor($r('app.color.color_white'))
            .onSubmit(() => {
              TodoStore.dispatch(TodoListActions.updateTaskDetail.setPayload({
                id: this.itemData.id,
                value: this.editTextInput
              }));
              this.isEdit = false;
            })
            .onChange((value) => {
              this.editTextInput = value;
            });
        } else {
          Text(this.itemData.taskDetail)
            .fontColor(this.itemData.selected ? $r('app.color.text_three') : $r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ right: $r('app.float.vp_10') })
            .maxLines(1);
          Blank();
          if (!this.itemData.selected) {
            Image($r('app.media.square_and_pencil'))
              .width($r('app.float.icon_size'))
              .height($r('app.float.icon_size'))
              .margin({ right: $r('app.float.vp_24') })
              .onClick(() => {
                this.isEdit = true;
              });
          }
          Image($r('app.media.trash'))
            .interpolation(ImageInterpolation.High)
            .width($r('app.float.icon_size'))
            .height($r('app.float.icon_size'))
            .margin({ right: $r('app.float.vp_10') })
            .onClick(() => {
              TodoStore.dispatch(TodoListActions.deleteTodoItem.setPayload(this.itemData.id));
            });
        }
      }.layoutWeight(1);

      // [EndExclude todo_list_item]
    }
    // [StartExclude todo_list_item]
    .height($r('app.float.todo_item_height'))
    .width('100%')
    .borderRadius($r('app.float.vp_16'))
    .padding({
      left: $r('app.float.vp_12'),
      top: $r('app.float.vp_8'),
      bottom: $r('app.float.vp_8'),
      right: $r('app.float.vp_12')
    })
    .backgroundColor($r('app.color.color_white'));

    // [EndExclude todo_list_item]
  }
}

// [End todo_list_item]