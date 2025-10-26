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
import { ListManager } from '@hadss/scroll_components';
import { LinkDataModel, CategoryModel, GoodsDataModel } from "../model/CategoryModel";
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/util/Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Observed
export class GroupLayoutViewModel {
  @Track categoryList: CategoryModel[] = [];
  myListManager: ListManager;
  private NetworkTime: number = 200;
  private listScroller: ListScroller = new ListScroller();

  constructor(myListManager: ListManager, listScroller: ListScroller) {
    this.myListManager = myListManager;
    this.listScroller = listScroller;
  }

  loadData() {
    try {
      let categoryList: CategoryModel[] = [];
      let titleId: number = 0;
      linkData.forEach((item: LinkDataModel) => {
        if (titleId !== item.titleId) {
          categoryList.push({ titleId: item.titleId, titleName: item.titleName, goodsList: [] });
        }
        for (let i = 1; i <= 10; i++) {
          categoryList[categoryList.length -1].goodsList.push({
            titleId,
            goodsId: item.goodsId + i,
            goodsName: uiContext?.getHostContext()?.resourceManager.getStringSync(item.goodsName.id) + i.toString(),
            imgUrl: item.imgUrl,
            price: Number(i.toString() + item.price.toString())
          });
        }
        titleId = item.titleId;
      })
      this.categoryList = categoryList;
      this.initEventCallback(this.categoryList);
      this.myListManager.setDataSource(this.categoryList);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('SearchButton', `getStringSync failed. code = ${err.code}, message = ${err.message}`);
    }
  }

  initEventCallback(list: CategoryModel[]) {
    list.forEach((categoryModel) => {
      categoryModel.goodsList.forEach((good) => {
        good.clickCollection = () => {
          return this.collectionData(good.goodsId);
        }
        good.realIndex = () => {
          return categoryModel.goodsList.indexOf(good);
        }
      });
    });
  }

  deleteData(good: GoodsDataModel): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      // The simulated collection was successful
      setTimeout(() => {
        // this.myListManager.nodeAdapter.deleteData(index);
        resolve(true);
      }, this.NetworkTime);
    });
  }

  collectionData(_goodId: number): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      // The simulated collection was successful
      setTimeout(() => {
        this.listScroller.closeAllSwipeActions();
        resolve(true);
      }, this.NetworkTime);
    });
  }
}


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
    imgUrl: $r('app.media.pic2'),
    price: 20
  },
  {
    titleId: 3,
    titleName: $r('app.string.down_jackets'),
    goodsId: 3,
    goodsName: $r('app.string.down_jackets'),
    imgUrl: $r('app.media.pic3'),
    price: 30
  },
  {
    titleId: 4,
    titleName: $r('app.string.casual_shoes'),
    goodsId: 4,
    goodsName: $r('app.string.casual_shoes'),
    imgUrl: $r('app.media.pic4'),
    price: 40
  },
  {
    titleId: 5,
    titleName: $r('app.string.jacket'),
    goodsId: 5,
    goodsName: $r('app.string.jacket'),
    imgUrl: $r('app.media.pic5'),
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
    imgUrl: $r('app.media.pic2'),
    price: 70
  },
  {
    titleId: 8,
    titleName: $r('app.string.same_style'),
    goodsId: 8,
    goodsName: $r('app.string.same_style'),
    imgUrl: $r('app.media.pic3'),
    price: 80
  },
]