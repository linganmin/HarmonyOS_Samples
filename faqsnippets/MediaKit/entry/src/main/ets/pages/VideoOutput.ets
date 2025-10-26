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

import { camera } from '@kit.CameraKit';
import { media } from '@kit.MediaKit';

@Component
struct VideoOutput {
  @State message: string = 'Hello World';

  // [Start AVRecorderProfile]
  async getVideoOutput(cameraManager: camera.CameraManager, videoSurfaceId: string,
    cameraOutputCapability: camera.CameraOutputCapability): Promise<camera.VideoOutput | undefined> {
    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCapability.videoProfiles;
    if (!videoProfilesArray) {
      console.error(`createOutput videoProfilesArray === null || undefined`);
      return undefined;
    }
    let aVRecorderProfile: media.AVRecorderProfile = {
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      // 视频比特率
      videoBitrate: 100000,
      videoCodec: media.CodecMimeType.VIDEO_AVC,
      // 视频分辨率的宽
      videoFrameWidth: 640,
      // 视频分辨率的高
      videoFrameHeight: 480,
      // 视频帧率
      videoFrameRate: 30
    };
    let avRecorderConfig: media.AVRecorderConfig = {
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: aVRecorderProfile,
      url: 'fd://35',
      rotation: 90
    };
    // createVideoOutput传入的videoProfile对象的宽高需要和aVRecorderProfile保持一致
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.size.width === aVRecorderProfile.videoFrameWidth &&
        profile.size.height === aVRecorderProfile.videoFrameHeight;
    });
    let videoOutput = cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    return videoOutput;
  }

  // [End AVRecorderProfile]

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