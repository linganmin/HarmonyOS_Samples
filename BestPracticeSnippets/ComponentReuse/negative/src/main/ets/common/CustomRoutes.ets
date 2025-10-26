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

export class CustomRoutes {
  static readonly ROUTES: Route[] = [
    {
      title: '未使用组件复用',
      child: [
        { text: '场景1', title: '列表项结构类型相同', to: 'NoReuseScene1' },
        { text: '场景2', title: '列表项结构类型相同-结构一', to: 'NoReuseScene2_StructureOne' },
        { text: '场景2', title: '列表项结构类型相同-结构二', to: 'NoReuseScene2_StructureTwo' },
        { text: '场景3', title: '列表项内子组件可拆分组合', to: 'NoReuseScene3' }
      ]
    },
    {
      title: '组件复用使用不当',
      child: [
        { text: '场景1', title: '父组件未使用复用，子组件使用复用', to: 'ImproperReuseOfComponentsScene1' },
        { text: '场景2', title: '复用嵌套', to: 'ImproperReuseOfComponentsScene2' },
        { text: '场景3', title: 'reuseId分类过粗', to: 'ImproperReuseOfComponentsScene3' }
      ]
    }
  ]
}

export interface Route {
  title: string | Resource;
  child: Array<ChildRoute>;
}

export interface ChildRoute {
  text: string | Resource;
  title?: string | Resource | null;
  description?: string;
  to: string;
}