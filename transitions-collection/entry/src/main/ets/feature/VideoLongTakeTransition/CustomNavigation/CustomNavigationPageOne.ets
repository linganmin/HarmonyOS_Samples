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

import { ComponentAttrUtils, RectInfoInPx } from '../../../utils/commonutils/ComponentAttrUtils';
import { CardAttr, WaterFlowDataSource } from '../../../utils/commonutils/WaterFlowDataSource';
import Constants from '../../../common/Constants';
import { CustomTransition } from '../../../utils/customtransition/CustomNavigationUtils';
import { WindowUtils } from '../../../utils/windowutils/WindowUtils';
import { VideoCardComponent } from './VideoCard';
import { getResourceString } from '../../../utils/commonutils/ResourceString';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function CustomNavigationPageOneBuilder() {
  CustomNavigationPageOne()
}

@Component
export struct CustomNavigationPageOne {
  @State dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  @State columnType: string = '';
  @StorageProp('currentBreakpoint') @Watch('updateColumnData') currentBreakpoint: string = '';
  @State updateNumber: number = 1;
  @State scrollFirstIndex: number = 0;
  private pageId: string = '';
  private pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    for (let i = 0; i < 6; i++) {
      this.dataSource.pushData(new CardAttr());
    }
    this.updateColumnData();
  }

  build() {
    // [Start NavDestination5_start]
    NavDestination() {
      WaterFlow() {
        LazyForEach(this.dataSource, (_: CardAttr, index: number) => {
          FlowItem() {
            VideoCardComponent({
              isPlaying: false,
              index,
              onColumnClicked: (prePageCallback) => {
                this.onColumnClicked(`xComponent_${index}`, prePageCallback)
              }
            })
          }
          .width('100%')
          .borderRadius(10)
          .clip(true)
          .id('FlowItem_' + index.toString())
        }, (item: string) => item)
      }
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((first: number) => {
        this.scrollFirstIndex = first;
      })
      .padding(12)
      .columnsTemplate(this.columnType)
      .columnsGap(12)
      .rowsGap(10)
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Constants.DEFAULT_BG_COLOR)
    .title(getResourceString(this.getUIContext(), $r('app.string.video_title'), this))
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
      }
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
    })

    // [End NavDestination5_start]
  }

  private updateColumnData(): void {
    let currentBreakpoint: string | undefined = AppStorage.get('currentBreakpoint');
    if (currentBreakpoint === 'xs' || currentBreakpoint === 'sm') {
      this.columnType = '1fr 1fr';
    } else if (currentBreakpoint === 'md') {
      this.columnType = '1fr 1fr 1fr';
    } else {
      this.columnType = '1fr 1fr 1fr 1fr';
    }
  }

  private onColumnClicked(xComponentId: string, prePageCallback: () => void): void {
    try {
      let cardItemInfo: RectInfoInPx =
        ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), xComponentId);
      let param: Record<string, Object> = {};
      param['cardItemInfo'] = cardItemInfo;
      param['xComponentId'] = xComponentId;
      param['prePageCallback'] = prePageCallback;
      this.pageInfos.pushPath({ name: 'VideoLongTakeTransitionWithCustomNavigationPageTwo', param: param });
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'CustomNavigationPageOne',
        `onColumnClicked failed. code=${error.code}, message=${error.message}`);
    }
  }
}