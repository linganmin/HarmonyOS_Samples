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
import { hilog } from "@kit.PerformanceAnalysisKit";

interface LinkDataModel {
  titleId: number,
  titleName: Resource,
  goodsId: number,
  goodsName: Resource,
  imgUrl: Resource,
  price: number,
}

export interface GoodsDataModel {
  titleId: number,
  goodsId: number,
  goodsName: string,
  imgUrl: Resource,
  price: number,
}

export interface NavTitleModel {
  titleId: number,
  titleName: Resource,
  goodsList: GoodsDataModel[]
}

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

class GoodsViewModel {
  getLinkData(): NavTitleModel[] {
    let linkDataList: NavTitleModel[] = [];
    let titleId: number = 0;
    linkData.forEach((item: LinkDataModel) => {
      if (titleId !== item.titleId) {
        linkDataList.push({ titleId: item.titleId, titleName: item.titleName, goodsList: [] });
      }
      try {
        for (let i = 1; i <= 10; i++) {
          linkDataList[linkDataList.length -1].goodsList.push({
            titleId,
            goodsId: item.goodsId + i,
            goodsName: uiContext?.getHostContext()!.resourceManager.getStringSync(item.goodsName.id) + i.toString(),
            imgUrl: item.imgUrl,
            price: Number(i.toString() + item.price.toString())
          })
        }
      } catch (error) {
        hilog.error(0x0000, 'testTag',`getStringSync failed, Code:${error.code}, message:${error.message}`);
      }
      titleId = item.titleId;
    })
    return linkDataList;
  }
}

let goodsViewModel = new GoodsViewModel();

export default goodsViewModel as GoodsViewModel;

const linkData: LinkDataModel[] = [
  {
    titleId: 1,
    titleName: $r('app.string.selected_clothing'),
    goodsId: 1,
    goodsName: $r('app.string.selected_clothing'),
    imgUrl: $r('app.media.pic1'),
    price: 10
  },
  {
    titleId: 2,
    titleName: $r('app.string.selected_accessories'),
    goodsId: 2,
    goodsName: $r('app.string.selected_accessories'),
    imgUrl: $r('app.media.pic1'),
    price: 20
  },
  {
    titleId: 3,
    titleName: $r('app.string.down_jackets'),
    goodsId: 3,
    goodsName: $r('app.string.down_jackets'),
    imgUrl: $r('app.media.pic1'),
    price: 30
  },
  {
    titleId: 4,
    titleName: $r('app.string.casual_shoes'),
    goodsId: 4,
    goodsName: $r('app.string.casual_shoes'),
    imgUrl: $r('app.media.pic1'),
    price: 40
  },
  {
    titleId: 5,
    titleName: $r('app.string.jacket'),
    goodsId: 5,
    goodsName: $r('app.string.jacket'),
    imgUrl: $r('app.media.pic1'),
    price: 50
  },
  {
    titleId: 6,
    titleName: $r('app.string.pants'),
    goodsId: 6,
    goodsName: $r('app.string.pants'),
    imgUrl: $r('app.media.pic1'),
    price: 60
  },
  {
    titleId: 7,
    titleName: $r('app.string.sports_matching'),
    goodsId: 7,
    goodsName: $r('app.string.sports_matching'),
    imgUrl: $r('app.media.pic1'),
    price: 70
  },
  {
    titleId: 8,
    titleName: $r('app.string.same_style'),
    goodsId: 8,
    goodsName: $r('app.string.same_style'),
    imgUrl: $r('app.media.pic1'),
    price: 80
  },
]

