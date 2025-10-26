/**
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

import { ItemGroup } from './ItemGroup';
import { getString } from '@ohos/common';
import { MainItem } from './MainItem';

@Component
export struct MenuNavRouter {
  @StorageLink('selectedLabel') selectedLabel: string = '';
  @StorageLink('selectedSecondLabel') selectedSecondLabel: string = '';
  @StorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  public childList: Array<string> = [];
  public addAction?: (title: string) => void;
  public secondLabel?: boolean;

  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 8, right: 8 })
  }

  build() {
    ItemGroup() {
      Column() {
        ForEach(this.childList, (item: string, index: number) => {
          if (index > 0) {
            this.CustomDivider()
          }
          MainItem({
            title: item
          })
            .onClick(()=>{
              if (this.secondLabel) {
                this.selectedSecondLabel = item;
                if (this.selectedSecondLabel === getString($r('app.string.lru_cache'))) {
                  this.pathStack.pushPathByName('LRUCache', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.base64'))) {
                  this.pathStack.pushPathByName('Base64Helper', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.string_code'))) {
                  this.pathStack.pushPathByName('StringCode', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.rational_number'))) {
                  this.pathStack.pushPathByName('RationalNumber', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.type_check'))) {
                  this.pathStack.pushPathByName('TypeCheck', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.json_function'))) {
                  this.pathStack.pushPathByName('JsonFunction', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.scope_helper'))) {
                  this.pathStack.pushPathByName('ScopeHelper', null, null);
                }
                if (this.selectedSecondLabel === getString($r('app.string.ason_function'))) {
                  this.pathStack.pushPathByName('AsonFunction', null, null);
                }
              } else {
                this.selectedLabel = item;
                // The page content is displayed according to the selected menu.
                if (this.selectedLabel === getString($r('app.string.xml'))) {
                  this.pathStack.pushPathByName('ConvertXml', null, null);
                } else if (this.selectedLabel === getString($r('app.string.url'))) {
                  this.pathStack.pushPathByName('Url', null, null);
                } else if (this.selectedLabel === getString($r('app.string.uri'))) {
                  this.pathStack.pushPathByName('Uri', null, null);
                } else if (this.selectedLabel === getString($r('app.string.array_list'))) {
                  this.pathStack.pushPathByName('ArrayListView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.task_pool'))) {
                  this.pathStack.pushPathByName('TaskPool', null, null);
                } else if (this.selectedLabel === getString($r('app.string.deque'))) {
                  this.pathStack.pushPathByName('DequeView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.hash_map'))) {
                  this.pathStack.pushPathByName('HashMapView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.hash_set'))) {
                  this.pathStack.pushPathByName('HashSetView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.light_weight_map'))) {
                  this.pathStack.pushPathByName('LightWeightMapView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.light_weight_set'))) {
                  this.pathStack.pushPathByName('LightWeightSetView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.linked_list'))) {
                  this.pathStack.pushPathByName('LinkedListView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.list'))) {
                  this.pathStack.pushPathByName('ListView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.plain_array'))) {
                  this.pathStack.pushPathByName('PlainArrayView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.queue'))) {
                  this.pathStack.pushPathByName('QueueView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.stack'))) {
                  this.pathStack.pushPathByName('StackView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.tree_map'))) {
                  this.pathStack.pushPathByName('TreeMapView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.tree_set'))) {
                  this.pathStack.pushPathByName('TreeSetView', null, null);
                } else if (this.selectedLabel === getString($r('app.string.util'))) {
                  this.pathStack.pushPathByName('Util', null, null);
                } else {
                  this.pathStack.pushPathByName('ArkTSUtil', null, null);
                }
              }
            })

        }, (item: string) => JSON.stringify(item))
      }
    }
  }
}