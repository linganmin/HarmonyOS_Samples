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
import { promptAction, window } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { CommonConstants, VideoDataType } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import { VideoDataModel } from '../model/VideoDataModel';
import VideoItem from '../view/VideoItem';
import { BufferBarPlayer } from './BufferBarPlayer';
import { UrlPlayer } from './UrlPlayer';


const TAG = '[Index]';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Provide('systemStatusAreaHeight') systemStatusAreaHeight: number = 0;
  @State url: string = CommonConstants.DEFAULT_URL;
  private videoDataList: VideoDataModel[] = VideoDataModel.getVideoDataList();
  private dialogController: promptAction.DialogController = new promptAction.DialogController();
  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();

  aboutToAppear(): void {
    let area = this.windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    this.systemStatusAreaHeight = area.topRect.height;
    this.windowClass.on('avoidAreaChange', (opts) => {
      if (opts.type == window.AvoidAreaType.TYPE_SYSTEM) {
        this.systemStatusAreaHeight = opts.area.topRect.height;
      }
    });
    let sysBarProps: window.SystemBarProperties = {
      statusBarContentColor: Color.White.toString()
    };
    this.windowClass.setWindowSystemBarProperties(sysBarProps);
  }

  aboutToDisappear(): void {
    this.windowClass.off('avoidAreaChange');
  }

  @Builder
  PagesMap(name: string) {
    if (name === 'BufferBarPlayer') {
      BufferBarPlayer();
    } else if (name === 'UrlPlayer') {
      UrlPlayer();
    }
  }

  @Builder
  customDialog() {
    Column() {
      TextArea({
        placeholder: $r('app.string.custom_url_placeholder'),
        text: $$this.url
      })
        .backgroundColor('#0dffffff')
        .fontColor($r('app.color.dialog_text_color'))
        .height(100)
        .heightAdaptivePolicy(TextHeightAdaptivePolicy.LAYOUT_CONSTRAINT_FIRST)
        .width('95%')

      Row() {
        Button($r('app.string.custom_url_dialog_cancel'))
          .backgroundColor($r('app.color.record_button_background_inactive_color'))
          .fontColor($r('app.color.player_button_color'))
          .onClick(() => {
            this.dialogController.close();
          })

        Button($r('app.string.custom_url_dialog_submit'))
          .backgroundColor($r('app.color.record_button_background_inactive_color'))
          .fontColor($r('app.color.player_button_color'))
          .onClick(() => {
            // check url
            let regex: RegExp = new RegExp('^(http|https)', 'i');
            let bool = regex.test(this.url);

            if (!bool) {
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.url_warn'),
                  duration: 2000,
                });
              } catch (err) {
                hilog.error(CommonConstants.LOG_DOMAIN, TAG, TAG,
                  `context.getPromptAction().showToast() failed, err: code is ${err.code}, message is ${err.message}`)
              }
              return;
            }
            let videoData: VideoData = {
              name: $r('app.string.video_name_custom_url'),
              type: VideoDataType.URL,
              videoSrc: this.url,
              description: '',
              caption: '',
              index: 0
            };
            this.pageStack.pushPathByName('UrlPlayer', videoData);
            this.dialogController.close();
          })
      }
      .margin({ top: 20 })
      .width('80%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding({
      top: 15,
      bottom: 15,
      left: 5,
      right: 5
    })
    .backgroundColor($r('app.color.dialog_background_color'))
    .width(352)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('AVPlayer')
        .fontSize(24)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
    }
    .padding({ top: `${this.systemStatusAreaHeight}px` })
    .height('100%')
    .width('100%')
  }

  @Builder
  menuBuilder() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.worldclock'))
          .fontSize(24)
          .fontColor([Color.White])
      }
      .height(40)
      .width(40)
      .padding(8)
      .backgroundColor($r('app.color.record_button_background_inactive_color'))
      .margin({ left: 10, right: 10 })
      .onClick(() => {
        this.url = CommonConstants.DEFAULT_URL;
        try {
          this.getUIContext()
            .getPromptAction()
            .presentCustomDialog(() => {
              this.customDialog()
            },
              this.dialogController,
              {
                isModal: true,
                autoCancel: false,
                maskColor: $r('app.color.modal_back_color'),
                cornerRadius: 24,
                width: 350,
                borderColor: $r('app.color.dialog_background_color'),
                backgroundColor: $r('app.color.dialog_background_color')
              }
            )
        } catch (err) {
          hilog.error(CommonConstants.LOG_DOMAIN, TAG, TAG,
            `context.getPromptAction().presentCustomDialog() failed, code is ${err.code}, message is ${err.message}`)
        }
      })
    }
    .padding({ top: `${this.systemStatusAreaHeight}px` })
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  build() {
    Navigation(this.pageStack) {
      Row() {
        Column() {
          List({ space: 10 }) {
            ForEach(this.videoDataList, (videoData: VideoDataModel) => {
              VideoItem({
                videoData: videoData,
                navDesName: videoData.navDesName
              })
            }, (item: VideoDataModel, index: number) => index + '_' + JSON.stringify(item))
          }
          .width(CommonConstants.FULL_SIZE)
          .height(CommonConstants.FULL_SIZE)
        }
        .justifyContent(FlexAlign.Start)
        .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
        .width(CommonConstants.FULL_SIZE)
        .height(CommonConstants.FULL_SIZE)
      }
      .height(CommonConstants.FULL_SIZE)
    }
    .title({ builder: this.titleBuilder(), height: 90 })
    .menus(this.menuBuilder())
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
    .backgroundColor('#1a1a1a')
  }
}
