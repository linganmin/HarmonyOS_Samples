/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { RecommendedProduct, RecommendedProductViewModel } from '../viewmodel/RecommendedProductViewModel';

@Component
export struct RecommendedProductView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @State recommendedProducts: RecommendedProduct[] = new RecommendedProductViewModel().getRecommendedProductList();

  build() {
    Swiper() {
      ForEach(this.recommendedProducts, (item: RecommendedProduct) => {
        Stack() {
          Image(item.getImage())
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT);

          if(item.getIsLive()) {
            Image($r('app.media.icon_is_living'))
              .width(ResourceUtil.getCommonImgSize()[0])
              .height(ResourceUtil.getCommonImgSize()[0])
              .margin({
                top: $r('app.float.section_live_margin'),
                right: $r('app.float.section_live_margin')
              });
          }
        }
        .width('100%')
        .alignContent(Alignment.TopEnd)
        .aspectRatio(1);
      }, (item: Resource, index: number) => JSON.stringify(item) + index);
    }
    .indicator(false);
  }
}