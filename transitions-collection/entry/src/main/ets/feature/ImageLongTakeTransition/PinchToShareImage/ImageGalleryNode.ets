/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BuilderNode, ComponentUtils, FrameNode, NodeController } from '@kit.ArkUI';
import { WindowUtils } from '../../../utils/windowutils/WindowUtils';
import { ImageWithGesture } from './ImageWithGesture';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export function getTranslateToFullScreen(uiContext: UIContext, id: string): Offset | null {
  let componentUtils: ComponentUtils = uiContext.getComponentUtils();
  let offsets: Offset = new Offset(0, 0);
  try {
    let rectangle = componentUtils.getRectangleById(id);
    offsets.offsetX =
      uiContext.px2vp((rectangle.windowOffset.x + rectangle.size.width / 2) - WindowUtils.windowWidth_px / 2);
    offsets.offsetY =
      uiContext.px2vp((rectangle.windowOffset.y + rectangle.size.height / 2) - WindowUtils.windowHeight_px / 2);
  } catch (err) {
    let error = err as BusinessError;
    hilog.error(0x0000, 'getTranslateToFullScreen', `error code=${error.code}, message=${error.message}`);
  }
  return offsets;
}

interface Params {
  isExpand: boolean;
}

@Builder
function ImageGalleryBuilder(params: Params) {
  ImageGallery({ isExpand: params.isExpand })
}

class Offset {
  offsetX: number = 0;
  offsetY: number = 0;

  constructor(offsetX: number, offsetY: number) {
    this.offsetX = offsetX;
    this.offsetY = offsetY;
  }
}

// [Start ImageGalleryNodeController_start]
export class ImageGalleryNodeController extends NodeController {
  private rootNode: BuilderNode<[Params]> | null = null;
  private wrapBuilder: WrappedBuilder<[Params]> = wrapBuilder(ImageGalleryBuilder);
  private isExpand: boolean = false;

  constructor(isExpand: boolean) {
    super();
    this.isExpand = isExpand;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootNode === null) {
      this.rootNode = new BuilderNode(uiContext);
      this.rootNode.build(this.wrapBuilder, { isExpand: this.isExpand });
    }
    return this.rootNode.getFrameNode();
  }

  init(uiContext: UIContext) {
    this.rootNode = new BuilderNode(uiContext);
    this.rootNode.build(this.wrapBuilder, { isExpand: this.isExpand });
  }

  update(isExpand: boolean) {
    if (this.rootNode !== null) {
      this.rootNode.update({ isExpand });
    }
  }
}

// [End ImageGalleryNodeController_start]

let myNode: ImageGalleryNodeController | undefined;

export const createMyNode = (uiContext: UIContext, isExpand: boolean) => {
  myNode = new ImageGalleryNodeController(isExpand);
  myNode.init(uiContext);
}

export const getMyNode = (): ImageGalleryNodeController | undefined => {
  return myNode;
}

@Component
struct ImageGallery {
  @Prop isExpand: boolean = false;
  private data: number[] = [];
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    for (let i = 0; i < 3; i++) {
      this.data[i] = i;
    }
  }

  build() {
    Swiper(this.swiperController) {
      ForEach(this.data, (item: number) => {
        ImageWithGesture({
          imageUrl: 'app.media.img_' + `${item % 5}`,
          isExpand: this.isExpand
        })
      })
    }
    .disableSwipe(this.isExpand ? true : false)
    .id('swiper')
    .indicator(this.isExpand ? false : true)
    .height('100%')
    .width('100%')
  }
}