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

import { fileIo as fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { PictureUtils } from '../common/PictureUtils';
import { CompressorResponseCode, CompressQuality, VideoCompressor } from '@ohos/videocompressor';

const TAG = 'VideoCompressDemo';

@Component
struct VideoCompression {
  @State videoPath: string = '';
  @State buffer: ArrayBuffer | undefined = undefined;
  @State quantity: string = '';
  @State fileDir: string = '';
  @State compressedSize: number = 0;
  private videoController: VideoController = new VideoController();
  private uiContext = this.getUIContext();

  @Styles
  butStyle(){
    .width(200)
    .height(50)
    .margin({ top: 30 })
  }

  // [Start Get_Video_Path]
  // 获取视频路径
  async selectAndCompressVideo() {
    let selectResult: photoAccessHelper.PhotoSelectResult = await PictureUtils.selectVideo(1);
    // 得到选中视频的uri
    this.videoPath = selectResult.photoUris[0];
    hilog.info(0x0000, TAG, 'videoCompressor select selectFilePath:' + this.videoPath)
  }

  // [End Get_Video_Path]

  // [Start Video_Compression]
  compressVideo(quality: CompressQuality, qualityTag: string) {
    this.quantity = qualityTag;
    let videoCompressor = new VideoCompressor();
    // 调用compressVideo方法并指定相应质量进行压缩
    videoCompressor.compressVideo(this.uiContext.getHostContext()!, this.videoPath, quality)
      .then((data) => {
        if (data.code == CompressorResponseCode.SUCCESS) {
          hilog.info(0x0000, TAG,
            'videoCompressor ' + qualityTag + ' message:' + data.message + '--outputPath:' + data.outputPath);
          // 获取存在应用沙箱路径下的压缩后的视频文件，点击保存按钮后将其写入相册
          this.buffer = PictureUtils.compressVideo(data.outputPath);
          hilog.info(0x0000, TAG, `The buffer: ${JSON.stringify(this.buffer)}`);
          this.uiContext.showAlertDialog({ message: '已压缩完成，可执行下载!' });
        } else {
          hilog.info(0x0000, TAG,
            'videoCompressor ' + qualityTag + ' code:' + data.code + '--error message:' + data.message);
        }
      }).catch((err: Error) => {
      hilog.info(0x0000, TAG, 'videoCompressor ' + qualityTag + ' get error message' + err.message);
    })
  }

  // [End Video_Compression]

  fileSizeConversion(size: number) {
    if (size < 1024) {
      return size + 'B';
    } else if (size < 1024 * 1024) {
      return (size / 1024).toFixed(2) + 'KB';
    } else if (size < 1024 * 1024 * 1024) {
      return (size / 1024 / 1024).toFixed(2) + 'MB';
    } else if (size < 1024 * 1024 * 1024 * 1024) {
      return (size / 1024 / 1024 / 1024 / 1024).toFixed(2) + 'GB';
    } else {
      return size + 'B';
    }
  }

  build() {
    Column({ space: 20 }) {
      Text(this.videoPath).fontSize(18).fontWeight(FontWeight.Bold);

      Button('选择视频', { type: ButtonType.Capsule, stateEffect: false })
        .fontSize('15fp')
        .fontColor('#FFF')
        .butStyle()
        .onClick(() => {
          this.selectAndCompressVideo()
        })

      Button('高质量压缩')
        .fontSize(20)
        .height(50)
        .width('80%')
        .onClick(() => {
          this.compressVideo(CompressQuality.COMPRESS_QUALITY_HIGH, 'HIGH');
        })

      Button('中质量压缩')
        .fontSize(20)
        .height(50)
        .width('80%')
        .onClick(() => {
          this.compressVideo(CompressQuality.COMPRESS_QUALITY_MEDIUM, 'MEDIUM')
        })

      Button('低质量压缩')
        .fontSize(20)
        .height(50)
        .width('80%')
        .onClick(() => {
          this.compressVideo(CompressQuality.COMPRESS_QUALITY_LOW, 'LOW');
        })
      // 默认参数下，图标、文字、背景都存在
      Button('保存文件', { type: ButtonType.Normal })
        .onClick(async () => {
          // [Start Save_Video]
          try {
            let parentDir = this.uiContext.getHostContext()!.filesDir;
            let fileName: string = Date.now() + '-' + this.quantity + '.mp4';
            this.fileDir = parentDir + '/' + fileName;
            let file = await fs.open(this.fileDir, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            // 写入文件
            await fs.write(file.fd, this.buffer);
            this.compressedSize = (await fs.stat(file.fd)).size;
            // 关闭文件
            await fs.close(file.fd);
            this.uiContext.showAlertDialog({ message: '保存成功!' });
          } catch (error) {
            hilog.error(0x0000, TAG, 'error is' + JSON.stringify(error));
            this.uiContext.showAlertDialog({ message: '保存失败!' });
          }
          // [End Save_Video]
        })
      Text(`压缩后的大小：${this.fileSizeConversion(this.compressedSize)}`)
      Video({ src: `file://${this.fileDir}`, currentProgressRate: 1, controller: this.videoController })
        .muted(false) // 设置是否静音
        .controls(true) // 设置是否显示默认控制条
        .autoPlay(false) // 设置是否自动播放
        .loop(false) // 设置是否循环播放
        .objectFit(ImageFit.Contain) // 设置视频适配模式
        .height(200)
        .width('100%')
        .visibility(this.fileDir === '' ? Visibility.None : Visibility.Visible)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}