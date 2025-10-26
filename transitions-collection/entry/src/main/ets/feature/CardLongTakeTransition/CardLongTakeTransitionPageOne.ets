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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { CardAttr, WaterFlowDataSource } from '../../utils/commonutils/WaterFlowDataSource';
import { SnapShotImage } from '../../utils/customtransition/SnapShotImage';
import { CardUtil } from '../../utils/commonutils/CardUtil';
import { CardComponent } from './CardComponent';
import { getResourceString } from '../../utils/commonutils/ResourceString';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function CardLongTakeTransitionPageOneBuilder() {
  CardLongTakeTransitionPageOne()
}

@Component
export struct CardLongTakeTransitionPageOne {
  @State dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  @State columnType: string = '';
  @StorageProp('currentBreakpoint') @Watch('upDateColumnData') currentBreakpoint: string = '';
  private clickedIndex: number = -1;
  private pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    for (let i = 0; i < 100; i++) {
      this.dataSource.pushData(new CardAttr());
    }
    this.upDateColumnData();
  }

  build() {
    NavDestination() {
      Stack() {
        WaterFlow() {
          LazyForEach(this.dataSource, (item: CardAttr, index: number) => {
            FlowItem() {
              CardComponent({
                indexValue: index.toString(),
                cardAttr: item,
                onColumnClicked: (indexValue: string) => {
                  this.onColumnClicked(indexValue);
                }
              })
            }
            .width('100%')
            .borderRadius(10)
            .clip(true)
            .id(CardUtil.getFlowItemIdByIndex(index.toString()))
          }, (item: string) => item)
        }
        .columnsTemplate(this.columnType)
        .columnsGap(10)
        .rowsGap(10)
        .width('100%')
        .height('100%')
      }
      .size({
        width: '100%',
        height: '100%'
      })
      .padding({
        left: 16,
        right: 16
      })
    }
    .backgroundColor('#F1F3F5')
    .title(getResourceString(this.getUIContext(), $r('app.string.card_title'), this))
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }

  private upDateColumnData(): void {
    let currentBreakpoint: string | undefined = AppStorage.get('currentBreakpoint');
    if (currentBreakpoint === 'xs' || currentBreakpoint === 'sm') {
      this.columnType = '1fr 1fr';
    } else if (currentBreakpoint === 'md') {
      this.columnType = '1fr 1fr 1fr';
    } else {
      this.columnType = '1fr 1fr 1fr 1fr';
    }
  }

  private doFinishTransition(): void {
    this.dataSource.getData(this.clickedIndex).isVisible = Visibility.Visible;
  }

  // [Start onColumnClicked_start]
  private onColumnClicked(indexValue: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    param['indexValue'] = clickedIndex;
    this.clickedIndex = clickedIndex;
    // Click the card to get the corresponding screenshot and save it.
    this.getUIContext()
      .getComponentSnapshot()
      .get('FlowItem_' + indexValue, (error: BusinessError, pixelMap: image.PixelMap) => {
        if (error) {
          hilog.error(0x0000, 'CardLongTakePageOne',
            `componentSnapshot.get error, reason: Code is ${error.code}, message is ${error.message}`);
          // If the screenshot fails, go to the default left/right transition. In this case, the pop-up page will not receive clickedComponentId parameter, and the registration process will not proceed.
          // At that time from and to the animation are undefined, will go in customNavContentTransition transitions by default.
          this.pageInfos.pushPath({ name: 'CardLongTakeTransitionPageTwo', param: param });
          return;
        } else {
          hilog.info(0x0000, 'CardLongTakePageOne', 'componentSnapshot.get success!');
          // If the screenshot is successful, then go to a custom mirror in the end transition.
          param['clickedComponentId'] = CardUtil.getFlowItemIdByIndex(indexValue);
          param['doDefaultTransition'] = () => {
            this.doFinishTransition();
          };
          SnapShotImage.pixelMap = pixelMap;
          this.pageInfos.pushPath({ name: 'CardLongTakeTransitionPageTwo', param: param });
          this.dataSource.getData(this.clickedIndex).isVisible = Visibility.Hidden;
        }
      })
  }

  // [End onColumnClicked_start]
}