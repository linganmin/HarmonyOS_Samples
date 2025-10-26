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

import { AppStorageV2 } from '@kit.ArkUI';
import Constants from '../commom/Constants';
import SystemAreaModel from '../model/SystemAreaModel';
import VideoCommentView from '../view/VideoCommentView';
import VideoView from '../view/VideoView';

@ComponentV2
struct VideoPage {
  build() {
    Column() {
      VideoView()
      VideoCommentView()
    }
  }
}

const systemAreaModel: SystemAreaModel =
  AppStorageV2.connect(SystemAreaModel, 'systemAreaModel', () => new SystemAreaModel(0, 0)) as SystemAreaModel;

const context: UIContext = AppStorage.get("context") as UIContext;

@Builder
function videoPageBuilder(name: string): void {
  if (name === Constants.NAV_DESTINATION_ITEM_VIDEO) {
    NavDestination() {
      VideoPage();
    }
    .title(title())
    .padding({ top: context.px2vp(systemAreaModel.topRectHeight) })
  } else {
    NavDestination()
      .title('VideoPage UI Error!')
  }
}

export const wrappedBuilderVideo: WrappedBuilder<[string]> =
  wrapBuilder(videoPageBuilder);

@Builder
function title() {
  Row() {
    Text($r('app.string.page_video'))
      .fontSize(20)
      .fontWeight(700)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .lineHeight(27)
      .width(152)

    Row() {
      Stack() {
        Circle()
          .fill($r('sys.color.comp_background_tertiary'))
          .width(40)
          .aspectRatio(1)
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize(20)
      }
    }
    .width(136)
    .height(Constants.FULL_PERCENT)
    .justifyContent(FlexAlign.End)
  }
  .width(Constants.FULL_PERCENT)
  .height(Constants.FULL_PERCENT)
  .padding({ left: 8 })
}