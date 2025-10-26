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

import { resourceManager } from '@kit.LocalizationKit';
import testNapi from 'libentry.so';
import Constants from '../utils/Constants';

let rawfileList: string[];
let rawfileContext: Uint8Array;
let rawfileDescriptor: resourceManager.RawFileDescriptor;

@Entry
@Component
struct Index {
  async aboutToAppear() {
    // Obtain the subdirectories and files in the rawfile directory.
    rawfileList = testNapi.getFileList(this.getUIContext().getHostContext()!.resourceManager, '');
    rawfileContext = testNapi.getRawFileContent(this.getUIContext().getHostContext()!.resourceManager, 'rawfile.txt');
    rawfileDescriptor = testNapi.getRawFileDescriptor(this.getUIContext().getHostContext()!.resourceManager, 'rawfile.txt');
  }

  build() {
    Row() {
      Column() {
        Text('getFileList = ' + rawfileList)
          .fontSize($r('app.string.font_size'))
          .id('get_file_list')
          .alignSelf(ItemAlign.Start)
        Text('getRawFileContent = ' + rawfileContext)
          .fontSize($r('app.string.font_size'))
          .id('get_raw_file_content')
          .alignSelf(ItemAlign.Start)
        Text('rawfileDescriptor.fd = ' + rawfileDescriptor.fd)
          .fontSize($r('app.string.font_size'))
          .alignSelf(ItemAlign.Start)
        Text('rawfileDescriptor.offset = ' + rawfileDescriptor.offset)
          .fontSize($r('app.string.font_size'))
          .alignSelf(ItemAlign.Start)
        Text('rawfileDescriptor.length = ' + rawfileDescriptor.length)
          .fontSize($r('app.string.font_size'))
          .id('length')
          .alignSelf(ItemAlign.Start)
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .padding($r('app.string.padding'))
    }
    .height(Constants.FULL_PERCENT)
  }
}