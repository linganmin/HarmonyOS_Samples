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

import { cloudDatabase } from '@kit.CloudFoundationKit';

class News extends cloudDatabase.DatabaseObject {
  public newsId: number = 0;
  public title = '';
  public content = '';
  public newsType = '图文';
  public pubUserName: string = '';
  public pubUserAvatar: string = '';
  public pubDate: Date = new Date();
  public viewCount: number = 0;

  public naturalbase_ClassName(): string {
    return 'News';
  }
}

export { News };