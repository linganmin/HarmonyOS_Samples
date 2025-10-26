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
* FAQ: 如何进行视频压缩
 */

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';

export class PictureUtils {
  // [Start Select_Video]
  static async selectVideo(selectNumber: number): Promise<photoAccessHelper.PhotoSelectResult> {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 设置要选择的媒体文件类型
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    // 设置选择文件最大数量
    photoSelectOptions.maxSelectNumber = selectNumber;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    // PhotoViewPicker的select方法不需要特殊权限即可读取到图片或者视频文件
    return await photoPicker.select(photoSelectOptions);
  }
  // [Start Select_Video]

  static compressVideo(outputPath: string): ArrayBuffer {
    let file = fs.openSync(outputPath, fs.OpenMode.READ_WRITE);
    let videoSize = fs.statSync(file.fd).size;
    let arrayBuffer = new ArrayBuffer(videoSize);
    fs.readSync(file.fd, arrayBuffer);
    fs.closeSync(file);
    return arrayBuffer;
  }
}