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

import { common } from '@kit.AbilityKit';
import { uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { TextModifier, SubHeader } from '@kit.ArkUI';
import { ConfigMapKey, ResourceUtil } from '../../common/ResourceUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageHyperLinkBuilder() {
  HyperLinkDrag();
}

@Entry
@Component
struct HyperLinkDrag {
  @State dropContent: ResourceStr = '';
  @State url: string = '';
  @State type: string = '';
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private context?: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Hyperlink(ResourceUtil.getRawFileStringByKey(this.context, ConfigMapKey.HUAWEI_DEVELOPER_URL),
              'This is huawei developer.')
              .draggable(true)
              .margin({ top: '8vp' })
            Hyperlink(ResourceUtil.getRawFileStringByKey(this.context, ConfigMapKey.HUAWEI_DEVECO_STUDIO_URL),
              'This is huawei DevEco Studio.')
              .draggable(true)
              .margin({
                top: '8vp',
                bottom: '8vp'
              })
          }
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .alignItems(HorizontalAlign.Start)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .padding({
            left: '16vp',
            right: '16vp',
            top: '8vp',
            bottom: '8vp'
          })
          .margin({
            left: '16vp',
            right: '16vp',
            top: '8vp'
          })

          SubHeader({
            primaryTitle: $r('app.string.hyperlink_text_column_name'),
            primaryTitleModifier: this.primaryModifier
          })
          Column() {
            Text(this.dropContent)
              .fontSize('16fp')
              .lineHeight(22)
              .width('100%')
              .constraintSize({ maxWidth: '100%' })
              .margin({
                left: '16vp',
                right: '16vp',
                top: '8vp'
              })
          }
          .height('175vp')
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .allowDrop([uniformTypeDescriptor.UniformDataType.HYPERLINK])
          .onDrop((event: DragEvent) => {
            try {
              let dragData = event.getData();
              let records = dragData.getRecords();
              for (let i = 0; i < records.length; i++) {
                let types = records[i].getTypes();
                if (types.includes(uniformTypeDescriptor.UniformDataType.HYPERLINK)) {
                  let hyperLinkUds =
                    records[i].getEntry(uniformTypeDescriptor.UniformDataType.HYPERLINK) as uniformDataStruct.Hyperlink;
                  this.url = hyperLinkUds.url;
                  this.dropContent = $r('app.string.data_detail', hyperLinkUds.url, hyperLinkUds.description);
                }
              }
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
          })
          .margin({
            left: '16vp',
            right: '16vp'
          })
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .margin({
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.context!, $r('app.string.hyperlink_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}