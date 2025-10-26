/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:如何获取图片的宽高
*/

@Component
struct ImageWidthHeight {
  build() {
    // [Start obtain_the_width_and_height_of_the_image]
    Image($r('app.media.startIcon'))
      .width(200)
      .height(200)
      .objectFit(ImageFit.Contain)
      .onComplete((event) => {
        let imageWidth = event?.width;
        let imageHeight = event?.height;
        console.info('imageWidth:'+imageWidth,'imageHeight:'+imageHeight);
      })
    // [End obtain_the_width_and_height_of_the_image]
  }
}
