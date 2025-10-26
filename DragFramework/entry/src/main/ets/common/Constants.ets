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

export class Constants {
  public static readonly BREAK_POINT_SM: string = 'sm';
  public static readonly BREAK_POINT_MD: string = 'md';
  public static readonly BREAK_POINT_LG: string = 'lg';
  public static readonly FULL_WIDTH: string = '100%';
  public static readonly FULL_HEIGHT: string = '100%';
  public static readonly BORDER_WIDTH: number = 0.5;
  public static readonly FOLD_IMAGE_RATE: number = 1.2;
  /*
   * Pages name and paths.
   */
  public static readonly ROUTES: Route =
    {
      child: [
        {
          name: 'ImageDrag',
          route: 'image/Image'
        },
        {
          name: 'HyperLinkDrag',
          route: 'hyperlink/HyperLink'
        },
        {
          name: 'RichEditorDrag',
          route: 'richEditor/RichEditor'
        },
        {
          name: 'TextInputDrag',
          route: 'textInput/TextInput'
        },
        {
          name: 'TextAreaDrag',
          route: 'textarea/TextArea'
        },
        {
          name: 'ListDrag',
          route: 'list/List'
        },
        {
          name: 'BackgroundCustomization',
          route: 'background/Background'
        },
        {
          name: 'WatermarkAdded',
          route: 'watermark/Watermark'
        },
        {
          name: 'AIRecognition',
          route: 'aiRecognition/AIRecognition'
        },
        {
          name: 'OnlineImage',
          route: 'onlineimage/OnlineImage'
        },
        {
          name: 'LocalVideo',
          route: 'localvideo/LocalVideo'
        },
        {
          name: 'TextAndImageIndex',
          route: 'textandimage/TextAndImageIndex'
        }
      ]
    }
}

export interface Route {
  child: Array<ChildRoute>;
}

export interface ChildRoute {
  name: string;
  route: string;
}