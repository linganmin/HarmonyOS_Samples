/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { appInfoManager } from '@kit.AppGalleryKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'dynamicIconManager';

@Entry
@Component
@Preview
struct DynamicIconPage {
    scroller: Scroller = new Scroller();
    @State dynamicIconInfos: appInfoManager.DynamicIconInfo[] = [];
    @State message: string = '';

    private queryDynamicIcon() {
        try {
            hilog.info(0, TAG, `queryDynamicIcon start.`);
            appInfoManager.queryDynamicIcons().then((iconInfos: appInfoManager.DynamicIconInfo[]) => {
                hilog.info(0, TAG, `queryDynamicIcons success. iconInfos: ${JSON.stringify(iconInfos)}`);
                this.dynamicIconInfos = iconInfos;
                this.message = JSON.stringify(iconInfos);
            }).catch((error: BusinessError) => {
                this.message = `queryDynamicIcon failed: ${JSON.stringify(error)}`;
                hilog.error(0, TAG,
                    `queryDynamicIcons failed, code: ${error.code}, exception message: ${error.message}`);
            })
        } catch (error) {
            this.message = `queryDynamicIcon exception: ${JSON.stringify(error)}`;
            hilog.error(0, TAG,
                `queryDynamicIcons exception, code: ${error.code}, exception message: ${error.message}`);
        }
    }

    private selectDynamicIcon(iconId: string) {
        try {
            hilog.info(0, TAG, `selectDynamicIcon start.`);
            appInfoManager.selectDynamicIcon(iconId).then(() => {
                hilog.info(0, TAG, `selectDynamicIcon success. iconId: ${iconId}`);
                this.message = `selectDynamicIcon success. iconId: ${iconId}`;
            }).catch((error: BusinessError) => {
                this.message = `selectDynamicIcon failed: ${JSON.stringify(error)}`;
                hilog.error(0, TAG,
                    `selectDynamicIcon failed, code: ${error.code}, exception message: ${error.message}`);
            });
        } catch (error) {
            this.message = `selectDynamicIcon exception: ${JSON.stringify(error)}`;
            hilog.error(0, TAG,
                `selectDynamicIcon exception, code: ${error.code}, exception message: ${error.message}`);
        }
    }

    private disableDynamicIcon() {
        try {
            hilog.info(0, TAG, `disableDynamicIcon start.`);
            appInfoManager.disableDynamicIcon().then(() => {
                hilog.info(0, TAG, `disableDynamicIcon success.`);
                this.message = 'disableDynamicIcon success.';
            }).catch((error: BusinessError) => {
                this.message = `disableDynamicIcon failed: ${JSON.stringify(error)}`;
                hilog.error(0, TAG,
                    `disableDynamicIcon failed, code: ${error.code}, exception message: ${error.message}`);
            });
        } catch (error) {
            this.message = `disableDynamicIcon exception: ${JSON.stringify(error)}`;
            hilog.error(0, TAG,
                `disableDynamicIcon exception, code: ${error.code}, exception message: ${error.message}`);
        }
    }

    build() {
        Scroll(this.scroller) {
            Column() {
                Row() {
                    Text($r('app.string.dynamicIconTitle'))
                        .width('100%')
                        .height(48)
                        .lineHeight(48)
                        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                        .fontWeight(FontWeight.Bold)
                        .margin({ bottom: 6 })
                        .textAlign(TextAlign.Center)
                }.alignItems(VerticalAlign.Center)

                Text($r('app.string.dynamicIconDescName'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })

                Text($r('app.string.dynamicIconDesc'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })

                Text($r('app.string.dynamicIconUsageSteps'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })

                Text($r('app.string.dynamicIconUsageSteps1'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))

                Text($r('app.string.dynamicIconUsageSteps2'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))

                Text($r('app.string.dynamicIconUsageSteps3'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))

                Text($r('app.string.dynamicIconUsageSteps4'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })

                Text($r('app.string.dynamicIconDemonstration'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })

                Button("queryDynamicIcons").onClick(() => {
                    this.queryDynamicIcon();
                }).margin({ top: 4, bottom: 4 })

                Button("disableDynamicIcon").onClick(() => {
                    this.disableDynamicIcon();
                }).margin({ top: 4 })

                if (this.dynamicIconInfos && this.dynamicIconInfos.length > 0) {
                    Divider().strokeWidth(1).margin({ bottom: 4, top: 4 })
                }
                ForEach(this.dynamicIconInfos, (dynamicIconInfo: appInfoManager.DynamicIconInfo) => {
                    Button(`selectDynamicIcon: ${dynamicIconInfo.iconId}`).onClick(() => {
                        this.selectDynamicIcon(dynamicIconInfo.iconId);
                    }).margin({ top: 4, bottom: 4 })
                })

                Divider().strokeWidth(1).margin({ bottom: 4, top: 4 })
                Text(this.message)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.JUSTIFY)
                    .margin({ top: 6 })
            }.padding({ left: 4, right: 4 })
        }
    }
}