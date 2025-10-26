/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/**
 * Image and text title information.
 */
export class GraphicTitle {
  titlePicUrl: string = '';
  title: ResourceStr = '';

  constructor(titlePicUrl: string, title: ResourceStr) {
    this.titlePicUrl = titlePicUrl;
    this.title = title;
  }
}

/**
 * Group list of teletext titles.
 */
export class GraphicTitleGroup {
  title: ResourceStr;
  graphicTitleList: GraphicTitle[];

  constructor(title: ResourceStr, graphicTitleList: GraphicTitle[]) {
    this.title = title;
    this.graphicTitleList = graphicTitleList;
  }
}

/**
 * Contact groups list.
 */
export class ContactGroup {
  title: Resource | string;
  contact: ContactInfo[];

  constructor(title: Resource | string, contact: ContactInfo[]) {
    this.title = title;
    this.contact = contact;
  }
}

/**
 * Contact information.
 */
export class ContactInfo {
  imgName: string;
  name: Resource;

  constructor(imgName: string, name: Resource) {
    this.imgName = imgName;
    this.name = name;
  }
}

/**
 * Topic Information.
 */
export class TopicInfo {
  topicId: string;
  title: Resource;
  viewCount: string;

  constructor(topicId: string, title: Resource, viewCount: string) {
    this.topicId = topicId;
    this.title = title;
    this.viewCount = viewCount;
  }
}

/**
 * Topic Group.
 */
export class TopicGroup {
  topicList: TopicInfo[];
  title: ResourceStr;
  groupId: string;

  constructor(topicList: TopicInfo[], title: ResourceStr, groupId: string) {
    this.topicList = topicList;
    this.title = title;
    this.groupId = groupId;
  }
}