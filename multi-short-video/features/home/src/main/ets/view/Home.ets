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

import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BreakpointConstants } from '@ohos/commons';
import { HomeConstants } from '../constants/HomeConstants';

@Component
struct VideoIntro {
  build() {
    Row() {
      Column() {
        Text($r('app.string.Up'))
          .width($r('app.float.width_large'))
          .height($r('app.float.height_middle'))
          .fontSize($r('app.float.font_size_middle'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_middle') })
        Text($r('app.string.intro'))
          .width($r('app.float.width_ultra'))
          .height($r('app.float.height_plus'))
          .fontColor(Color.White)
          .fontSize($r('app.float.font_size_small'))
      }
      .width(HomeConstants.FULL_SIZE)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .margin({ left: $r('app.float.margin') })
    }
    .height(HomeConstants.FULL_SIZE)
  }
}

@Component
struct VideoInter {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  build() {
    Row() {
      Column() {
        Image($rawfile('image.png'))
          .height($r('app.float.height_plus'))
          .margin({ bottom: $r('app.float.bottom_middle') })

        Image($rawfile('like.png'))
          .height($r('app.float.height_large'))
          .margin({ bottom: $r('app.float.bottom_small') })
        Text($r('app.string.like_number'))
          .height($r('app.float.height_small'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_middle') })

        Image($rawfile('comment.png'))
          .height($r('app.float.height_large'))
          .margin({ bottom: $r('app.float.bottom_small') })
        Text($r('app.string.comment_number'))
          .height($r('app.float.height_small'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_middle') })

        Image($rawfile('share.png'))
          .height($r('app.float.height_large'))
          .margin({ bottom: $r('app.float.bottom_small') })
          .onClick((event) => {
            let data: systemShare.SharedData = new systemShare.SharedData({
              utd: utd.UniformDataType.PLAIN_TEXT,
              content: 'this video\'s uri'
            });
            let controller: systemShare.ShareController = new systemShare.ShareController(data);
            let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
            if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
              controller.show(context, {
                anchor: {
                  windowOffset: {
                    x: this.getUIContext().vp2px(event.windowX - HomeConstants.HALF_WINDOW),
                    y: this.getUIContext().vp2px(event.windowY - HomeConstants.HALF_WINDOW)
                  },
                  size: {width: this.getUIContext().vp2px(HomeConstants.FULL_WINDOW), height:  this.getUIContext().vp2px(HomeConstants.FULL_WINDOW)}
                }
              })
            } else {
              controller.show(context, {
                previewMode: systemShare.SharePreviewMode.DETAIL,
                selectionMode: systemShare.SelectionMode.SINGLE
              });
            }
          })
        Text($r('app.string.share_number'))
          .height($r('app.float.height_small'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_middle') })
      }
      .width(HomeConstants.FULL_SIZE)
    }
    .height(HomeConstants.FULL_SIZE)
  }
}

@Component
export struct Home {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State videoSrc: Resource = $rawfile('ggg11.mp4');
  @State arr: Array<string> = HomeConstants.tab;
  controller: VideoController = new VideoController();
  @State curIndex: number = 0;

  @Builder tabBuilder(index: number) {
    Column() {
      if (index === 2) {
        Image($rawfile('add.png'))
          .width($r('app.float.width_small'))
          .margin({ bottom: $r('app.float.bottom_large') })
      } else {
        Text(this.arr[index])
          .width($r('app.float.width_small'))
          .fontSize($r('app.float.font_size_middle'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_large') })
      }
    }
    .width(HomeConstants.FULL_SIZE)
    .height($r('app.float.height_ultra'))
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Row() {
      Stack() {
        Video({
          src: $rawfile('ggg11.mp4'),
          currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X,
          controller: this.controller
        })
          .height(HomeConstants.FULL_SIZE)
          .autoPlay(true)
          .controls(false)
          .objectFit(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? ImageFit.Cover : ImageFit.Contain)

        Column() {
          if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
            SideBarContainer(SideBarContainerType.Embed) {
              Column() {
                Column()
                  .height(HomeConstants.TWENTY_SIZE)
                Column() {
                  ForEach(this.arr, (item: string) => {
                    Column() {
                      if (item === this.arr[2]) {
                        Image($rawfile('add.png'))
                          .width($r('app.float.width_middle'))
                      } else {
                        Text(item)
                          .fontSize($r('app.float.font_size_middle'))
                          .fontColor(Color.White)
                      }
                    }
                    .height(HomeConstants.FIFTEEN_SIZE)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      this.curIndex = this.arr.indexOf(item);
                    })
                  }, (item: string) => JSON.stringify(item))
                }
                .width(HomeConstants.FULL_SIZE)
                .height(HomeConstants.SIXTY_SIZE)
                .justifyContent(FlexAlign.Center)
                Column()
                  .height(HomeConstants.TWENTY_SIZE)
              }
              .width(HomeConstants.FULL_SIZE)
              .height(HomeConstants.FULL_SIZE)

              Row() {
                if (this.curIndex == 0) {
                  VideoIntro()
                    .width(HomeConstants.EIGHTY_SIZE)
                    .height(HomeConstants.TWENTY_SIZE)
                  VideoInter()
                    .width(HomeConstants.TWENTY_SIZE)
                    .height(HomeConstants.FOURTH_SIZE)
                }
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({ bottom: HomeConstants.FIFTH_SIZE })
            }
            .sideBarWidth(HomeConstants.FIFTEEN_SIZE)
          } else {
            Tabs({ barPosition: BarPosition.End }) {
              TabContent() {
                Column() {
                  Row() {
                    VideoIntro()
                      .width(HomeConstants.EIGHTY_SIZE)
                      .height(HomeConstants.TWENTY_SIZE)
                    VideoInter()
                      .width(HomeConstants.TWENTY_SIZE)
                      .height(HomeConstants.FOURTH_SIZE)

                  }
                  .height(HomeConstants.FULL_SIZE)
                  .alignItems(VerticalAlign.Bottom)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width(HomeConstants.FULL_SIZE)
              }.tabBar(this.tabBuilder(0))

              TabContent() {
              }.tabBar(this.tabBuilder(1))

              TabContent() {
              }.tabBar(this.tabBuilder(2))

              TabContent() {
              }.tabBar(this.tabBuilder(3))

              TabContent() {
              }.tabBar(this.tabBuilder(4))
            }
            .height(HomeConstants.FULL_SIZE)
          }
        }
        .width(HomeConstants.FULL_SIZE)
      }
      .width(HomeConstants.FULL_SIZE)
    }
    .height(HomeConstants.FULL_SIZE)
  }
}