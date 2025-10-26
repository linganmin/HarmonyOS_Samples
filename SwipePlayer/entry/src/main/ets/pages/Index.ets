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

import { common } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { SwipePlayer, SwipePlayerController, SwipePlayerIDataSource } from '@hadss/swipeplayer';
import { CommonConstant } from '../constant/CommonConstant';
import { TabButton } from '../screen/TabButton';
import { TopTabButton } from '../screen/TopTabButton';
import { advertBuilder } from '../screen/Advert';
import { viewScreen } from '../screen/ViewScreenComponent';
import { VideoData } from '../model/CommonModel';
import { fullScreen } from '../screen/FullScreenComponent';
import { Service } from '../model/CommonUtils';

@Entry
@Component
struct Index {
  @State panDirection: PanDirection = PanDirection.Down;
  @State offsetY: number = 0;
  @StorageLink('isTabShow') isTabShow: boolean = true;
  @StorageLink('displayWidth') displayWidth: number = 0;
  @StorageLink('displayHeight') displayHeight: number = 0;
  @StorageLink('isSelected') isSelected: number = 1;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  swipePlayerController: SwipePlayerController = new SwipePlayerController();
  dataSources: SwipePlayerIDataSource = new SwipePlayerIDataSource();
  private playerData: VideoData[] = Service.getInstance().getData(this.getUIContext());
  private windowSizeChange = (size: window.Size) => {
    this.displayWidth = this.getUIContext().px2vp(size.width);
    this.displayHeight = this.getUIContext().px2vp(size.height);
  };

  aboutToAppear(): void {
    this.isTabShow = true;
    this.dataSources.pushData(this.playerData);
    AppStorage.setOrCreate('controller', this.swipePlayerController);
    AppStorage.setOrCreate('dataSources', this.dataSources);
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let window = context.windowStage.getMainWindowSync();
    window.on('windowSizeChange', this.windowSizeChange);
    display.getAllDisplays((_err: BusinessError, data: Array<display.Display>) => {
      this.displayWidth = this.getUIContext().px2vp(data[0].width);
      this.displayHeight = this.getUIContext().px2vp(data[0].height);
    });
  }

  onBackPress(): boolean | void {
    return this.swipePlayerController.backPressListener().onBackPress();
  }

  refreshText(): string {
    if (this.offsetY > CommonConstant.REFRESH_OFFSET[1]) {
      return CommonConstant.getReleaseRefresh(this.getUIContext());;
    } else {
      return CommonConstant.getRefresh(this.getUIContext());
    }
  }

  build() {
    Column() {
      TopTabButton()
        .zIndex(CommonConstant.Z_INDEX_LEVER_3)
        .position({ top: this.getUIContext().px2vp(this.topRectHeight) })
        .visibility(this.isTabShow ? Visibility.Visible : Visibility.Hidden);

      Text(this.refreshText())
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.REFRESH_HEIGHT)
        .zIndex(CommonConstant.Z_INDEX_LEVER_3)
        .fontColor(CommonConstant.CUSTOM_FONT_COLOR)
        .textAlign(TextAlign.Center)
        .visibility(this.offsetY < CommonConstant.REFRESH_OFFSET[0] ? Visibility.None : Visibility.Visible)
        .position({ y: CommonConstant.REFRESH_OFFSET[0] });

      SwipePlayer({
        datasource: this.dataSources,
        swipePlayerController: this.swipePlayerController,
        options: {
          videoPlayer: {
            playIcon: CommonConstant.VIDEO_FILL_PLAY,
          },
          swiperCallback: {
            onAnimationStart: (targetIndex: number) => {
              let totalNum = this.dataSources.totalCount();
              if (totalNum - targetIndex <= 5) {
                this.dataSources.pushData(this.playerData);
              }
            },
            onChange: (index: number) => {
              if (index === 0 || !index) {
                this.panDirection = PanDirection.Down;
              } else {
                this.panDirection = PanDirection.None;
              }
              this.isSelected = 1;
            }
          },
          viewBuilder: (type: string, isFullScreen?: boolean) => {
            if (type === 'video' && isFullScreen) {
              return fullScreen;
            } else if (type === 'video' && !isFullScreen) {
              return viewScreen;
            } else {
              return advertBuilder;
            }
          }
        }
      })
        .parallelGesture(
          PanGesture({ fingers: 1, direction: this.panDirection })
            .onActionUpdate((event: GestureEvent) => {
              if (event.offsetY < 0) {
                this.offsetY = 0;
              } else {
                this.offsetY = event.offsetY;
              }
            })
            .onActionEnd(() => {
              if (this.offsetY > 200) {
                this.dataSources.reloadData(this.playerData.reverse());
              }
              this.offsetY = 0;
            })
        );
      TabButton()
        .position({ bottom: 0 })
        .padding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
        .visibility(this.isTabShow ? Visibility.Visible : Visibility.Hidden);
    }
    .width(CommonConstant.FULL_PERCENT_WIDTH)
    .height(CommonConstant.FULL_PERCENT_HEIGHT);
  }
}


