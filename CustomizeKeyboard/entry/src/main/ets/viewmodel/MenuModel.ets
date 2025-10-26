/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export let numberKeyboardData: Menu[] = [
  {
    text: ',',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '1',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '2',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '3',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: $r('app.string.keyboardButton_delete'),
    backgroundColor: $r('app.color.menu_color_gray'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '?',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '4',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '5',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '6',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: $r('app.string.keyboardButton_clear'),
    backgroundColor: $r('app.color.menu_color_gray'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '!',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '7',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '8',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '9',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: $r('app.string.keyboardButton_finish'),
    backgroundColor: $r('app.color.menu_color_gray'),
    width: '100%',
    height: '98vp'
  },
  {
    text: $r('app.string.tabButton_english_text'),
    backgroundColor: $r('app.color.menu_color_gray'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '0',
    backgroundColor: $r('app.color.menu_color_white'),
    width: '100%',
    height: '46vp'
  },
  {
    text: '.',
    backgroundColor: $r('app.color.menu_color_gray'),
    width: '100%',
    height: '46vp'
  }
]

export let EnglishKeyboardData: Menu[][] = [
  [
    {
      text: 'q',
      upperText: 'Q',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'w',
      upperText: 'W',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'e',
      upperText: 'E',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'r',
      upperText: 'R',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 't',
      upperText: 'T',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'y',
      upperText: 'Y',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'u',
      upperText: 'U',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'i',
      upperText: 'I',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'o',
      upperText: 'O',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'p',
      upperText: 'P',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    }
  ],
  [
    {
      text: 'a',
      upperText: 'A',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 's',
      upperText: 'S',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'd',
      upperText: 'D',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'f',
      upperText: 'F',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'g',
      upperText: 'G',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'h',
      upperText: 'H',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'j',
      upperText: 'J',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'k',
      upperText: 'K',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'l',
      upperText: 'L',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    }
  ],
  [
    {
      text: $r('app.media.arrowshape_up'),
      upperText: $r('app.media.arrowshape_up_fill'),
      backgroundColor: $r('app.color.menu_color_gray'),
      width: 49 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'z',
      upperText: 'Z',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'x',
      upperText: 'X',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'c',
      upperText: 'C',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'v',
      upperText: 'V',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'b',
      upperText: 'B',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'n',
      upperText: 'N',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: 'm',
      upperText: 'M',
      backgroundColor: $r('app.color.menu_color_white'),
      width: 30 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: $r('app.string.keyboardButton_delete'),
      backgroundColor: $r('app.color.menu_color_gray'),
      width: 49 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    }
  ],
  [
    {
      text: $r('app.string.tabButton_number_text'),
      backgroundColor: $r('app.color.menu_color_gray'),
      width: 72 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: $r('app.string.keyboardButton_space'),
      backgroundColor: $r('app.color.menu_color_white'),
      width: 212 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    },
    {
      text: $r('app.string.keyboardButton_finish'),
      backgroundColor: $r('app.color.menu_color_gray'),
      width: 72 + uiContext!.px2vp(6) + 'vp',
      height: '43vp'
    }
  ]
]

export interface Menu {
  text: string | Resource;
  upperText?: string | Resource;
  backgroundColor: Resource;
  width: string;
  height: string;
}
