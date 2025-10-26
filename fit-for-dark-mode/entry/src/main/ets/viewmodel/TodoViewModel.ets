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

import { Todo } from "./Todo";

export class TodoViewModel {
  private todos: Todo[] = [];

  constructor() {
    this.todos.push(new Todo('001', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('002', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('003', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('004', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('005', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('006', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('007', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('008', $r('app.string.todo_item_title')));
    this.todos.push(new Todo('009', $r('app.string.todo_item_title')));
  }

  public getTodos(): Todo[] {
    return this.todos;
  }
}