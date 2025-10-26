/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:获取指定文件系统的剩余空间大小
*/

// [Start CheckStorageSpace]
import { BusinessError } from '@kit.BasicServicesKit';
import { statfs } from '@kit.CoreFileKit';

@Entry
@Component
struct GetFileSpace {
  build() {
    Column() {
      Button('Obtain the system space size')
        .onClick(() => {
          let context = this.getUIContext().getHostContext();
          let path = context!.filesDir;

          //Get the total number of bytes in the specified file system
          statfs.getTotalSize(path).then((number: number) => {
            console.info('getTotalSize succeed, Size: ' + number);
          }).catch((err: BusinessError) => {
            console.error('getTotalSize failed with error message: ' + err.message + ', error code: ' + err.code);
          });

          //Get the number of idle bytes in the specified file system
          statfs.getFreeSize(path).then((number: number) => {
            console.info('getFreeSize succeed, Size: ' + number);
          }).catch((err: BusinessError) => {
            console.error('getFreeSize failed with error message: ' + err.message + ', error code: ' + err.code);
          });
        })
    }
  }
}
// [End CheckStorageSpace]