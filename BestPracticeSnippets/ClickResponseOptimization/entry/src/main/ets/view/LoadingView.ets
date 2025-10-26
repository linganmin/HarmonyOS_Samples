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

/**
 *  最佳实践：点击响应优化
 */
import { CommonConstants } from '../common/constants/WorldCommonConstants';
import Constants, { SkeletonData, SkeType } from '../common/constants/WorldConstants';
import { ArticleSkeletonView } from './ArticleSkeletonView';

@Preview
@Component
export struct LoadingView {
  @State columnBgColor: Color = Color.Gray;
  @State listOpacity: number = 1;

  // [Start start_animation]
  // 骨架图，通过渐显渐隐的方式呈现骨架动画
  startAnimation(): void {
     this.getUIContext().animateTo(CommonConstants.SKELETON_ANIMATION, () => {
      this.listOpacity = CommonConstants.HALF_OPACITY;
    });
  }

  // 骨架图布局
  build() {
    Row() {
      List({ space: Constants.RESOURCE_LIST_SPACE }) {
        ForEach(SkeletonData, (item: SkeType) => {
          ListItem() {
            ArticleSkeletonView({ isMine: item.isMine, isFeed: item.isFeed })
          }
        })
      }
      .padding({
        left: '12vp',
        right: '12vp'
      })
      .lanes(1)
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row()
        .layoutWeight(0)
        .backgroundColor($r('app.color.skeleton_color_medium'))
    }
    .width('100%')
    .opacity(this.listOpacity)
    .onAppear(() => {
      this.startAnimation();
    })
  }

  // [End start_animation]
}