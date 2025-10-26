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

import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { VideoTranscoderPage } from './VideoTranscoderPage';
import { TranscoderFinishPage } from './TranscoderFinishPage';
import { avConfigCommon } from '../utils/AVTranscoderManager';

interface resolutionCommon {
  name: Resource,
  value: string
}

// Resolution Array
const resolutionList: resolutionCommon[] = [
  { name: $r('app.string.standard_clearance'), value: '1280x720' },
  { name: $r('app.string.high_definition'), value: '1920x1080' },
  { name: $r('app.string.ultra_clear'), value: '3840x2160' },
]

// CodeRate Array
const codeRateList: string[] = ['2Mbps', '4Mbps', '6Mbps', '8Mbps', '16Mbps', '30Mbps', '50Mbps'];

@Entry
@Component
struct Index {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @State resolution: string = '1920x1080';
  @State selectedIndex: number = 1;
  @State videoFrameWidth: number = 0;
  @State videoFrameHeight: number = 0;
  controller: VideoController = new VideoController();
  private context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  @Builder
  myRouter(name: string) {
    if (name === 'VideoTranscoderPage') {
      VideoTranscoderPage();
    } else if (name === 'TranscoderFinishPage') {
      TranscoderFinishPage();
    }
  }

  @Builder
  titleBar() {
    Text($r('app.string.video_transcoder'))
      .height('32vp')
      .fontSize('26vp')
      .fontWeight(700)
      .textAlign(TextAlign.Start)
      .margin('16vp')
  }

  aboutToAppear(): void {
    this.getVideoMetaData();
  }
  onPageShow(): void {
    this.controller.start()
  }

  // Get video metadata
  async getVideoMetaData() {
    const TAG = 'MetadataDemo';
    const isSupport: boolean = canIUse('SystemCapability.Multimedia.Media.AVMetadataExtractor');
    if (isSupport) {
      try {
        // Create an AVMetadataExtractor object
        let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
        // Set up fdSrc
        avMetadataExtractor.fdSrc = await this.context.resourceManager.getRawFd('video_sample.mp4');
        // Get metadata (callback mode)
        avMetadataExtractor.fetchMetadata((error, metadata) => {
          if (error) {
            console.error(TAG, `fetchMetadata callback failed, err = ${JSON.stringify(error)}`);
            return;
          }
          console.info(TAG, `fetchMetadata callback success, genre: ${JSON.stringify(metadata)}`);
          // Initialization parameters
          this.videoFrameWidth = Number(metadata.videoWidth);
          this.videoFrameHeight = Number(metadata.videoHeight);
        })
      } catch (err) {
        hilog.error(0x0000, 'testTag', `createAVMetadataExtractor failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Start the conversion.
  onStart() {
    // Judgment logic before conversion
    const width: number = Number(this.resolution.split('x')[0]);
    console.info('this.videoFrameWidth', this.videoFrameWidth, width);
    if (this.videoFrameWidth < 3840 && width >= 3840) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.showToastWarn4k'),
          duration: 2000
        })
      } catch (err) {
        hilog.error(0x0000, 'testTag', `getUIContext failed, code is ${err.code}, message is ${err.message}`);
      }
    } else if (this.videoFrameWidth < 1920 && width >= 1920) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.showToastWarn1080'),
          duration: 2000
        })
      } catch (err) {
        hilog.error(0x0000, 'testTag', `getUIContext failed, code is ${err.code}, message is ${err.message}`);
      }
    } else if (this.videoFrameWidth < 720 && width >= 720) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.showToastWarn720'),
          duration: 2000
        })
      } catch (err) {
        hilog.error(0x0000, 'testTag', `getUIContext failed, code is ${err.code}, message is ${err.message}`);
      }
    } else {
      const codeRate: number = parseInt(codeRateList[this.selectedIndex].split('Mbps')[0]) * 1000000;
      const params: avConfigCommon = {
        resolution: this.resolution,
        codeRate
      }
      this.pathInfos.pushPathByName('VideoTranscoderPage', params);
    }
  }

  build() {
    Navigation(this.pathInfos) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        this.titleBar()
        Column() {
          Video({
            src: $rawfile('video_sample.mp4'),
            controller: this.controller,
          })
            .autoPlay(true)
            .controls(false)
            .loop(true)
        }
        .width('100%')
        .height('292vp')
        .flexShrink(0)

        Column() {
          Row() {
            Text($r('app.string.param_config'))
              .textAlign(TextAlign.Start)
              .fontWeight(400)
              .fontSize('14vp')
          }
          .margin({ top: '20vp' })
          .padding({ top: '8vp', right: '12vp', bottom: '8vp', left: '12vp' })

          Column() {
            Row() {
              Text($r('app.string.file_name'))
                .fontColor('rgba(0, 0, 0, 0.9)')
                .fontSize('16vp')
                .fontWeight(500)
              Text('video_sample.mp4')
                .fontColor('rgba(0, 0, 0, 0.6)')
                .fontSize('14vp')
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .commonStyle()

            Row() {
              Text($r('app.string.resolution'))
                .fontColor('rgba(0, 0, 0, 0.9)')
                .fontSize('16vp')
                .fontWeight(500)
              Row() {
                ForEach(resolutionList, (item: resolutionCommon, index: number) => {
                  Text(item.name)
                    .margin({ left: '16vp' })
                    .padding({ top: '4.5vp', right: '12vp', bottom: '4.5vp', left: '12vp' })
                    .backgroundColor(item.value === this.resolution ? '#0A59F7' : 'rgba(0, 0, 0, 0.05)')
                    .textAlign(TextAlign.Center)
                    .borderRadius('14vp')
                    .fontColor(item.value === this.resolution ? Color.White : 'rgba(0, 0, 0, 0.6)')
                    .onClick(() => {
                      this.resolution = item.value
                    })
                }, (item: resolutionCommon, index: number) => String(index))
              }
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .commonStyle()

            Row() {
              Text($r('app.string.code_rate'))
                .fontColor('rgba(0, 0, 0, 0.9)')
                .fontSize('16vp')
                .fontWeight(500)

              Row() {
                Text(String(codeRateList[this.selectedIndex]))
                  .fontColor('rgba(0, 0, 0, 0.9)')
                  .fontSize('14vp')
                Text() {
                  SymbolSpan($r('sys.symbol.arrowtriangle_down_fill'))
                    .fontSize('14vp')
                }
                .margin({ left: '9vp' })
              }
              .onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: codeRateList,
                  selected: this.selectedIndex,
                  defaultPickerItemHeight: 40,
                  onAccept: (value: TextPickerResult) => {
                    this.selectedIndex = Number(value.index);
                  }
                });
              })
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .commonStyle()
            .border({
              width: '0vp'
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius('16vp')
          .padding({ top: '4vp', right: '12vp', bottom: '4vp', left: '12vp' })
        }
        .padding({ left: '16vp', right: '16vp' })
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        Column() {
          Button($r('app.string.start_transfer'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.onStart()
            })
        }
        .width('100%')
        .padding('16vp')
        .flexShrink(0)
      }
      .width('100%')
      .height('100%')
    }
    .padding({ top: '36vp', bottom: '28vp' })
    .navDestination(this.myRouter)
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor('#F1F3F5')
  }

  @Styles
  commonStyle() {
    .width('100%')
    .padding({
      top: '13vp',
      right: '0vp',
      bottom: '13vp',
      left: '0vp'
    })
    .border({
      width: { bottom: '0.5vp' },
      color: 'rgba(0, 0, 0, 0.2)'
    })
  }
}