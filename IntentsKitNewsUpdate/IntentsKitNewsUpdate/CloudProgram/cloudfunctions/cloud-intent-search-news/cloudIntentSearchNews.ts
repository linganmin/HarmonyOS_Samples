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


import { CloudDbZoneWrapper } from './CloudDBZoneWrapper';
import { Device, PaginationReq, QueryBlogInfoReq } from './types';

interface ISearchParam {
  version: string; // Request version, default '1.0', max 16 chars
  deviceInfo: Device; // Device information
  pagination?: PaginationReq; // Optional pagination parameters
  content: QueryBlogInfoReq; // Search parameters
}

// intent - search data
interface ISearchResult {
  entityId: string;
  blogTitle: string;
  blogType: 'Normal' | 'Video';
  blogCategory: string;
  logoURL: {
    small: {
      url: string;
      widthPixels: number;
      heightPixels: number;
    }
  };
  description: string;
  blogAuthor: string;
  blogAuthorImage: {
    small: {
      url: string;
      widthPixels: number;
      heightPixels: number;
    }
  };
  blogPublishTime: string;
  tags?: string[];
  likeCount?: number;
  forwardCount?: number;
  commentCount?: number;
  favorites?: number;
  viewCount?: number;
  detailUrl: Array<{
    webURL?: string;
    displayText?: string;
  }>;
}

interface IResponse {
  reply: {
    items: ISearchResult[];
    moreLink?: {
      webURL?: string;
      displayText?: string;
    };
    pagination?: {
      next?: string;
      total: number;
    };
  };
  errorCode: string;
  errorMessage: string;
}

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);

  const searchParam = event as ISearchParam;
  const data = await new CloudDbZoneWrapper().searchNews(searchParam?.content?.blogCategory, searchParam?.content?.blogAuthor, searchParam?.content?.keywords);

  const result: ISearchResult[] = data.map((item) => ({
    entityId: item.getNewsId().toString(),
    blogTitle: item.getTitle(),
    blogType: 'Normal',
    blogCategory: item.getNewsType(),
    logoURL: {
      small: {
        url: 'https://gitee.com/gorit/screenshots/raw/main/sm_img.png',
        widthPixels: 320, // Default value
        heightPixels: 180 // Default value
      }
    },
    description: item.getContent().split(',')[0],
    blogAuthor: item.getPubUserName(),
    blogAuthorImage: {
      small: {
        url: item.getPubUserAvatar() || 'https://gitee.com/gorit/screenshots/raw/main/avatar.png',
        widthPixels: 32, // Default value
        heightPixels: 32 // Default value
      }
    },
    blogPublishTime: item.getPubDate().getTime().toString(),
    // Optional fields with default values
    tags: [],
    likeCount: 0,
    forwardCount: 0,
    commentCount: 0,
    favorites: 0,
    viewCount: 0,
    detailUrl: [{
      webURL: `https://your-domain.com/news/${item.getNewsId()}`,
      displayText: '查看详情'
    }]
  }));

  const resp: IResponse = {
    reply: {
      items: result,
      pagination: {
        total: result.length,
        next: result.length >= 20 ? '2' : undefined // Assuming 20 items per page
      },
      moreLink: {
        webURL: 'https://your-domain.com/news/list',
        displayText: '查看更多资讯'
      }
    },
    errorCode: '0',
    errorMessage: 'SUCCESS'
  };

  callback(resp);
};

export { myHandler };