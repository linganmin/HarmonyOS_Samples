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

import { CommonConstants } from '../constants/CommonConstants';

export class BlogViewModel {
  private blogList: Blog[] = [];

  constructor() {
    CommonConstants.USER_PROFILES.forEach((item: Resource, index: number) => {
      this.blogList.push(new Blog(item, CommonConstants.USER_NAMES[index], CommonConstants.USER_TYPES[index],
        CommonConstants.BLOG_DESCRIPTIONS[index], CommonConstants.BLOG_PHOTOS[index]));
    }, (item: Resource, index: number) => JSON.stringify(item) + index)
  }

  getBlogList(): Blog[] {
    return this.blogList;
  }
}

export class Blog {
  usrProfile: Resource = $r('app.media.user_profile_1');
  userName: Resource = $r('app.string.user_name_1');
  userType: Resource = $r('app.string.user_type_1');
  description: Resource = $r('app.string.blog_content_1');
  photos: Resource[] = [];

  constructor(usrProfile: Resource, userName: Resource, userType: Resource, description: Resource, photos: Resource[]) {
    this.usrProfile = usrProfile;
    this.userName = userName;
    this.userType = userType;
    this.description = description;
    this.photos = photos;
  }

  getUsrProfile(): Resource {
    return this.usrProfile;
  }

  getUserName(): Resource {
    return this.userName;
  }

  getUserType(): Resource {
    return this.userType;
  }

  getDescription(): Resource {
    return this.description;
  }

  getPhotos(): Resource[] {
    return this.photos;
  }
}