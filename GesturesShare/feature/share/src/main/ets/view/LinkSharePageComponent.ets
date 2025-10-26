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

// [Start LinkSharePage]
import { common } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { FileData, ShareType, VIDEO_SOURCES } from '../model/FileData';
import { ShareModel } from '../model/ShareModel';
import { BreakpointConstants } from '@ohos/common';

@Component
export struct LinkSharePageComponent {
  // [StartExclude LinkSharePage]
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('GesturesShare_fileShare') fileShare: number[] = [];
  @StorageLink('GesturesShare_isShareLink') isShareLink: boolean = false;
  @StorageLink('GesturesShare_shareVideoIndex') @Watch('changeVideo') shareVideoIndex: number = 0;
  private videoController: VideoController = new VideoController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private dataList: FileData[] = VIDEO_SOURCES;
  private shareModel: ShareModel | undefined = undefined;
  // [EndExclude LinkSharePage]
  // Current playing video index.
  @State currentVideoIndex: number = 0;
  @State url: ResourceStr = $rawfile(this.dataList[this.currentVideoIndex].url);

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // [StartExclude LinkSharePage]
          Column() {
            Video({
              controller: this.videoController,
              src: this.url,
              posterOptions: { showFirstFrame: true }
            })
              .width('100%')
              .aspectRatio(16 / 9)
              .autoPlay(true)
              .controls(false)
          }
          .width('100%')
          .aspectRatio(16 / 9)
          // [EndExclude LinkSharePage]
          Column() {
            // [StartExclude LinkSharePage]
            Text($r('app.string.play_list'))
              .height(48)
              .fontWeight(FontWeight.Medium)
              .fontSize(16)
              .alignSelf(ItemAlign.Start)
            // [EndExclude LinkSharePage]
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.dataList, (item: FileData, index) => {
                  RelativeContainer() {
                    // [StartExclude LinkSharePage]
                    Text(JSON.stringify(item.index + 1))
                      .width(46)
                      .height(46)
                      .fontSize(16)
                      .textAlign(TextAlign.Center)
                    if (this.currentVideoIndex === index) {
                      SymbolGlyph($r('sys.symbol.rhythm'))
                        .fontSize(16)
                        .alignRules({
                          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                          left: { anchor: '__container__', align: HorizontalAlign.Start },
                        })
                        .fontColor(['rgba(10,89,247,0.5)'])
                        .offset({
                          x: 2,
                          y: 2
                        })
                    }
                    // [EndExclude LinkSharePage]
                  }
                  // [StartExclude LinkSharePage]
                  .width(46)
                  .height(46)
                  .borderWidth('1')
                  .backgroundColor(this.currentVideoIndex === index ? 'rgba(10,89,247,0.05)' : Color.White)
                  .borderColor(this.currentVideoIndex === index ? 'rgba(10,89,247,0.5)' : 'rgb(241,243,245)')
                  .borderRadius(8)
                  .margin({
                    right: 12
                  })
                  // [EndExclude LinkSharePage]
                  .onClick(() => {
                    this.currentVideoIndex = index;
                    this.shareModel = ShareModel.getInstance(this.context);
                    this.shareModel.setVideoIndex(this.currentVideoIndex);
                    this.videoController.reset();
                    this.url = $rawfile(item.url);
                  })
                  // [StartExclude LinkSharePage]
                }, (item: FileData, index: number) => index + JSON.stringify(item))
              }
              .width('100%')
            }
            .width('100%')
          }
          .padding(16)
        }
      }
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      // [EndExclude LinkSharePage]
    }
    // [StartExclude LinkSharePage]
    .title($r('app.string.gestures_share_link'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    // [EndExclude LinkSharePage]
    .onShown(() => {
      // [StartExclude LinkSharePage]
      if (this.isShareLink) {
        this.isShareLink = false;
        this.currentVideoIndex = this.shareVideoIndex;
        this.url = $rawfile(this.dataList[this.currentVideoIndex].url);
      }
      if (!canIUse('SystemCapability.Collaboration.SystemShare')) {
        return;
      }
      // [EndExclude LinkSharePage]
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel?.immersiveListening(ShareType.LINK_SHARE);
    })
    .onHidden(() => {
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel?.immersiveDisableListening();
    })
  }

  // [StartExclude LinkSharePage]
  changeVideo() {
    if (this.isShareLink) {
      this.isShareLink = false;
      this.currentVideoIndex = this.shareVideoIndex;
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel.setVideoIndex(this.currentVideoIndex);
      this.url = $rawfile(this.dataList[this.currentVideoIndex].url);
    }
  }
  // [EndExclude LinkSharePage]
}
// [End LinkSharePage]

@Builder
export function LinkSharePageComponentBuilder() {
  LinkSharePageComponent()
}