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

import { display } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVPlayerState, Constants, VideoDataType } from '../common/constants/Constants';
import { VideoInfo } from '../model/VideoInfo';
import { AppRouter } from '../common/utils/AppRouter';
import { VideoParams } from '../model/VideoParams';
import { VideoDataSource } from '../model/VideoDataSource';
import { AvPlayerController } from '../controller/AvPlayerController';

const TAG = 'VideoList';

@Component
export struct VideoList {
  @State playIdx: number = 0;
  @State pullRadio: number = 1.0;
  @State isMuted: boolean = true;
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State xWidth: number | string = '100%';
  @State xHeight: number | string = '100%';
  @StorageLink('CurrentTime') currentTime: number = 0;
  @StorageLink('DurationTime') durationTime: number = 0;
  @StorageLink('StartRender') startRender: boolean = false;
  @Prop @Watch('onPageShowChange') isShow: boolean = true;
  private unloadID?: string;
  private init: boolean = true;
  private curIndex: number = 0;
  private frameWidth: number = 0;
  private frameHeight: number = 0;
  private listItemHeight: number = 0;
  private offsetting: boolean = false;
  private listScroller: ListScroller = new ListScroller();
  private dataSource: VideoDataSource = new VideoDataSource();
  private windowClass = AppStorage.get('windowClass') as window.Window;
  // [Start av_player]
  private avPlayerController: AvPlayerController = new AvPlayerController();

  // [End av_player]
  // [Start set_component_size]
  /*
   * Calculate XComponent Width&Height
   */
  setXComponentWH(vWidth: number, vHeight: number) {
    let radio = vWidth / vHeight;
    if (radio > 1) {
      // Horizontal video
      this.xWidth = this.frameWidth;
      this.xHeight = Math.floor(this.xWidth / radio);
      if (this.xHeight > this.frameHeight) {
        this.xHeight = this.frameHeight;
        this.xWidth = Math.floor(this.xHeight * radio);
      }
    } else {
      // Vertical video
      this.xHeight = this.frameHeight;
      this.xWidth = Math.floor(this.xHeight * radio);
      if (this.xWidth > this.frameWidth) {
        this.xWidth = this.frameWidth;
        this.xHeight = Math.floor(this.xWidth / radio);
      }
    }
  }

  // [End set_component_size]

  onPageShowChange() {
    if (this.avPlayerController && AppRouter.getPageIndex() === -1) {
      if (this.isShow) {
        if (this.avPlayerController.getVideoState() === AVPlayerState.PAUSED) {
          this.avPlayerController.videoPlay();
        }
      } else {
        if (this.avPlayerController.getVideoState() === AVPlayerState.PLAYING) {
          this.avPlayerController.videoPause();
        }
      }
    }
  }

  // [Start play]
  play(index: number) {
    this.startRender = false;
    // Reset AVPlayer
    this.avPlayerController.videoReset().then(() => {
      // [StartExclude play]
      if (index !== this.playIdx) {
        this.dataSource.getData(this.playIdx).stopTime = this.currentTime;
        this.playIdx = index;
      }
      if (this.dataSource.getData(index).surfaceID !== undefined) {
        this.unloadID = undefined;
        // Get video data params
        if (index === this.playIdx) {
          let stopTime = this.dataSource.getData(index).stopTime!;
          this.currentTime = stopTime;
          let surfaceID = this.dataSource.getData(index).xController!.getXComponentSurfaceId();
          // [EndExclude  play]
          this.isMuted = true;
          // Init AVPlayer
          this.avPlayerController.initAVPlayer({
            type: VideoDataType.RAW_FILE,
            videoSrc: this.dataSource.getData(index).src!,
            name: $r("app.string.app_name"),
            description: '',
            caption: '',
            index: 0,
            seekTime: stopTime,
            isMuted: true,
            head: $r("app.media.preview1")
          }, surfaceID);
          // [StartExclude play]
        }
      } else {
        this.unloadID = this.dataSource.getData(index).id;
      }
      // [EndExclude  play]
    });
  }

