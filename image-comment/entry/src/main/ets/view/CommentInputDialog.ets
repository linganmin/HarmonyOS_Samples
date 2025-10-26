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

import { common } from '@kit.AbilityKit';
import { cameraCapture } from '../utils/CameraUtils';
import { ImageListView } from './ImageListView';

const MAX_SELECT_IMAGE: number = 9;
const ID_TEXT_INPUT: string = "id_text_input";
const ID_IMAGE_CAMERA: string = "id_image_camera";
const ID_TEXT_PUSH: string = "id_text_publish";

@CustomDialog
@Component
export struct CommentInputDialog {
  @State selectedImages: string[] = [];
  @State text: string = "";
  @Link textInComment: string;
  @Link imagesInComment: string[];
  controller?: CustomDialogController;
  publish: () => void = (): void => {}

  build() {
    Column() {
      RelativeContainer() {
        TextInput()
          .height($r('app.integer.text_input_height'))
          .padding({
            left: $r('app.integer.text_input_padding_left'),
            right: $r('app.integer.text_input_padding_right'),
            top: $r('app.integer.text_input_padding_top'),
            bottom: $r('app.integer.text_input_padding_bottom')
          })
          .margin({
            right: $r('app.integer.text_input_margin_top')
          })
          .onChange((textInComment: string) => {
            this.text = textInComment;
          })
          .defaultFocus(true)
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: ID_TEXT_PUSH, align: HorizontalAlign.Start }
          })
          .id(ID_TEXT_INPUT)
        Image($r('app.media.camera'))
          .height($r('app.integer.image_camera_height'))
          .width($r('app.integer.image_camera_width'))
          .onClick(async () => {
            if (this.selectedImages.length >= MAX_SELECT_IMAGE) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.most_select_image') });
              return;
            }
            const image: string = await cameraCapture(this.getUIContext().getHostContext() as common.UIAbilityContext);
            if (image !== "") {
              this.selectedImages.push(image);
            }
          })
          .margin({
            right: $r('app.integer.image_camera_margin_top')
          })
          .alignRules({
            top: { anchor: ID_TEXT_INPUT, align: VerticalAlign.Top },
            bottom: { anchor: ID_TEXT_INPUT, align: VerticalAlign.Bottom },
            right: { anchor: ID_TEXT_INPUT, align: HorizontalAlign.End }
          })
          .id(ID_IMAGE_CAMERA)
        Button($r('app.string.publish'))
          .width($r('app.integer.button_publish_width'))
          .height($r('app.integer.button_publish_height'))
          .borderRadius($r('app.integer.button_publish_border_radius'))
          .backgroundColor($r('app.color.button_publish_background'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.controller) {
              this.textInComment = this.text;
              this.imagesInComment = this.selectedImages;
              this.publish();
              this.controller.close();
              this.textInComment = "";
              this.imagesInComment = [];
            }
          })
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .id(ID_TEXT_PUSH)
      }
      .height($r('app.integer.relative_container_input_height'))

      if (this.selectedImages.length > 0) {
        ImageListView({ selectedImages: this.selectedImages, imageEnableDelete: true })
      }
    }
    .padding($r('app.integer.column_input_padding'))
    .backgroundColor(Color.White)
    .offset({
      y: $r('app.integer.column_input_dialog_offset_y')
    })
  }
}