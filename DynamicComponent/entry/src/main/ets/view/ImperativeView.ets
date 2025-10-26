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
import { FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import data from 'resources/rawfile/structure.json';
import dataEn from 'resources/rawfile/structure_en.json';
import { typeNode } from '@ohos.arkui.node';
import { i18n } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start VM_start]
class VM {
  type?: string;
  content?: string;
  css?: ESObject;
  children?: VM[];
  id?: string;
}
// [End VM_start]

// [Start carouselNodes_start]
let carouselNodes: typeNode.Image[] = [];

function FrameNodeFactory(vm: VM, context: UIContext): FrameNode | null {
  if (vm.type === "Column") {
    let node = typeNode.createNode(context, "Column");
    setColumnNodeAttr(node, vm.css);
    vm.children?.forEach(kid => {
      let child = FrameNodeFactory(kid, context);
      node.appendChild(child);
    });
    return node;
  } else if (vm.type === "Row") {
    // [StartExclude carouselNodes_start]
    let node = typeNode.createNode(context, "Row");
    setRowNodeAttr(node, vm.css);
    vm.children?.forEach(kid => {
      let child = FrameNodeFactory(kid, context);
      node.appendChild(child);
    });
    return node;
    // [EndExclude carouselNodes_start]
  } else if (vm.type === "Swiper") {
    // [StartExclude carouselNodes_start]
    let node = typeNode.createNode(context, "Swiper");
    node.attribute.width(vm.css.width);
    node.attribute.height(vm.css.height);
    vm.children?.forEach(kid => {
      let child = FrameNodeFactory(kid, context);
      node.appendChild(child);
    });
    return node;
    // [EndExclude carouselNodes_start]
  } else if (vm.type === "Image") {
    // [StartExclude carouselNodes_start]
    let node = typeNode.createNode(context, "Image");
    node.attribute.width(vm.css.width);
    node.attribute.height(vm.css.height);
    node.attribute.borderRadius(vm.css.borderRadius);
    node.attribute.objectFit(ImageFit.Fill);
    node.attribute.onClick(() => {
      context.getPromptAction().showToast({ message: $r("app.string.imperative_demo_toast_tips") });
    });
    node.initialize($r(vm.content));
    carouselNodes.push(node);
    return node;
    // [EndExclude carouselNodes_start]
  } else if (vm.type === "Text") {
    // [StartExclude carouselNodes_start]
    let node = typeNode.createNode(context, "Text");
    node.attribute.fontSize(vm.css.fontSize);
    node.attribute.width(vm.css.width);
    node.attribute.height(vm.css.height);
    node.attribute.width(vm.css.width);
    node.attribute.borderRadius(vm.css.borderRadius);
    node.attribute.backgroundColor(vm.css.backgroundColor);
    node.attribute.fontColor(vm.css.fontColor);
    node.attribute.opacity(vm.css.opacity);
    node.attribute.textAlign(TextAlign.Center);
    node.attribute.fontWeight(vm.css.fontWeight)
    if (vm.id === 'refreshImage') {
      node.attribute.onClick(() => {
        carouselNodes[0].initialize($r('app.media.movie6'));
        carouselNodes[1].initialize($r('app.media.movie7'));
        carouselNodes[2].initialize($r('app.media.movie8'));
        carouselNodes[3].initialize($r('app.media.movie9'));
        carouselNodes[4].initialize($r('app.media.movie10'));
        node.attribute.visibility(Visibility.Hidden);
      })
    } else {
      node.attribute.onClick(() => {
        context.getPromptAction().showToast({ message: $r("app.string.imperative_demo_toast_tips") });
      });
    }
    node.initialize(vm.content);
    return node;
    // [EndExclude carouselNodes_start]
  }
  return null;
}

function setColumnNodeAttr(node: typeNode.Column, css: ESObject) {
  node.attribute.width(css.width);
  node.attribute.height(css.height);
  node.attribute.backgroundColor(css.backgroundColor);
  node.attribute.justifyContent(FlexAlign.End);

    if (css.alignItems === "HorizontalAlign.Start") {
    node.attribute.alignItems(HorizontalAlign.Start);
  }
  if (css.padding !== undefined) {
    node.attribute.padding(css.padding as Padding);
  }
  if (css.margin !== undefined) {
    node.attribute.margin(css.margin as Padding);
  }
}

function setRowNodeAttr(node: typeNode.Row, css: ESObject) {
  node.attribute.width(css.width);
  node.attribute.height(css.height);
  if (css.padding !== undefined) {
    node.attribute.padding(css.padding as Padding);
  }
  if (css.margin !== undefined) {
    node.attribute.margin(css.margin as Padding);
  }
  node.attribute.justifyContent(FlexAlign.SpaceBetween);
}
// [End carouselNodes_start]



class ImperativeController extends NodeController {
  makeNode(uiContext: UIContext): FrameNode | null {
    carouselNodes = [];
    if (i18n.System.getSystemLanguage() == 'zh-Hans') {
      return FrameNodeFactory(data, uiContext);
    } else {
      return FrameNodeFactory(dataEn, uiContext);
    }
  }
}

@Builder
export function ImperativeViewComponentBuilder() {
  ImperativeViewComponent()
}

@Component
export struct ImperativeViewComponent {
  controller: ImperativeController = new ImperativeController();
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Column() {
        NodeContainer(this.controller)
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.Black)
    }
    .title(this.ResourceToString($r('app.string.tab3')))
  }

  ResourceToString(resource:Resource):string{
    try {
      return this.context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError
      if (err.code) {
        hilog.error(0x0000, 'ImperativeView', 'Failed to get resource. Cause: %{public}s', JSON.stringify(err) ?? '');
      }
      return '';
    }
  }
}