  // [End play]
  @Builder
  loadingBuilder() {
    Row() {
      LoadingProgress()
        .width(48)
        .height(32)
    }
    .height(Constants.FOOTER_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (!isExpanding && currentRatio <= 0.0 && this.init) {
        this.init = false;
        this.play(0);
      }
      if (!isExpanding && currentRatio <= 0.0 && this.offsetting) {
        this.offsetting = false;
        this.play(0);
      }
    })
  }

  @Builder
  sliderBuilder() {
    // [Start slider]
    Slider({
      min: 0,
      max: this.durationTime,
      value: this.currentTime,
      style: SliderStyle.NONE,
      direction: Axis.Horizontal
    })
    // [End slider]
      .height(2)
      .width('100%')
      .trackThickness(2)
      .align(Alignment.End)
      .blockColor(Color.Transparent)
      .trackColor(Color.Transparent)
      .padding({ left: Constants.SLIDER_PADDING, right: Constants.SLIDER_PADDING })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      })
      .visibility(this.avPlayerController.getVideoState() === AVPlayerState.PLAYING ? Visibility.Visible :
      Visibility.Hidden)
  }

  @Builder
  videoItemBuilder(info: VideoInfo, index: number) {
    Column() {
      Row() {
        Image($r('app.media.preview2'))
          .width(25)
          .height(25)
          .borderRadius(20)

        Text($r('app.string.user_name'))
          .fontSize(14)
          .fontWeight(500)
          .width('85%')
          .margin({ left: '15px' })
          .fontColor(Color.White)

        Image($r('app.media.chevron_down'))
          .width(20)
          .height(20)
          .opacity(0.7)

      }
      .margin({ bottom: 10 })

      Stack({ alignContent: Alignment.Top }) {
        RelativeContainer() {
          // [Start x_component]
          XComponent({
            type: XComponentType.SURFACE,
            controller: info.xController
          })
          // [End x_component]
            .borderRadius(8)
            .width(this.xWidth)
            .height(this.xHeight)
            .backgroundColor(Color.Black)
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            // [Start x_component_onLoad]
            .onLoad(() => {
              let surfaceID = info.xController!.getXComponentSurfaceId();
              info.surfaceID = surfaceID;
              if (info.id === this.unloadID) {
                this.play(index);
              }
            })
            // [End x_component_onLoad]
            .onDestroy(() => {
              info.surfaceID = undefined;
            })
            // [Start x_component_onClick]
            .onClick(() => {
              // Save video data
              AppStorage.setOrCreate(Constants.SURFACE_ID_KEY, info.surfaceID);
              this.avPlayerController.videoPause();

              info.stopTime = this.avPlayerController.currentTime;
              info.duration = this.avPlayerController.duration;
              // Jump video play detail
              AppRouter.pushByName(Constants.DETAIL_PAGE_NAME,
                new VideoParams(info, this.playIdx, index), () => {
                  let param: VideoParams = AppStorage.get("BackParam") as VideoParams;
                  let _index = param.index;
                  this.dataSource.getData(_index).stopTime = param.videoInfo.stopTime;
                  this.play(param.playIdx);
                })
            })
          // [End x_component_onClick]
          this.sliderBuilder();

          Button({ type: ButtonType.Circle, stateEffect: false }) {
            Image(this.isMuted ? $r('app.media.speaker_close') : $r('app.media.speaker_open'))
              .padding(10)
              .fillColor(Color.White)
          }
          .width(40)
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .margin({ right: 8 })
          .onClick(() => {
            // Set Muted
            this.avPlayerController.videoMuted(!this.isMuted).then(() => {
              this.isMuted = !this.isMuted;
            });
          })
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          })
        }
        .width(this.frameWidth)
        .height(this.frameHeight)
        .visibility((this.playIdx === index) ? Visibility.Visible : Visibility.Hidden)

        Column() {
          Image(info.pixelMap !== undefined ? info.pixelMap : info.preview)
            .borderRadius(8)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .visibility((this.playIdx !== index) ? Visibility.Visible :
        Visibility.Hidden)
      }
      .width('100%')
      .height(this.listItemHeight - Constants.TITLE_HEIGHT - Constants.INFO_AREA_HEIGHT -
      Constants.LIST_ITEM_TOP_PADDING)

      RelativeContainer() {
        Column() {
          Row() {
            Text($r('app.string.title'))
              .fontSize(14)
              .lineHeight(22)
              .width('100%')
              .margin({ left: '10px' })
              .fontWeight(FontWeight.Medium)
              .fontColor('#E6FFFFFF')
              .opacity(0.8)
          }

          Row() {
            Text(info.detail)
              .fontSize(14)
              .lineHeight(22)
              .fontWeight(FontWeight.Regular)
              .fontColor('#E6FFFFFF')
              .opacity(0.7)
          }
        }
      }
      .width('100%')
      .height(Constants.INFO_AREA_HEIGHT)
      .padding({ top: 5, bottom: 13 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // [Start on_did_build]
  onDidBuild(): void {
    this.dataSource.loadData();
    this.play(this.playIdx);
  }

  // [End on_did_build]

  // [Start about_to_appear]
  aboutToAppear() {
    try {
      this.windowClass.setWindowSystemBarProperties({
        // Status bar color
        statusBarColor: '#1A1A1A'
      });

      // Calculated based on screen width RelativeContainer width
      let winWidth = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
      this.frameWidth = winWidth - Constants.LIST_ITEM_LEFT_PADDING - Constants.LIST_ITEM_RIGHT_PADDING;
      this.frameHeight = Math.floor(this.frameWidth / Constants.WH_RADIO);
      this.listItemHeight =
        this.frameHeight + Constants.TITLE_HEIGHT + Constants.LIST_ITEM_TOP_PADDING + Constants.INFO_AREA_HEIGHT;
      emitter.on('prepared', (eventData: emitter.EventData) => {
        let vWidth: number = eventData.data!.width;
        let vHeight: number = eventData.data!.height;
        let surfaceID: string = eventData.data!.surfaceID;
        if (this.playIdx < this.dataSource.totalCount()) {
          let playSurfaceID = this.dataSource.getData(this.playIdx).surfaceID;
          if (playSurfaceID === surfaceID) {
            this.setXComponentWH(vWidth, vHeight);
          }
        }
      });
    } catch (error) {
      if (error.code !== null && error.message !== null) {
        hilog.error(Constants.DOMAIN, TAG, `aboutToAppear failed, code is ${error.code}, message is ${error.message}`);
      }
    }
  }

  // [End about_to_appear]

  aboutToDisappear(): void {
    emitter.off('prepared');
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // [Start list]
      List({ scroller: this.listScroller }) {
        LazyForEach(this.dataSource, (info: VideoInfo, index: number) => {
          ListItem() {
            this.videoItemBuilder(info, index)
          }
          // [StartExclude list]
          .width('100%')
          .height(this.listItemHeight)
          .backgroundColor('#1A1A1A')
          .padding({
            top: Constants.LIST_ITEM_TOP_PADDING,
            left: Constants.LIST_ITEM_LEFT_PADDING,
            right: Constants.LIST_ITEM_RIGHT_PADDING
          })
          .onClick(() => {
            // Save video data
            if (index !== this.playIdx) {
              this.avPlayerController.videoPause();
              // Jump video play detail
              AppRouter.pushByName(Constants.DETAIL_PAGE_NAME,
                new VideoParams(info, this.playIdx, index), () => {
                  let param: VideoParams = AppStorage.get('BackParam') as VideoParams;
                  let _index = param.index;
                  this.dataSource.getData(_index).stopTime = param.videoInfo.stopTime;
                  this.play(param.playIdx);
                });
            }
          })

          // [EndExclude list]
        }, (info: VideoInfo) => info.id)
      }
      // [End list]
      .width('100%')
      .height('100%')
      .friction(Constants.LIST_FRICTION)
      .scrollBarWidth(6)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .cachedCount(Constants.LIST_CACHE_COUNT)
      .alignListItem(ListItemAlign.Center)
      .backgroundColor('#000000')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .childrenMainSize(new ChildrenMainSize(this.listItemHeight))
      .divider({
        strokeWidth: Constants.LIST_DIVIDER_WIDTH,
        color: 0x02DCDCDC,
        startMargin: 0,
        endMargin: 0,
      })
      // [Start list_on_scroll_stop]
      .onScrollStop(() => {
        let yOffset = this.listScroller.currentOffset().yOffset;
        let curIndex = Math.floor(yOffset / (this.listItemHeight + Constants.LIST_DIVIDER_WIDTH));
        let offsetInItem = yOffset - curIndex * (this.listItemHeight + Constants.LIST_DIVIDER_WIDTH);
        if (offsetInItem > Constants.LIST_ITEM_TOP_PADDING + 34) {
          curIndex += 1;
        }
        this.curIndex = curIndex;
        if (curIndex !== this.playIdx && curIndex < this.dataSource.totalCount()) {
          setTimeout(() => {
            if (this.curIndex === curIndex && this.curIndex !== this.playIdx) {
              this.play(curIndex);
            }
          }, Constants.DELAY_MS);
        }
      })

      // [End list_on_scroll_stop]
      this.loadingBuilder()
    }
    .width('100%')
  }
}