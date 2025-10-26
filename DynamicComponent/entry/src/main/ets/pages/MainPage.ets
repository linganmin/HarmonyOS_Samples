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

import { ArrayList } from '@kit.ArkTS';
import { getAdNodeController } from '../components/AdController';
import { CardComponent } from '../components/CardComponent';
import { CardData, CardDataSource } from '../model/CardData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component
export struct MainPage {
  private data: CardDataSource = new CardDataSource();
  private idList: ArrayList<string> = new ArrayList();

  // Saves the NodeController required for creating the Map.
  // [Start aboutToAppear_start]
  aboutToAppear() {
    for (let i = 0; i <= 100; i++) {
      let id = i.toString();
      // In actual services, data is obtained from the cloud, a card list is generated,
      // and the node where the advertisement is located is marked.
      if (i % 7 === 6) {
        // Node where the advertisement is located
        this.data.pushData(new CardData(true, id));
        try {
          this.idList.add(id);
        } catch (error) {
          let err = error as BusinessError
          if (err.code) {
            hilog.error(0x0000, 'ImperativeView', 'Failed to add id. Cause: %{public}s', JSON.stringify(err) ?? '');
          }
        }
      } else {
        this.data.pushData(new CardData(false, id));
      }
    }
  }
  // [End aboutToAppear_start]

  build() {
    NavDestination() {
      // [Start List_start]
      List({ space: 3 }) {
        // Iteratively generating a node tree
        LazyForEach(this.data, (item: CardData) => {
          ListItem() {
            if (item.isAdCard()) {
              // Creates a NodeContainer placeholder for an ad node. When the component is loaded,
              // the corresponding ad card Controller is obtained.
              NodeContainer(getAdNodeController(this.getUIContext(), item.getId())).width($r('app.string.percent_100'));
            } else {
              CardComponent({ cardData: item });
            }
          }
          .margin({
            left: $r('app.string.spacing_xxl'),
            right: $r('app.string.spacing_xxl')
          })
        }, (item: CardData) => item.getId())
      }
      .width($r('app.string.percent_100'))
      .height($r('app.string.percent_100'))
      .cachedCount(5)
      // [End List_start]
    }
    .layoutWeight(1)
    .title(this.ResourceToString($r('app.string.tab2')))
  }

  ResourceToString(resource:Resource):string{
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError
      if (err.code) {
        hilog.error(0x0000, 'ImperativeView', 'Failed to get resource. Cause: %{public}s', JSON.stringify(err) ?? '');
      }
      return '';
    }
  }
}