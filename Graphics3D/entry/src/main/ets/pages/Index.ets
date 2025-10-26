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

import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

const TAG: string = '[Index]';

@Entry
@Component
struct Index {
  onJumpClick(target_url: string): void {
    this.getUIContext().getRouter().pushUrl({ url: target_url }, router.RouterMode.Single, (err) => {
      if (err) {
        Logger.error(TAG, `Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
    });
  }

  build() {
    Column() {
      List({ space: Constants.LIST_SPACE }) {
        ListItem() {
          Button($r('app.string.container'))
            .onClick(() => {
              this.onJumpClick('graphics3d/ContainerPage');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button($r('app.string.node_base'))
            .onClick(() => {
              this.onJumpClick('graphics3d/NodeBase');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button($r('app.string.node_camera'))
            .onClick(() => {
              this.onJumpClick('graphics3d/NodeCamera');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button($r('app.string.node_light'))
            .onClick(() => {
              this.onJumpClick('graphics3d/NodeLight');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button($r('app.string.scene_environment'))
            .onClick(() => {
              this.onJumpClick('graphics3d/SceneEnvironment');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button('scene_animation')
            .onClick(() => {
              this.onJumpClick('graphics3d/SceneAnimation');
            })
            .width(Constants.FULL_PERCENT)
        }

        ListItem() {
          Button('scene_shader')
            .onClick(() => {
              this.onJumpClick('graphics3d/SceneShader');
            })
            .width(Constants.FULL_PERCENT)
        }
      }
      .alignListItem(ListItemAlign.Center)
      .padding({
        left: $r('app.float.page_padding_left'),
        right: $r('app.float.page_padding_left')
      })
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
    .padding({ bottom: $r('app.float.page_padding_left') })
  }
}