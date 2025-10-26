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

import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { LiveProduct, LiveViewModel } from '../viewmodel/LiveViewModel';
import { Comment } from './Comment';
import { LiveShopList } from './LiveShopList';

@Component
export struct LiveMaskLayer {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @Prop currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @State currentProductIndex: number = 0;
  @State liveProductList: LiveProduct[] = new LiveViewModel().getProductList().reverse();
  @Link detailType: string;
  @Link isMoreDetail: boolean;

  build() {
    Flex({
      direction: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? FlexDirection.Row :
      FlexDirection.Column,
      justifyContent: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? FlexAlign.SpaceBetween :
      FlexAlign.End
    }) {
      Comment({currentBreakpoint: this.currentBreakpoint});
      LiveShopList({
        currentBreakpoint: this.currentBreakpoint,
        detailType: this.detailType,
        isMoreDetail: this.isMoreDetail
      });
    }
    .layoutWeight(1)
    .padding({
      left: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
      right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      $r('app.float.live_mask_padding_right_lg') : 0,
      top: deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? 0 : this.topRectHeight
    });
  }
}