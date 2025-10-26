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
import CommonConstant from "../utils/CommonConstant"
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let getRouter = uiContext!.getRouter();

export class SkipParams {
  onCancel: () => void;
  pageInfos?: NavPathStack;
  type: 0 | 1;

  constructor(onCancel: () => void, type: 0 | 1, pageInfos?: NavPathStack) {
    this.onCancel = onCancel;
    this.type = type;
    if (pageInfos) {
      this.pageInfos = pageInfos;
    }
  }
}

export class routerParams {
  constructor(text: string) {
    this.text = text;
  }

  text: string;
}

function skip(type: 0 | 1, skipParam: string, pageInfos?: NavPathStack) {
  if (type === 0) {
    getRouter.pushUrl({
      url: CommonConstant.ROUTER_PATH,
      params: new routerParams(skipParam)
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'skip', `pushUrl failed, error code=${err.code}, message=${err.message}`);
    });
  } else {
    if (pageInfos) {
      pageInfos.pushPath({ name: CommonConstant.SKIP_ACTION_PATH, param: skipParam });
    }
  }
}

@Builder
export function SkipBuilder(params: SkipParams) {
  Column() {
    Text($r('app.string.SkipBuilderText_1'))
      .fontSize($r('app.float.font_size_large'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.SkipBuilderFontColor'))

    Text($r('app.string.SkipBuilderText_2'))
      .fontSize($r('app.float.font_size_medium'))
      .fontColor($r('app.color.SkipBuilderFontColor'))
      .margin({ top: $r('app.float.SkipBuilderTextMarginTop'), bottom: $r('app.float.SkipBuilderTextMarginBottom') })

    Text() {
      Span($r('app.string.SkipBuilderSpan_1'))
        .fontSize($r('app.float.font_size_regular')).fontColor($r('app.color.SkipBuilderSpanColor'))
      Span($r('app.string.SkipBuilderSpan_2'))
        .fontSize($r('app.float.font_size_regular'))
        .onClick(() => {
          skip(params.type, CommonConstant.SkipBuilderSpan_2, params.pageInfos)
        })
        .fontColor($r('app.color.base_blue'))
      Span($r('app.string.SkipBuilderSpan_3'))
        .fontSize($r('app.float.font_size_regular'))
        .fontColor($r('app.color.SkipBuilderSpanColor'))
    }

    Row() {
      Button(CommonConstant.CANCEL, { stateEffect: true, type: ButtonType.Normal })
        .onClick(() => {
          params.onCancel();
        })
        .backgroundColor(Color.Transparent)
        .width($r('app.float.SkipBuilderButtonWidth'))
        .height($r('app.float.SkipBuilderButtonHeight'))
        .fontColor($r('app.color.base_blue'))
      Button(CommonConstant.AGREE, { stateEffect: true, type: ButtonType.Normal })
        .onClick(() => {
          params.onCancel();
        })
        .backgroundColor(Color.Transparent)
        .width($r('app.float.SkipBuilderButtonWidth'))
        .height($r('app.float.SkipBuilderButtonHeight'))
        .fontColor($r('app.color.base_blue'))
    }.margin({ top: $r('app.float.SkipBuilderRowMarginTop') })
  }
  .padding({
    top: $r('app.float.SkipBuilderPaddingTop'),
    bottom: $r('app.float.SkipBuilderPaddingBottom'),
    left: $r('app.float.SkipBuilderPaddingLeft'),
    right: $r('app.float.SkipBuilderPaddingRight')
  })
  .width($r('app.float.SkipBuilderWidth'))
}