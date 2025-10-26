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

import { AdComponent, advertising } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdStatus } from '../../constant/AdStatus';
import { AdType } from '../../constant/AdType';
import { AdsViewModel } from '../../viewmodel/AdsViewModel';

const TAG: string = 'Ads Demo-NativeAdPage';

@ComponentV2
export struct NativeAdPage {
  @Local private visibilityState: Visibility = Visibility.Visible;
  private viewModel: AdsViewModel = new AdsViewModel(this.getUIContext());

  aboutToAppear() {
    const adRequestParams: advertising.AdRequestParams = this.viewModel.getParamsFromNav(AdType.NATIVE);
    this.viewModel.loadAdWithMultiSlots([adRequestParams]);
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          Repeat<advertising.Advertisement>(this.viewModel.ads)
            .each((repeatItem: RepeatItem<advertising.Advertisement>) => {
              ListItem() {
                AdComponent({
                  ads: [repeatItem.item],
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
                        case AdStatus.AD_FAIL:
                          hilog.info(0x0000, TAG, 'Status is onAdFail');
                          this.visibilityState = Visibility.None;
                          break;
                      }
                    }
                  }
                })
                  .width('100%')
                  .visibility(this.visibilityState)
              }
            })
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}