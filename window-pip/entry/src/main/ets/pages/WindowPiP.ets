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

import { Constants } from '../constants/Constants';
import { PlayVideo } from './VideoPlay';
import Logger from '../utils/Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let UIContext = uiContext!.getHostContext()!;

@Component
struct ImageWidthTitle {
  @State imageHeight: number = 0;
  @Link pageInfos: NavPathStack;
  public titleResource?: Resource;

  build() {
    Column({ space: Constants.HOME_SPACE }) {
      Image($r('app.media.btn_ground'))
        .width(Constants.NAV_DESTINATION_HEIGHT)
        .height(this.imageHeight)
        .borderRadius($r('app.integer.video_button_board_radius'))
        .objectFit(ImageFit.Cover)
        .draggable(false)
      Text(this.titleResource)
        .fontSize($r('app.integer.text_size'))
    }
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      UIContext.eventHub.emit('onStateChange', true);
      this.pageInfos?.pushPath({ name: Constants.NAV_DESTINATION_NAME }, { launchMode: 3 });
    })
    .onAreaChange((oldArea: Area, newArea: Area) => {
      let width = newArea.width as number;
      this.imageHeight = width * 9 / 16;
      Logger.info(`[onAreaChange] oldArea：${oldArea} ,newArea：${newArea}`);
    })
  }
}

@Entry
@Component
struct WindowPiP {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @State curState: string = '';
  private navigationId: string = 'navId';

  @Builder
  PageMap(name: string) {
    if (name === Constants.NAV_DESTINATION_NAME) {
      PlayVideo({ navigationId: this.navigationId })
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Scroll() {
        Column() {
          ImageWidthTitle({ titleResource: $r('app.string.video1'), pageInfos: this.pageInfos })
          Blank()
            .height($r('app.integer.scroll_height'))
          GridRow({
            columns: Constants.GRID_ROW_COLUMNS,
            gutter: { x: Constants.GRID_ROW_X, y: Constants.GRID_ROW_Y }
          }) {
            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video2'), pageInfos: this.pageInfos })
            }

            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video3'), pageInfos: this.pageInfos })
            }

            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video4'), pageInfos: this.pageInfos })
            }

            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video5'), pageInfos: this.pageInfos })
            }

            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video6'), pageInfos: this.pageInfos })
            }

            GridCol() {
              ImageWidthTitle({ titleResource: $r('app.string.video7'), pageInfos: this.pageInfos })
            }
          }
          .width(Constants.NAV_DESTINATION_WIDTH)
        }
        .justifyContent(FlexAlign.Start)
        .padding({ left: Constants.COLUMNS_PADDING, right: Constants.COLUMNS_PADDING })
        .height(Constants.NAV_DESTINATION_HEIGHT)
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title($r('app.string.pip_demo'))
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .mode(NavigationMode.Auto)
    .navDestination(this.PageMap)
    .size({ width: Constants.NAV_DESTINATION_WIDTH, height: Constants.NAV_DESTINATION_HEIGHT })
    .id(this.navigationId)
  }
}
