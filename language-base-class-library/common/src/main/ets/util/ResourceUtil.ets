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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let uiContext: UIContext

export async function getStringArray(resource: Resource, UIContext: UIContext): Promise<Array<string>> {
  uiContext = UIContext

  let context = UIContext.getHostContext() as common.UIAbilityContext;
  let menuList: Array<string> = [];
  try {
    menuList = await context.resourceManager.getStringArrayValue(resource.id);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'getStringArray', `getStringArrayValue failed, error code=${err.code}, message=${err.message}`);
  }
  return menuList;
}

export function getString(resource: Resource): string {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  let result = '';
  try {
    result = context.resourceManager.getStringSync(resource.id);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'getString', `getStringSync failed, error code=${err.code}, message=${err.message}`);
  }
  return result;
}

@Builder
export function customTitle(title: string) {
  Row() {
    Text(title)
      .fontColor($r('sys.color.black'))
      .fontSize(16)
      .fontWeight(FontWeight.Bold)

    Row() {
      Image($r('app.media.ic_public_add'))
        .height(24)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
    }
    .id('add')
    .height('100%')
    .aspectRatio(1)
    .visibility(showAddButton(title) ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      addAction(title);
    })
  }
  .width('85%')
  .height(56)
  .margin({ left: 5 })
  .justifyContent(FlexAlign.SpaceBetween)
}

function showAddButton(title: string) {
  let ret = false
  switch (title) {
    case getString($r('app.string.deque')):
    case getString($r('app.string.hash_map')):
    case getString($r('app.string.hash_set')):
    case getString($r('app.string.light_weight_map')):
    case getString($r('app.string.light_weight_set')):
    case getString($r('app.string.linked_list')):
    case getString($r('app.string.list')):
    case getString($r('app.string.array_list')):
    case getString($r('app.string.plain_array')):
    case getString($r('app.string.queue')):
    case getString($r('app.string.stack')):
    case getString($r('app.string.tree_map')):
    case getString($r('app.string.tree_set')):
      ret = true
      break;
    default:
      break;
  }
  return ret
}

function addAction(title: string) {
  switch (title) {
    case getString($r('app.string.deque')):
    case getString($r('app.string.linked_list')):
    case getString($r('app.string.list')):
    case getString($r('app.string.queue')):
    case getString($r('app.string.stack')):
    case getString($r('app.string.array_list')):
      uiContext.getRouter()
        .pushUrl({ url: 'pages/AddInformationView', params: { 'title': title } })
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'addAction', `pushUrl failed, error code=${err.code}, message=${err.message}`);
        })
      break;
    case getString($r('app.string.hash_map')):
    case getString($r('app.string.light_weight_map')):
    case getString($r('app.string.plain_array')):
    case getString($r('app.string.tree_map')):
      uiContext.getRouter()
        .pushUrl({ url: 'pages/AddKeyValuePairView', params: { 'title': title } })
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'addAction', `pushUrl failed, error code=${err.code}, message=${err.message}`);
        })
      break;
    case getString($r('app.string.hash_set')):
    case getString($r('app.string.light_weight_set')):
    case getString($r('app.string.tree_set')):
      uiContext.getRouter()
        .pushUrl({ url: 'pages/AddStringView', params: { 'title': title } })
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'addAction', `pushUrl failed, error code=${err.code}, message=${err.message}`);
        })
      break;
    default:
      break;
  }
}
