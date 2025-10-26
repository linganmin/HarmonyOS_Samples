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

import { lang } from '@kit.ArkTS';

// [Start todo_item_data]
@ObservedV2
export class TodoItemData {
  id: number = 0;
  @Trace taskDetail: string = '';
  @Trace selected?: boolean;
  // [StartExclude todo_item_data]
  @Trace state: number;
  toDoItemSendable: ToDoItemSendable;

  // [EndExclude todo_item_data]

  constructor(taskDetail: string, selected?: boolean, id?: number) {
    this.id = id ? id : Date.now();
    this.taskDetail = taskDetail;
    this.selected = selected;
    // [StartExclude todo_item_data]
    this.toDoItemSendable = new ToDoItemSendable(this.id, this.taskDetail, this.selected);
    this.state = this.toDoItemSendable.state;
    // [EndExclude todo_item_data]
  }

  // [StartExclude todo_item_data]
  updateState(state: number) {
    this.state = state;
    this.toDoItemSendable.state = state;
  }

  // [EndExclude todo_item_data]
}

// [End todo_item_data]

// [Start todo_item_sendable]
@Sendable
export class ToDoItemSendable implements lang.ISendable {
  id: number;
  detail: string;
  selected: boolean;
  state: number;

  constructor(id: number, detail: string, selected: boolean = false) {
    this.id = id;
    this.selected = selected;
    this.detail = detail;
    this.state = 0;
  }
}

// [End todo_item_sendable]

@ObservedV2
export class Progress {
  @Trace value: number = 0;
  @Trace total: number = 0;
  valueMonitorCallBack?: (value: number) => void;

  @Monitor('value')
  valueChange() {
    this.valueMonitorCallBack?.(this.value);
  }

  setValueMonitor(callback: (value: number) => void): void {
    this.valueMonitorCallBack = callback;
  }
}

// [Start todo_store_model]
@ObservedV2
export class TodoStoreModel {
  @Trace todoList: TodoItemData[] = [];
  @Trace isShow: boolean = false;
  addTaskTextInputValue: string = '';
  // [StartExclude todo_store_model]
  @Trace progress: Progress = new Progress();
  @Trace syncTodoList: TodoItemData[] = [];
  @Trace marginBottom: number = 0;

  @Computed
  get percent(): number {
    let per = (this.progress.value / this.progress.total) * 100;
    return (per > -1) ? per : 100;
  }

  // [EndExclude todo_store_model]

  @Computed
  get uncompletedTodoList(): TodoItemData[] {
    return this.todoList.filter(item => !item.selected);
  }

  @Computed
  get completedTodoList(): TodoItemData[] {
    return this.todoList.filter(item => item.selected);
  }
}

// [End todo_store_model]