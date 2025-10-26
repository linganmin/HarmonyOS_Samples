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

import { CommonConstants as Const } from '../../common/CommonConstants';
import { AVPlayerUtil } from '../../common/utils/AVPlayerUtil';

@Component
export struct VideoPlayView {
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('isHover') isHover: boolean = false;
  public avPlayerUtil?: AVPlayerUtil;
  private xComponentController: XComponentController = new XComponentController();

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: this.isHover ? FlexAlign.Start : FlexAlign.Center,
      alignItems: ItemAlign.Start
    }) {
      // [Start set_height]
      Column() {
        XComponent({
          id: Const.X_COMPONENT_ID,
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          // [StartExclude set_height]
          .onLoad(() => {
            this.avPlayerUtil?.createAvPlayer(this.xComponentController.getXComponentSurfaceId());
          })
          .aspectRatio(Const.VIDEO_ASPECT_RATIO)
        // [EndExclude set_height]
      }
      .height(this.isHover ? this.creaseRegion[0] : '100%')
      // [End set_height]
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}