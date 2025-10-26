/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { CommonConstant } from '../constant/CommonConstant';
import { VideoData } from './CommonModel';

export class Service {
  private static instance: Service = new Service();

  public static getInstance(): Service {
    return Service.instance;
  }

  private constructor() {
  }

  getData(uiContext: UIContext) {
    let playerArr: VideoData[] = [];
    CommonConstant.getMediaData(uiContext).forEach((item) => {
      let tempData = new VideoData();
      tempData.url = item.url;
      tempData.publisherImage = item.publisherImage;
      tempData.publisherName = item.publisherName;
      tempData.mediaIntro = item.mediaIntro;
      tempData.isLike = item.isLike;
      tempData.likesNum = item.likesNum;
      tempData.commentsNum = item.commentsNum;
      tempData.shareNum = item.shareNum;
      playerArr.push(tempData);
    });
    let index = Math.floor(Math.random() * (playerArr.length - 1)) + 1;
    playerArr.splice(index, 0, new VideoData());
    return playerArr;
  }
}