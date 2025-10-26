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

import { CustomSpan, EditorView } from '../views/EditorView';
import { ToolbarView } from '../views/ToolbarView';
import { GraphicTitle, TopicInfo } from '../models/CommonModel';
import { PictureListView } from '../views/PictureListView';
import { TopView } from '../views/TopView';
import { LocationView } from '../views/LocationView';
import Logger from '../utils/Logger';

const TAG = 'Home';

@Entry
@Component
struct Home {
  @Provide titleInfo: GraphicTitle = new GraphicTitle('', '');
  @Provide topicInfo?: TopicInfo = undefined;
  @State isTopicViewVisible: boolean = false;
  @State isEmojiKeyboard: boolean = false;
  getEditorData: () => CustomSpan[] = () => [];

  publish() {
    Logger.info(TAG, JSON.stringify(this.getEditorData()))
  }

  build() {
    Column() {
      TopView({
        onPublish: () => {
          this.publish();
        }
      })

      Scroll() {
        Column() {
          EditorView({
            isTopicViewVisible: this.isTopicViewVisible,
            isEmojiKeyboard: this.isEmojiKeyboard,
            onReady: getData => {
              this.getEditorData = getData;
            }
          })
          PictureListView()
        }
      }
      .align(Alignment.Top)
      .layoutWeight(1)

      LocationView()

      ToolbarView({
        isTopicViewVisible: this.isTopicViewVisible,
        isEmojiKeyboard: this.isEmojiKeyboard
      })
    }
    .height('100%')
    .width('100%')
  }
}