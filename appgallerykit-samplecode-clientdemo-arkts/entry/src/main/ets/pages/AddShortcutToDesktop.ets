/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { productViewManager } from '@kit.AppGalleryKit';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'addShortcutToDesktop';

@Entry
@Component
@Preview
struct Index {
    scroller: Scroller = new Scroller();

    tid: string = "";

    build() {
        Scroll(this.scroller) {
            Column() {
                Row() {
                    Text($r('app.string.shortcutTitle'))
                        .width('100%')
                        .height(48)
                        .lineHeight(48)
                        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                        .fontWeight(FontWeight.Bold)
                        .margin({ bottom: 6 })
                        .textAlign(TextAlign.Center)
                }.alignItems(VerticalAlign.Center)

                Text($r('app.string.shortcutOverview'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })

                Text($r('app.string.shortcutDescribe'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })

                Text($r('app.string.shortcutProcedure'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })

                Text($r('app.string.shortcutProcedure1'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))

                Text($r('app.string.shortcutProcedure2'))
                    .width('100%')
                    .fontSize(14)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Divider().strokeWidth(1).margin({ bottom: 0, top: 10 })

                Text($r('app.string.shortcutDemo'))
                    .width('100%')
                    .height(48)
                    .lineHeight(48)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 6 })
                Text($r('app.string.checkPinShortcutPermittedDescribe'))
                    .width('100%')
                    .fontSize(16)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                    .fontWeight(FontWeight.Medium)
                Text(`1. checkPinShortcutPermitted(context: UIAbilityContext, shortcutId: string, want: Want, labelResName: string, iconResName: string): Promise<CheckShortcutResult>`)
                    .width('100%')
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Button("checkPinShortcutPermitted").onClick(() => {
                    // Scenario 1: Pass a resource name to check whether a shortcut can be added to the home screen and add the shortcut to the home screen if it can be added.
                    try {
                        const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
                        const shortcutId = "id_test1"; // Corresponds to shortcutId configured in the shortcut tag.
                        const labelResName = "shortcut"; // Corresponds to the label resource name configured in the shortcut tag.
                        const iconResName = "aa_icon"; // Corresponds to the icon resource name configured in the shortcut tag.
                        const want: Want = {
                            bundleName: "com.example.appgallery.kit.demo",
                            moduleName: "entry",
                            abilityName: "EntryAbility",
                            parameters: {
                                testKey: "testValue"
                            }
                        };
                        productViewManager.checkPinShortcutPermitted(uiContext, shortcutId, want, labelResName, iconResName)
                            .then((result: productViewManager.CheckShortcutResult) => {
                                hilog.info(0x0001, TAG, `checkPinShortcutPermitted success result is ${JSON.stringify(result)}`);
                                this.tid = result.tid ?? "";
                                this.getUIContext().getPromptAction().showToast({
                                    message: JSON.stringify(result),
                                    duration: 1000
                                });
                            }).catch((error: BusinessError) => {
                            hilog.error(0x0001, TAG, `checkPinShortcutPermitted error. code is ${error.code}, message is ${error.message}`);
                            this.getUIContext().getPromptAction().showToast({
                                message: JSON.stringify(error),
                                duration: 1000
                            });
                        })
                    } catch (err) {
                        hilog.error(0x0001, TAG, `checkPinShortcutPermitted error: ${JSON.stringify(err)}`);
                    }
                }).margin({ top: 4, bottom: 4 })
                Text(`2. checkPinShortcutPermitted(context: UIAbilityContext, shortcutId: string, want: Want, label: string, foregroundIcon: string, backgroundIcon: string): Promise<CheckShortcutResult>`)
                    .width('100%')
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Text($r('app.string.checkPinShortcutPermittedNote'))
                    .width('100%')
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                    .fontStyle(FontStyle.Italic)
                Button("checkPinShortcutPermitted").onClick(() => {
                    // Scenario 2: Pass a resource sandbox path to check whether a shortcut can be added to the home screen and add the shortcut to the home screen if it can be added.
                    try {
                        const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
                        const shortcutId = `${Date.now()}`;
                        const want: Want = {
                            bundleName: "com.example.appgallery.kit.demo",
                            moduleName: "entry",
                            abilityName: "EntryAbility",
                            parameters: {
                                testKey: "testValue"
                            }
                        }
                        const label = "shortcut";
                        const foregroundIcon = uiContext.filesDir + "/icon.png"; // Store this file in /data/app/el2/100/base/com.example.appgallery.kit.demo/haps/entry/files in advance.
                        const backgroundIcon = ""; // You can pass an empty string, which indicates a single icon. Currently only a single icon is supported.
                        productViewManager.checkPinShortcutPermitted(uiContext, shortcutId, want, label, foregroundIcon, backgroundIcon)
                            .then(result => {
                                hilog.info(0x0001, TAG, `checkPinShortcutPermitted success result is ${JSON.stringify(result)}`);
                                this.tid = result.tid ?? "";
                                this.getUIContext().getPromptAction().showToast({
                                    message: JSON.stringify(result),
                                    duration: 2000
                                });
                            }).catch((error: BusinessError) => {
                            hilog.error(0x0001, TAG, `checkPinShortcutPermitted error. code is ${error.code}, message is ${error.message}`);
                            this.getUIContext().getPromptAction().showToast({
                                message: JSON.stringify(error),
                                duration: 2000
                            });
                        })
                    } catch (err) {
                        hilog.error(0x0001, TAG, `checkPinShortcutPermitted error: ${JSON.stringify(err)}`);
                    }
                }).margin({ top: 4, bottom: 4 })

                Divider().strokeWidth(1).margin({ bottom: 4, top: 4 })

                Text($r('app.string.requestNewPinShortcutDescribe'))
                    .width('100%')
                    .fontSize(16)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                    .fontWeight(FontWeight.Medium)
                Text(`requestNewPinShortcut(context: UIAbilityContext, tid: string): Promise<void>`)
                    .width('100%')
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                Button("requestNewPinShortcut").onClick(() => {
                    try {
                        const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
                        productViewManager.requestNewPinShortcut(uiContext, this.tid)
                            .then(() => {
                                hilog.info(0x0001, TAG, `requestNewPinShortcut success.`);
                                this.tid = "";
                                this.getUIContext().getPromptAction().showToast({
                                    message: "success",
                                    duration: 1000
                                });
                            }).catch((error: BusinessError) => {
                            hilog.error(0x0001, TAG, `requestNewPinShortcut error. code is ${error.code}, message is ${error.message}`);
                            setTimeout(() => {
                                this.getUIContext().getPromptAction().showToast({
                                    message: JSON.stringify(error),
                                    duration: 1000
                                });
                            }, 50)
                        })
                    } catch (err) {
                        hilog.error(0x0001, TAG, `requestNewPinShortcut error: ${JSON.stringify(err)}`);
                    }
                }).margin({ top: 4 })
            }.padding({ left: 4, right: 4 })
        }
    }
}