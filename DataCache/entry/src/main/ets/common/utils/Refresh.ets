/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import * as Const from '../constant/CommonConstants';
import ListModel from '../../model/ListModel';
import { ResData } from '../types/CommonTypes';

export function refreshState(that: ListModel, state: number): void {
  switch (state) {
    case RefreshStatus.Drag:
      that.pullDownRefreshText = $r('app.string.pull_down_refresh_text');
      that.pullDownRefreshImage = $r('app.media.ic_pull_down_refresh');
      break;
    case RefreshStatus.Refresh:
      that.pullDownRefreshText = $r('app.string.refreshing_text');
      that.pullDownRefreshImage = $r('app.media.ic_pull_up_load');
      break;
    case RefreshStatus.Done:
      that.pullDownRefreshText = $r('app.string.refresh_success_text');
      that.pullDownRefreshImage = $r('app.media.ic_succeed_refresh');
      break;
    default:
      break;
  }
}

export function getUrl(context: Context): string {
  let filename = '';
  try {
    filename = context.resourceManager.getStringSync($r('app.string.fileName').id);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'refreshing', `getStringSync failed, error code=${err.code}, message=${err.message}`);
  }
  return `https://devecostudio-drcn.op.hicloud.com/solution/v1/getSceneMockData?scene=newsData&fileName=${filename}.json&`;
}

export function refreshing(that: ListModel, url: string): Promise<void> {
  that.currentPage = 1;
  return http.createHttp()
    .request(`${url}pageNum=${that.currentPage}&pageSize=${that.pageSize}`)
    .then((res) => {
      const data: ResData[] = JSON.parse(res.result as string).data;
      if (data.length === that.pageSize) {
        that.hasMore = true;
        that.currentPage++;
      } else {
        that.hasMore = false;
      }
      that.newsData = data;
    }).catch(() => {
      hilog.error(0x0000, 'refreshing', 'http request fail');
    });
}

export function loadMore(that: ListModel, url: string): void {
  if (that.hasMore && that.endIndex === that.newsData.length) {
    http.createHttp()
      .request(`${url}pageNum=${that.currentPage}&pageSize=${that.pageSize}`)
      .then((res) => {
        if (Const.TOTAL_COUNT === that.newsData.length) {
          that.hasMore = false;
          return;
        }
        const data: ResData[] = JSON.parse(res.result as string).data;
        if (data.length === that.pageSize) {
          that.currentPage++;
          that.hasMore = true;
        } else {
          that.hasMore = false;
        }
        that.newsData = that.newsData.concat(data);
      }).catch(() => {
      hilog.error(0x0000, 'loadMore', 'http request fail');
    });
  }
}