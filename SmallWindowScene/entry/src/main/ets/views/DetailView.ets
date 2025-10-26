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

import { CommonConstants } from '../constants/CommonConstants';
import { Blog, BlogViewModel } from '../viewmodels/BlogViewModel';
import { BlogView } from './BlogView';

@Component
export struct DetailView {
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 0;
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 0;
  private blogList: Blog[] = new BlogViewModel().getBlogList();

  @Builder
  operationUtils() {
    Row() {
      operationIcon({ icon: $r('app.media.ic_toolbar_comment') })
      operationIcon({ icon: $r('app.media.ic_toolbar_star') })
      operationIcon({ icon: $r('app.media.ic_toolbar_heart') })
      operationIcon({ icon: $r('app.media.ic_toolbar_share') })
    }
    .width(CommonConstants.HUNDRED_PERCENT)
    .height($r('app.float.util_height'))
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    NavDestination() {
      // [Start scroll]
      Scroll() {
        Column() {
          // [StartExclude scroll]
          List() {
            ForEach(this.blogList, (item: Blog, index: number) => {
              ListItem() {
                Column() {
                  BlogView({ blog: item })

                  Divider()
                    .width(CommonConstants.HUNDRED_PERCENT)
                    .strokeWidth('0.5vp')
                  this.operationUtils()

                  Divider()
                    .width(CommonConstants.HUNDRED_PERCENT)
                    .strokeWidth('10vp')
                    .color($r('app.color.grey_background'))
                    .visibility(index === this.blogList.length - 1 ? Visibility.None : Visibility.Visible)
                }
                .width(CommonConstants.HUNDRED_PERCENT)
              }
              .margin({ bottom: index === this.blogList.length - 1 ? this.bottomAvoidHeight : 0 })
            }, (item: Blog, index: number) => JSON.stringify(item) + index)

          }
          .scrollBar(BarState.Off)
          .listDirection(Axis.Vertical)
          .width(CommonConstants.HUNDRED_PERCENT)
          .padding({ top: this.topAvoidHeight })

          // [EndExclude scroll]
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .height('100%')
      .width('100%')

      // [End scroll]
    }
    .height(CommonConstants.HUNDRED_PERCENT)
    .width(CommonConstants.HUNDRED_PERCENT)
    .hideTitleBar(true)
  }
}

@Component
struct operationIcon {
  icon: Resource = $r('app.media.ic_toolbar_comment');

  build() {
    Image(this.icon)
      .width($r('app.float.image_size_sm'))
      .height($r('app.float.image_size_sm'))
  }
}