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
* FAQ:视频预览分辨率设置
*/
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct SetVideoPreviewResolution {
  surfaceId: string = '';
  mXComponentController: XComponentController = new XComponentController();

  async initCamera(context: common.BaseContext, surfaceId: string) {}

  build() {
    RelativeContainer() {
      // [Start SetVideoPreviewResolution]
      XComponent({
        id: 'componentId',
        type: 'surface',
        controller: this.mXComponentController,
      }).onLoad(async () => {
        this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
        let baseContext = this.getUIContext().getHostContext()! as common.BaseContext;
        await this.initCamera(baseContext, this.surfaceId)
      }).width('100%')
        .height('100%')
      // [End SetVideoPreviewResolution]
    }
    .height('100%')
    .width('100%')
  }
}
