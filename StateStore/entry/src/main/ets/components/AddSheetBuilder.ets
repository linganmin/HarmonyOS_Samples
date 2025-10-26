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

import TodoListActions from '../store/TodoListActions';
import { TodoStore } from '../store/TodoListStore';

@Builder
export function addSheetBuilder() {
  Column({ space: 8 }) {
    Row({ space: 8 }) {
      TextInput({ text: TodoStore.getState().addTaskTextInputValue, placeholder: $r('app.string.to_do_task') })
        .layoutWeight(1)
        .backgroundColor($r('app.color.color_white'))
        .borderRadius(0)
        .enableKeyboardOnFocus(false)
        .onChange((value) => {
          TodoStore.dispatch(TodoListActions.changeTextInput.setPayload(value));
        });
    }
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

    Blank().layoutWeight(1);

    Button($r('app.string.finished'))
      .width('100%')
      .margin({ bottom: TodoStore.getState().marginBottom })
      .onClick(() => {
        TodoStore.dispatch(TodoListActions.addTodoList);
      });
  }
  .width('100%')
  .height('100%')
  .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
}