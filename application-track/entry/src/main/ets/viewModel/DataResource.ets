/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/**
 * Tracing point data. The outermost key is the page name.
 */

// [Start data_resource]
// entry\src\main\ets\viewModel\DataResource.ets
export const DataResource: Record<string, Record<string, DataResourceType>> = {
  'Index': {
    'button-1': { id: 'button-1' },
    'button-2': { id: 'button-2' }
  },
  'Page2': {
    'component-1': { id: 'text-2' }
  }
}

export interface DataResourceType {
  id: string
}

// [Start data_resource]