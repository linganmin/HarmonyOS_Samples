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

import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants, VideoDataType } from '../common/constants/CommonConstants';
import { ImageUtil } from '../common/utils/ImageUtil';
import { VideoData } from '../model/VideoData';

const TAG = '[VideoItem]';

@Component
export default struct VideoItem {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop videoData: VideoData;
  @Prop navDesName: string;
  @State videoCover: image.PixelMap | Resource = {} as image.PixelMap;
  private rsMgr = this.getUIContext().getHostContext()?.resourceManager

  async aboutToAppear(): Promise<void> {
    if (!this.rsMgr) {
      return;
    }
    try {
      if (this.videoData.videoSrc && this.videoData.type === VideoDataType.RAW_FILE) {
        let avFd = await this.rsMgr.getRawFd(this.videoData.videoSrc);
        this.videoCover = await ImageUtil.getVideoFirstFrame(avFd);
      } else if (this.videoData.head) {
        this.videoCover = await ImageUtil.getPixmapFromMedia(this.videoData.head);
      }
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `call aboutToAppear failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  build() {

    Row() {
      Image(this.videoCover)
        .height('100%')
        .width(120)
        .objectFit(ImageFit.Fill)
        .borderRadius(16)

      Text(this.videoData?.name)
        .fontColor(Color.White)
        .fontSize(16)
        .margin({ left: 10 })
    }
    .height(80)
    .width('100%')
    .onClick(async () => {
      this.pageStack.pushPathByName(this.navDesName, this.videoData);
    })

  }
}