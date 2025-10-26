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

import { Action, Reducer } from '@hadss/state_store';
import { TodoItemData, TodoStoreModel } from '../model/TodoListModel';
import { TodoStore } from './TodoListStore';
import TodoListActions from './TodoListActions';
import RdbUtil from '../utils/RdbUtil';
import GlobalContext from '../utils/GlobalContext';

let uiContext: UIContext | undefined

// [Start todo_list_reducer]
export const todoReducer: Reducer<TodoStoreModel> = (state: TodoStoreModel, action: Action) => {
  let GlobalContent = GlobalContext.getInstance();
  uiContext = GlobalContent.getUIContext()
  switch (action.type) {
    case TodoListActions.getTodoList.type:
      return async () => {
        state.todoList = (await RdbUtil.getInstance(uiContext?.getHostContext()!)).query();
      };
    case TodoListActions.addTodoList.type:
      if (state.addTaskTextInputValue === '') {
        uiContext!.getPromptAction().showToast({ message: $r('app.string.empty') });
        return null;
      }
      state.todoList.push(new TodoItemData(state.addTaskTextInputValue));
      state.isShow = false;
      state.addTaskTextInputValue = '';
      break;
    case TodoListActions.deleteTodoItem.type:
      // [StartExclude todo_list_reducer]
      uiContext!.getPromptAction().showDialog({
        message: $r('app.string.deleteCurrentTips'),
        buttons: [
          {
            text: $r('app.string.dialog_cancel'),
            color: $r('app.color.text_blue')
          },
          {
            text: $r('app.string.dialog_delete'),
            color: $r('app.color.text_blue')
          }
        ]
      }).then((res) => {
        if (res.index === 1) {
          let index: number | undefined;
          state.todoList.find((item, _index) => {
            index = _index;
            return item.id === action.payload;
          });
          if (index !== undefined) {
            state.todoList.splice(index, 1);
          }
        }
      });
      // [EndExclude todo_list_reducer]
      break;
    case TodoListActions.updateTaskDetail.type:
      // [StartExclude todo_list_reducer]
      const currentItem = state.todoList.find(item => item.id === action.payload.id);
      if (currentItem) {
        if (action.payload.value === '') {
          uiContext!.getPromptAction().showToast({ message: $r('app.string.empty') });
          return null;
        }
        currentItem.taskDetail = action.payload.value;
        currentItem.toDoItemSendable.detail = action.payload.value;
        currentItem.updateState(0)
      }
      // [EndExclude todo_list_reducer]
      break;
    case TodoListActions.completeTodoItem.type:
      // [StartExclude todo_list_reducer]
      const todoItem = state.todoList.find(item => item.id === action.payload.id);
      if (todoItem) {
        todoItem.selected = action.payload.value;
        todoItem.toDoItemSendable.selected = action.payload.value;
        todoItem.updateState(0)
      }
      // [EndExclude todo_list_reducer]
      break;
    // [StartExclude todo_list_reducer]
    case TodoListActions.changeTextInput.type:
      state.addTaskTextInputValue = action.payload;
      break;
    case TodoListActions.clearCompletedTodoList.type:
      uiContext!.getPromptAction().showDialog({
        message: $r('app.string.deleteTips', state.todoList.filter(item => item.selected).length),
        buttons: [
          {
            text: $r('app.string.dialog_cancel'),
            color: $r('app.color.text_blue')
          },
          {
            text: $r('app.string.dialog_delete'),
            color: $r('app.color.text_blue')
          }
        ]
      }).then((res) => {
        if (res.index === 1) {
          for (let i = state.todoList.length - 1; i >= 0; i--) {
            if (state.todoList[i].selected) {
              state.todoList.splice(i, 1);
            }
          }
        }
      });
      break;
    case TodoListActions.showSheet.type:
      state.isShow = true;
      break;
    case TodoListActions.hideSheet.type:
      uiContext!.getPromptAction().showDialog({
        message: $r('app.string.closeTips'),
        buttons: [
          {
            text: $r('app.string.dialog_not_save'),
            color: $r('app.color.text_blue')
          },
          {
            text: $r('app.string.dialog_save'),
            color: $r('app.color.text_blue')
          }
        ]
      }).then((res) => {
        if (res.index === 1) {
          TodoStore.dispatch(TodoListActions.addTodoList);
        } else {
          state.isShow = false;
        }
      });
      break;
    // [Start reducer_case]
    case TodoListActions.updateProgress.type:
      let item = state.syncTodoList.find(item => item.id === action.payload);
      item?.updateState(1);
      state.progress.value++;
      break;
    case TodoListActions.setTotal.type:
      state.syncTodoList = state.todoList.filter(item => item.state === 0);
      state.progress.total = action.payload;
      break;
    // [End reducer_case]
    case TodoListActions.setButtonMargin.type:
      state.marginBottom = action.payload;
      break;
    case TodoListActions.clearProgress.type:
      state.progress.value = 0
      state.progress.total = 0
      break;
    // [EndExclude todo_list_reducer]
  }
  return null;
};

// [End todo_list_reducer]