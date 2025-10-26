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
 * 最佳实践：文件句柄泄漏类问题检测方法
 */

// [Start fd_leak_detection_case]
import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

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
          let listFileOption:ListFileOptions={};
          listFileOption.recursion = false;
          listFileOption.listNum = 10000;
          fs.listFile("/proc/self/fd", listFileOption, (err: BusinessError, fileNames: Array<string>) => {
            if (err) {
              console.error("list file failed, message:", err.message + ", code:" + err.code);
            } else {
              console.log("count:", fileNames.length);
              fileNames.forEach(fileName => {
                let fd: number = Number(fileName);
                try {
                  let actName = fs.dup(fd);
                  console.info('fd:', fd);
                  console.info('path:', actName.path);
                  fs.close(actName);
                } catch(e) {
                  console.info(e);
                }
              });
            }
          });
        })
    }
    .height('100%')
    .width('100%')
  }
}
// [End fd_leak_detection_case]