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

export interface LinkDataModel {
  titleId: number;
  titleName: Resource;
  goodsId: number;
  goodsName: Resource;
  imgUrl: Resource;
  price: number;
}

export interface ParamsGoods {
  dataModel: GoodsDataModel;
}

export interface GoodsDataModel {
  titleId: number;
  goodsId: number;
  goodsName: string;
  imgUrl: Resource;
  price: number;

  // Click events can be defined and callbacks can be made when appropriate
  clickCollection?: () => Promise<boolean>;
  clickDelete?: () => void;
  realIndex?: () => number;
}

export interface CategoryModel {
  titleId: number;
  titleName: Resource;
  goodsList: GoodsDataModel[];
}