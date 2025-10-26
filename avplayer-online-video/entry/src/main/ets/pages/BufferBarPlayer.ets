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

import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CommonConstants } from '../common/constants/CommonConstants';
import { AvPlayerController } from '../controller/AvPlayerController';
import { VideoData } from '../model/VideoData';
import { BasicVideoPlayer } from '../view/BasicVideoPlayer';

@Component
export struct BufferBarPlayer {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop private videoData: VideoData;
  @State durationTime: number = 0;
  @State private avPlayerController: AvPlayerController = new AvPlayerController();
  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();


  // [Start cache_bar_4]
  @Builder
  progressBuilder() {
    Stack() {
      Slider({
        value: this.avPlayerController.currentTime,
        min: CommonConstants.SLIDER_PROGRESS_MIN,
        max: this.avPlayerController.durationTime,
        step: CommonConstants.SLIDER_PROGRESS_STEP,
        direction: Axis.Horizontal
      })
        .blockColor(Color.White)
        .trackColor($r('app.color.track_color_show'))
        .selectedColor($r('app.color.slider_selected'))
        .trackThickness(5)
        .zIndex(1)
        .onChange((value: number) => {
          this.avPlayerController.videoSeek(value);
        })

      Slider({
        value: this.avPlayerController.currentBufferTime,
        min: CommonConstants.SLIDER_PROGRESS_MIN,
        max: this.avPlayerController.durationTime,
        step: CommonConstants.SLIDER_PROGRESS_STEP,
        direction: Axis.Horizontal,
        style: SliderStyle.NONE
      })
        .trackColor(Color.Grey)
        .selectedColor(Color.White)
        .blockColor($r('app.color.track_color_show'))
        .trackThickness(5)
        .margin({ left: 12, right: 12 })
        .zIndex(0)
    }
    .layoutWeight(1)
  }

  // [End cache_bar_4]

  build() {
    NavDestination() {
      Column() {
        BasicVideoPlayer({
          avPlayerController: this.avPlayerController,
          videoData: this.videoData,
          progressBuilder: ()=>{this.progressBuilder()},
        })
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
    .hideBackButton(true)
    .hideToolBar(true)
    .onReady((context: NavDestinationContext) => {
      let param: VideoData = context.pathInfo.param as VideoData;
      this.videoData = param;
    })


  }
}
