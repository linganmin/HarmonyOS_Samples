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

import { createMyNode, getMyNode, ImageGalleryNodeController } from './ImageGalleryNode';
import { getResourceString } from '../../../utils/commonutils/ResourceString';

@Builder
export function PinchToShareImagePageOneBuilder() {
  PinchToShareImagePageOne()
}

@Component
struct PinchToShareImagePageOne {
  @State imageGalleryNodeController?: ImageGalleryNodeController = undefined;
  // [Start expand_start]
  @StorageProp('expand') @Watch('goToPageTwo') num1: number = 0;
  // [StartExclude expand_start]
  private pageInfo: NavPathStack = new NavPathStack();

  goToPageTwo() {
    let param: Record<string, Object> = {};
    param['onBack'] = () => {
      this.restoreNodeController()
    };
    this.pageInfo.pushPath({ name: 'PinchToShareImagePageTwo', param }, false);
    this.imageGalleryNodeController = undefined;
  }

  // [EndExclude expand_start]

  aboutToAppear(): void {
    if (!getMyNode()) {
      createMyNode(this.getUIContext(), false);
    }
    this.imageGalleryNodeController = getMyNode();
  }

  // [End expand_start]

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            NodeContainer(this.imageGalleryNodeController)
              .height('100%')
              .width('100%')
          }
          .zIndex(1)
          .height(340)

          Column() {
            Text($r('app.string.DetailPage_text'))
              .fontSize(16)
              .fontColor($r('sys.color.password_icon_focus_color'))
          }
          .padding(16)
        }
      }
      .scrollBar(BarState.Off)
    }
    .title(getResourceString(this.getUIContext(), $r('app.string.double_finger_amplification'), this))
    .height('100%')
    .width('100%')
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
  }

  private restoreNodeController() {
    this.imageGalleryNodeController = getMyNode();
    this.imageGalleryNodeController?.update(false);
  }
}