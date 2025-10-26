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
* FAQ:如何实现前置镜头的录像镜像功能
*/

// [Start video_mirror_image]
import { camera } from '@kit.CameraKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [StartExclude video_mirror_image]
// [Start is_mirror_supported]
function testIsMirrorSupported(videoOutput: camera.VideoOutput): boolean {
  let isSupported: boolean = videoOutput.isMirrorSupported();
  return isSupported;
}

// [End is_mirror_supported]
// [EndExclude video_mirror_image]

function enableMirror(videoOutput: camera.VideoOutput, mirrorMode: boolean): void {
  try {
    videoOutput.enableMirror(mirrorMode);
  } catch (error) {
    let err = error as BusinessError;
  }
}

// [End video_mirror_image]