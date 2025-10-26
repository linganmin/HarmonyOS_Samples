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

import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { comment as Comment } from './model/comment';
import { CommentResp } from './model/CommentResp';
import { ListResp } from './model/ListResp';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colComment: CloudDBCollection<Comment>;

  constructor(logger) {
    this.logger = logger;
    this.colComment = cloud.database({ zoneName: ZONE_NAME }).collection(Comment);
  }

  async queryComment(pathId: string, pageNum: number, pageSize: number): Promise<ListResp[]> {
    const listResp: ListResp[] = [];
    try {
      const commentQuery: CloudDBZoneQuery<Comment> =
        this.colComment.query().orderByDesc("create_time").equalTo('path_id', pathId);
      let totalCount: number = await commentQuery.countQuery('id');
      commentQuery.limit(pageSize, (pageNum - 1) * pageSize);

      const resList: CommentResp[] = [];
      if (pageNum <= Math.ceil(totalCount / pageSize)) {
        const commentData: Comment[] = await commentQuery.get();
        if (commentData.length <= 0) {
          return listResp;
        }
        for (let i = 0; i < commentData.length; i++) {
          let dataQ: Comment = commentData[i];
          resList.push(new CommentResp(
            dataQ.getId(),
            dataQ.getPath_id(),
            dataQ.getPath_name(),
            dataQ.getUsername(),
            dataQ.getCreate_time(),
            dataQ.getComment(),
            dataQ.getScore()
          ));
        }
      }
      listResp.push(new ListResp(pageNum, pageSize, Math.ceil(totalCount / pageSize),
        totalCount, totalCount > pageNum * pageSize, resList));
      return listResp;
    } catch (error) {
      this.logger.error(`[learning-comments] queryComment error: ${error}`);
    }
  }
}