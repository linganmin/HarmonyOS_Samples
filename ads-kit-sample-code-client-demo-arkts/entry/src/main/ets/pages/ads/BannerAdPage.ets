/*
 * Copyright 2023. Huawei Technologies Co., Ltd. All rights reserved.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import { advertising, AutoAdComponent } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdStatus } from '../../constant/AdStatus';
import { AdType } from '../../constant/AdType';
import { AdsViewModel } from '../../viewmodel/AdsViewModel';

const TAG: string = 'Ads Demo-BannerAdPage';

@ComponentV2
export struct BannerAdPage {
  @Local private visibilityState: Visibility = Visibility.Visible;
  private adRequestParams: advertising.AdRequestParams = { adId: '' };
  private ratio: number = -1;
  private viewModel: AdsViewModel = new AdsViewModel(this.getUIContext());

  aboutToAppear() {
    this.adRequestParams = this.viewModel.getParamsFromNav(AdType.BANNER);
    if (this.adRequestParams.adWidth && this.adRequestParams.adHeight) {
      this.ratio = this.adRequestParams.adWidth / this.adRequestParams.adHeight;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image($r('app.media.banner_background'))
        AutoAdComponent({
          adParam: this.adRequestParams,
          adOptions: this.viewModel.adOptions,
          displayOptions: this.viewModel.adDisplayOptions,
          interactionListener: {
            onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
              switch (status) {
                case AdStatus.AD_OPEN:
                  hilog.info(0x0000, TAG, 'Status is onAdOpen');
                  break;
                case AdStatus.AD_CLICKED:
                  hilog.info(0x0000, TAG, 'Status is onAdClick');
                  break;
                case AdStatus.AD_CLOSED:
                  hilog.info(0x0000, TAG, 'Status is onAdClose');
                  this.visibilityState = Visibility.None;
                  break;
                case AdStatus.AD_LOAD:
                  hilog.info(0x0000, TAG, 'Status is onAdLoad');
                  break;
                case AdStatus.AD_FAIL:
                  hilog.error(0x0000, TAG, 'Status is onAdFail');
                  this.visibilityState = Visibility.None;
                  break;
              }
            }
          }
        })
          .width('100%')
          .aspectRatio(this.ratio)
          .visibility(this.visibilityState)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}