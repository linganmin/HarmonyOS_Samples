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

class ResourceResp {
    constructor(id, title, brief, headerImageUrl, type, webUrl, publishDate, topics, viewsCount,
        collectionCount, likesCount, tag, bannerSrc, mediaSrc, isLiked, isCollected, isViewed) {
        this.id = id;
        this.title = title;
        this.brief = brief;
        this.headerImageUrl = headerImageUrl;
        this.type = type;
        this.webUrl = webUrl;
        this.publishDate = publishDate;
        this.topics = topics;
        this.viewsCount = viewsCount;
        this.collectionCount = collectionCount;
        this.likesCount = likesCount;
        this.tag = tag;
        this.bannerSrc = bannerSrc;
        this.mediaSrc = mediaSrc;
        this.isLiked = isLiked;
        this.isCollected = isCollected;
        this.isViewed = isViewed;
    }
}

module.exports = { ResourceResp };