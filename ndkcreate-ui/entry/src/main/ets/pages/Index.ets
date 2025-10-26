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

import { ICardInfo } from '../model/DataModel';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  cardList: ICardInfo[] = [];

  aboutToAppear(): void {
    this.cardList = [
      {
        'pageName': 'IntegratingWithArkts',
        'pageTitle': $r('app.string.integrating_with_arkts'),
      },
      {
        'pageName': 'ListeningForComponentEvents',
        'pageTitle': $r('app.string.listening_for_component_events'),
      },
      {
        'pageName': 'ListWithLazyLoading',
        'pageTitle': $r('app.string.list_with_lazy_loading'),
      },
      {
        'pageName': 'ListItemGroup',
        'pageTitle': $r('app.string.list_item_group'),
      },
      {
        'pageName': 'BuildingCustomComponents',
        'pageTitle': $r('app.string.building_custom_components'),
      },
      {
        'pageName': 'EmbeddingArkTSComponents',
        'pageTitle': $r('app.string.embedding_arkts_components'),
      },
      {
        'pageName': 'BuildingADialogBox',
        'pageTitle': $r('app.string.building_dialog_box'),
      },
      {
        'pageName': 'UsingPropertyAnimations',
        'pageTitle': $r('app.string.using_property_animations'),
      },
      {
        'pageName': 'AppearDisappearTransitions',
        'pageTitle': $r('app.string.appearance_disappearance_transitions'),
      },
      {
        'pageName': 'CombinedGestures',
        'pageTitle': $r('app.string.gesture_events'),
      }
    ]
  }

  @Builder
  titleBuilder() {
    Column() {
      Text($r('app.string.Navbar_title'))
        .fontSize(30)
        .lineHeight(40)
        .fontWeight(FontWeight.Bold)
    }
    .justifyContent(FlexAlign.Center)
    .margin({
      left: 16,
      right: 16,
      top: 64,
      bottom: 8
    })
    .height(40)
  }

  @Builder
  card(item: ICardInfo) {
    Column() {
      Button(item.pageTitle)
        .width('100%')
        .fontWeight(500)
        .fontSize(16)
        .onClick(() => {
          this.pageInfos.pushPath({ name: item.pageName });
        })
    }

  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        List({ space: 24 }) {
          ForEach(this.cardList, (item: ICardInfo) => {
            ListItem() {
              this.card(item);
            }
          }, (item: ICardInfo) => item.pageName)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 20,
        bottom: 10
      })
    }
    .title({ builder: this.titleBuilder, height: 112 })
    .mode(NavigationMode.Stack)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}



