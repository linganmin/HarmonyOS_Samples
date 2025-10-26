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

/**
 * 最佳实践：分析跨线程序列化耗时问题
 */

// [Start book]
import { taskpool } from '@kit.ArkTS';
class Book {
  recordId_: string = '';
  title_: string = '';
  content_: string = '';
  authorList_: Array<string> | null = null;
  constructor() {
    // Initialize static information related to Book
    // ...
  }
  // omit other member methods
  // ...
}
class BookDBInfo {
  dbName_: string = '';
  seq_: number = 0;
  tableName_: string = '';
  books_: Array<Book> | null = null;
  constructor(dbName: string, tableName: string) {
    this.dbName_ = dbName;
    this.tableName_ = tableName;
  }
}
function prepareBooksInfo() {
  let dbInfo = new BookDBInfo('database1','books');
  dbInfo.books_ = new Array<Book>();
  for (let i = 0; i < 50000; i++) {
    let book = new Book();
    book.authorList_ = new Array<string>();
    // Assemble book information
    // ...
    dbInfo.books_?.push(book);
  }
  let res = taskpool.execute(doDBOperations, dbInfo); // Passing across concurrent instances through taskpool
}
@Concurrent
function doDBOperations(info : BookDBInfo) {
  // Perform database-related operations
  // ...
}

// [End book]

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}