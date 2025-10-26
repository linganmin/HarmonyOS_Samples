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

import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { VideoSizeData } from '../model/VideoSizeData';
import { timeConvert } from '../common/utils/TimeUtils';
import { PhotoUtils } from '../common/utils/PhotoUtils';

const TAG: string = 'INDEX';

@Entry
@Component
struct Index {
  @State currentTime: number = 0;
  @State isChoose: boolean = false;
  @State videoSize: VideoSizeData = new VideoSizeData();
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State avImageGenerator: media.AVImageGenerator | undefined = undefined;
  private photoUtils: PhotoUtils = new PhotoUtils();
  private fileAlbum: fileIo.File | undefined = undefined;
  private avFileDescriptor: media.AVFileDescriptor | undefined = undefined;

  aboutToDisappear(): void {
    this.avImageGenerator?.release().catch((error: BusinessError)=>{
      hilog.error(0x0000, TAG, `release catch error, code: ${error.code}, message: ${error.message}`);
    });
  }
  // [Start fetch_Frame_ByTime]
  /**
   * Obtain a frame at a certain point in time of the video.
   * @param time A certain point in time of the video.
   */
  async fetchFrameByTime(time: number) {
    this.pixelMap = await this.avImageGenerator?.fetchFrameByTime(time,
      media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC, this.videoSize.photoSize).catch((error: BusinessError)=>{
      hilog.error(0x0000, TAG, `release catch error, code: ${error.code}, message: ${error.message}`);
      return undefined;
    });
  }
  // [End fetch_Frame_ByTime]
  /**
   * Pull up the gallery picker to obtain the default thumbnail of the selected video.
   */
  async photoPickerGetThumbnail() {
    try {
      this.photoUtils.selectVideo().then(async (result: string) => {
        if (result === '') {
          return;
        }
        this.isChoose = false;
        let thumbnailView = await this.photoUtils.acquireThumbnailByUrl(result);
        if (thumbnailView !== undefined) {
          this.pixelMap = thumbnailView;
        } else {
          hilog.error(0x0000, TAG, `the pixelMap acquires is undefined!`);
        }
      })
    } catch (error) {
      hilog.error(0x0000, TAG, `PhotoViewPicker failed!, error: ${JSON.stringify(error)}`);
    }
  }
  // [Start image_Generator_Get_Thumbnail]
  /**
   * Obtain video resources through AVImageGenerator.
   */
  async imageGeneratorGetThumbnail() {
    this.photoUtils.selectVideo().then(async (result: string) => {
      // [StartExclude image_Generator_Get_Thumbnail]
      if (result === '') {
        return;
      }
      this.isChoose = true;
      this.currentTime = 0;
      if (this.avImageGenerator) {
        await this.avImageGenerator.release();
      }
      // [EndExclude image_Generator_Get_Thumbnail]
      this.fileAlbum = fileIo.openSync(result, fileIo.OpenMode.READ_ONLY);
      this.avFileDescriptor = { fd: this.fileAlbum.fd };
      // [StartExclude image_Generator_Get_Thumbnail]
      this.videoSize = await this.photoUtils.getVideoData(this.avFileDescriptor);
      // [Start avImage_Generator]
      this.avImageGenerator = await media.createAVImageGenerator();
      if (this.avImageGenerator) {
        this.avImageGenerator.fdSrc = this.avFileDescriptor;
      } else {
        hilog.error(0X0000, TAG, 'Create AVImageGenerator failed!');
        return;
      }
      // [End avImage_Generator]
      this.fetchFrameByTime(0);
      // [EndExclude image_Generator_Get_Thumbnail]
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Invoke imageGeneratorGetThumbnail failed!, error code: ${error.code}, message: ${error.message}`);
    })
  }
  // [End image_Generator_Get_Thumbnail]

  build() {
    Column() {
      Column() {
        Text($r('app.string.EntryAbility_label'))
          .fontSize('30fp')
          .fontWeight(700)
          .margin({ top: '64vp' })
      }
      .width('100%')
      .height('20%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        Stack({ alignContent: Alignment.Bottom }) {
          Image(this.pixelMap)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height('70%')
        .backgroundColor(Color.White)
        .padding({
          left: '12vp',
          right: '12vp',
          top: '12vp',
          bottom: '12vp'
        })
        .margin({ bottom: '16vp' })
        .borderRadius($r('sys.float.corner_radius_level8'))

        Row() {
          Text(timeConvert(this.currentTime))
            .fontWeight(FontWeight.Regular)

          Slider({
            value: this.currentTime,
            min: 0,
            max: this.videoSize.totalTime,
            style: SliderStyle.OutSet
          })
            .width('80%')
            .blockColor(Color.White)
            .trackColor(0xE5E5E5)
            .selectedColor(Color.Blue)
            .showTips(false)
            .onChange(async (value: number, mode: SliderChangeMode) => {
              this.currentTime = value;
              if (mode === SliderChangeMode.End) {
                // second trans to millisecond.
                this.fetchFrameByTime(value * 1000);
                if (this.fileAlbum) {
                  fileIo.close(this.fileAlbum);
                }
              }
            })

          Text(timeConvert(this.videoSize.totalTime))
            .fontWeight(FontWeight.Regular)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height('20vp')
        .margin({ bottom: '16vp' })
        .visibility(this.isChoose ? Visibility.Visible : Visibility.Hidden)


        Button($r('app.string.show_thumbnail'))
          .width('100%')
          .onClick(() => {
            this.photoPickerGetThumbnail();
          })

        Button($r('app.string.specify_thumbnail'))
          .width('100%')
          .onClick(() => {
            this.imageGeneratorGetThumbnail();
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('80%')
    }
    .width('100%')
    .height('100%')
    .padding({
      left: '16vp',
      right: '16vp',
      bottom: '16vp'
    })
    .backgroundColor(0XF1F3F5)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}