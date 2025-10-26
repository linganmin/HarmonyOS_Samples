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

import { Action, StateStore } from '@hadss/state_store';

// [Start todo_list_actions]
export default class TodoListActions {
  static getTodoList: Action = StateStore.createAction('getTodoList');
  static addTodoList: Action = StateStore.createAction('addTodoList');
  static deleteTodoItem: Action = StateStore.createAction('deleteTodoItem');
  static updateTaskDetail: Action = StateStore.createAction('updateTaskDetail');
  static completeTodoItem: Action = StateStore.createAction('completeTodoItem');
  // [StartExclude todo_list_actions]
  static clearCompletedTodoList: Action = StateStore.createAction('clearCompletedTodoList');
  static changeTextInput: Action = StateStore.createAction('changeTextInput');
  static showSheet: Action = StateStore.createAction('showSheet');
  static hideSheet: Action = StateStore.createAction('hideSheet');
  static updateProgress: Action = StateStore.createAction('updateProgress');
  static setTotal: Action = StateStore.createAction('setTotal');
  static setButtonMargin: Action = StateStore.createAction('setButtonMargin');
  static clearProgress: Action = StateStore.createAction('clearProgress');
  // [EndExclude todo_list_actions]
};

// [End todo_list_actions]
