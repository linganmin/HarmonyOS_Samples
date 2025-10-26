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

import { taskpool } from '@kit.ArkTS';
import { SendableAction, StateStore } from '@hadss/state_store';
import { TodoItemData, ToDoItemSendable } from '../model/TodoListModel';
import RdbUtil from './RdbUtil';
import { sleep } from './Sleep';
import { TODO_LIST_STORE_ID, TodoStore } from '../store/TodoListStore';
import TodoListActions from '../store/TodoListActions';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
// [Start sync_data_base]
export async function syncDatabase() {
  try {
    const todos: TodoItemData[] = TodoStore.getState().todoList;
    const ToBeSynced = todos.map(item => item.toDoItemSendable);
    let task: taskpool.Task = new taskpool.Task(concurrentUpdateProgress, uiContext?.getHostContext()!, ToBeSynced);
    task.onReceiveData((data: SendableAction) => {
      // Use the receiveSendableAction method to trigger the Action sent by the child thread to refresh the state
      StateStore.receiveSendableAction(data);
    });
    await taskpool.execute(task);
    TodoStore.dispatch(TodoListActions.clearProgress);
  } catch (err) {
    console.error(`${err.message}\n${err.stack}`);
  }
}
// [End sync_data_base]

// [Start concurrent_update_progress]
@Concurrent
async function concurrentUpdateProgress(context: Context, data: ToDoItemSendable[]): Promise<void> {
  try {
    let rdb = await RdbUtil.getInstance(context);
    const originalIds = rdb.getAllIds();
    const toAdd = data.filter(todo =>!originalIds.some(id => todo.id === id));
    const toUpdate = data.filter(todo => todo.state === 0 && originalIds.indexOf(todo.id) > -1);
    const toDelete = originalIds.filter(id =>!data.some(todo => todo.id === id));
    // send setTotal event to set the total number of progress bars
    taskpool.Task.sendData(StateStore.createSendableAction(TODO_LIST_STORE_ID, TodoListActions.setTotal.type,
      toAdd.length + toUpdate.length + toDelete.length));

    for (const todo of toAdd) {
      rdb.inset(todo);
      await sleep(500);
      // send the update progress bar event updateProgress
      taskpool.Task.sendData(StateStore.createSendableAction(TODO_LIST_STORE_ID, TodoListActions.updateProgress.type,
        todo.id));
    }
    // [StartExclude concurrent_update_progress]
    for (const todo of toUpdate) {
      rdb.update(todo);
      await sleep(500);
      taskpool.Task.sendData(StateStore.createSendableAction(TODO_LIST_STORE_ID, TodoListActions.updateProgress.type,
        todo.id));
    }
    for (const id of toDelete) {
      rdb.delete(id);
      await sleep(500);
      taskpool.Task.sendData(StateStore.createSendableAction(TODO_LIST_STORE_ID, TodoListActions.updateProgress.type,
        id));
    }
    // [EndExclude concurrent_update_progress]
  } catch (err) {
    console.error(`${err.message}\n${err.stack}`);
    return undefined;
  }
}
// [End concurrent_update_progress]