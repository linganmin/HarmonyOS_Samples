import { afterAll, beforeAll, beforeEach, DEFAULT, describe, expect, it } from "@ohos/hypium";
import { driver, findAndClickComponent, findAndClickComponentById,
  getUIAbilityContext,
  startAbility } from "./utils/CommonTestUtil";
import { display, router, UIContext, window } from "@kit.ArkUI";
import { AnimationType, DialogHub } from "@hadss/dialoghub";
import { Component, MatchPattern, ON } from "@kit.TestKit";
import { DialogType } from "@hadss/dialoghub/src/main/ets/common/constant/DialogType";
import { common } from "@kit.AbilityKit";
import {
  cleanCurentPageDialogs,
  dragComponent,
  getComponentAttrsStr,
  getComponentRect,
  getInfoFromInspector,
  getTopDialog,
  MODAL_ID,
  testDialogAnimationType,
  testDialogCosed,
  testDialogPassThroughGesture,
  testDuration,
  waitForDialogDisplay,
  waitForDialogDisplayByDialog
} from "./utils/DialogUtils";
import { Point, Rect } from "@ohos.UiTest";
import { Constants } from "./constant/Constants";
import CopyCommonConstant from "./constant/CopyCommonConstant";
import CommonConstant from "../../../main/ets/utils/CommonConstant";

export let uiContext:UIContext;
let mainWindow: window.Window;
let screenWidth: number;
let screenHeight: number;

export default function DialogHubSampleTest() {
  beforeAll(async () => {
    await startAbility();
    await driver.delayMs(1000);
    mainWindow = (await getUIAbilityContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
    uiContext = mainWindow.getUIContext();
    display.getAllDisplays((err, data) => {
      screenWidth = data[0].width;
      screenHeight = data[0].height;
    })
  })
  describe('commonExamplesPageTest', () => {
    beforeAll(async () => {
      await replaceToMainPage();
      await driver.delayMs(500);
      await findAndClickComponent('常见弹窗示例');
    })
    beforeEach(async () => {
      await cleanCurentPageDialogs()
    })
    it('toastTest', 0, async () => {
      await findButtonInSamplePageAndClick('纯文本有持续时间的提示窗', 0);
      let toastDialog = await getTopDialog();
      expect(toastDialog.type).assertEqual(DialogType.TOAST);
      // 判定展示时间
      await testDuration(toastDialog.dialogId, CommonConstant.DURATION_3000);
    });
    it('snackbarTest', 0, async () => {
      let sampleButton = await findButtonInSamplePageAndClick('指定位置的非模态弹窗');
      let snackbar = await getTopDialog();
      expect(snackbar.type).assertEqual(DialogType.CUSTOM);
      let snackbarComponent = await waitForDialogDisplay(snackbar.dialogId);
      // 判定位置(大约在屏幕下半位置即可)
      let dialogRect = await snackbarComponent.getBounds()
      let windowRect = mainWindow.getWindowProperties().windowRect;
      expect(dialogRect.bottom / windowRect.height).assertLarger(0.6)
      // 判定跳转按钮
      let goButton = await driver.findComponent(ON.within(ON.id(snackbar.dialogId)).type('Button').text('点击前往'))
      expect(goButton).not().assertUndefined()
      let isGone = false;
      uiContext.getUIObserver().on("navDestinationSwitch", (info) => {
        if (!isGone) {
          expect(info.operation).assertEqual(NavigationOperation.PUSH);
          isGone = true;
        }
      })
      await goButton.click();
      while (!isGone) {
        await driver.delayMs(100)
      }
      await driver.pressBack();
      await driver.delayMs(100);
      // 关闭操作
      await sampleButton.click();
      snackbar = await getTopDialog();
      expect(snackbar.type).assertEqual(DialogType.CUSTOM);
      await waitForDialogDisplay(snackbar.dialogId);
      let closeIcon =
        await driver.findComponent(ON.within(ON.id(snackbar.dialogId)).isAfter(ON.text('点击前往')).clickable())
      expect(closeIcon).not().assertNull()
      await closeIcon.click();
      await testDialogCosed(snackbar.dialogId);
    });
    it('messageTipTest', 0, async () => {
      await findButtonInSamplePageAndClick('会定时消失且带弹出动效的弹窗');
      let messageTip = await getTopDialog();
      // 判定动画
      await testDialogAnimationType(messageTip, AnimationType.UP_DOWN);
      // 等待展示
      await waitForDialogDisplay(messageTip.dialogId);
      // 判定持续时间
      const expectDuration = CommonConstant.TIMED_DIALOG_DURATION * CommonConstant.DURATION_1000;
      await testDuration(messageTip.dialogId, expectDuration)
    });
    it('inputDialogTest', 0, async () => {
      let keyboardHeight = 0;
      mainWindow.on('keyboardHeightChange', (height) => {
        if (height != 0) {
          keyboardHeight = height;
        }
      })
      await findButtonInSamplePageAndClick('会避让键盘的弹窗');
      let inputDialog = await getTopDialog();
      expect(inputDialog.type).assertEqual(DialogType.CUSTOM);
      // 等待展示
      let inputDialogComponent = await waitForDialogDisplay(inputDialog.dialogId);
      let input = await driver.findComponent(ON.within(ON.id(inputDialog.dialogId)).type('TextInput'));
      let submitButton = await driver.findComponent(ON.within(ON.id(inputDialog.dialogId)).type('Image'));
      expect(input).not().assertNull();
      expect(submitButton).not().assertNull();
      // 输入框默认获焦
      expect(await input.isFocused()).assertEqual(true)
      let rectWithKeyboard = await inputDialogComponent.getBounds();
      // 关闭键盘
      await driver.pressBack();
      await driver.delayMs(500);
      let rectWithOutKeyboard = await inputDialogComponent.getBounds();
      expect(rectWithOutKeyboard.top - rectWithKeyboard.top).assertEqual(keyboardHeight);
    });
    it('popupTest', 0, async () => {
      let sampleButton = await findButtonInSamplePageAndClick('指向选定组件的带箭头弹窗');
      let popup = await getTopDialog();
      expect(popup.type).assertEqual(DialogType.POPUP);
      // 等待展示
      let popupComponent = await waitForDialogDisplay(popup.dialogId);
      let popupRect = await popupComponent.getBounds();
      let targetRect = await sampleButton.getBounds();
      let arrowComponent = await driver.findComponent(ON.within(ON.id(popup.dialogId)).type('Image'))
      let arrowRect = await arrowComponent.getBounds();
      expect(arrowRect.left).assertLarger(popupRect.left);
      expect(arrowRect.right).assertLess(popupRect.right);
      expect(Math.abs(targetRect.top - popupRect.top)).assertLess(100);
      expect(Math.abs(targetRect.right - popupRect.right)).assertLess(100);
      let expectShadow: ShadowStyle = (popup as ESObject).builderOptions.shadow;
      expect(expectShadow).not().assertUndefined()
    });
    it('autoDismissTest', 0, async () => {
      await findButtonInSamplePageAndClick('点击蒙层自动关闭的弹窗');
      let autoDismissDialog = await getTopDialog();
      expect(autoDismissDialog.type).assertEqual(DialogType.CUSTOM);
      // 等待展示
      let dialogComponent = await waitForDialogDisplay(autoDismissDialog.dialogId);
      // 判断遮罩
      let modelComponent = await driver.findComponent(ON.id(MODAL_ID))
      expect(modelComponent).not().assertNull();
      // 判断自动关闭能力
      let dialogRect = await dialogComponent.getBounds()
      await driver.click(dialogRect.left, dialogRect.top - 1);
      await testDialogCosed(autoDismissDialog.dialogId);
    });
    it('ActiveDismissTest', 0, async () => {
      await findButtonInSamplePageAndClick('可主动关闭的弹窗');
      let activeDismissDialog = await getTopDialog();
      expect(activeDismissDialog.type).assertEqual(DialogType.CUSTOM);
      // 等待展示
      await waitForDialogDisplay(activeDismissDialog.dialogId);
      // 判断按钮
      let closeButton = await driver.findComponent(ON.within(ON.id(activeDismissDialog.dialogId)).type('Button'))
      expect(closeButton).not().assertNull();
      // 判断自动关闭能力
      await closeButton.click();
      await testDialogCosed(activeDismissDialog.dialogId);
    });
    it('SheetTest', 0, async () => {
      await findButtonInSamplePageAndClick('能够动态调整高度的底部弹窗');
      let sheet = await getTopDialog();
      expect(sheet.type).assertEqual(DialogType.SHEET);
      // 等待展示
      let dialogComponent = await waitForDialogDisplayByDialog(sheet)
      let initRect = await dialogComponent.getBounds();
      let contentFlag = ON.within(ON.id(sheet.dialogId)).text('登录我的账号');
      let initContent = await driver.findComponent(contentFlag);
      expect(initContent).assertNull();
      // 变换高度 测试滑动 与 关闭
      let sheetDragBar = await driver.findComponent(ON.type(Constants.SHEET_DRAG_BAR_FLAG));
      await dragComponent(sheetDragBar, 0, uiContext.vp2px(-100))
      let adjustedRect = await dialogComponent.getBounds();
      let adjustedContent = await driver.findComponent(contentFlag);
      // 内容与高度变更
      expect(adjustedContent).assertNull();
      expect(adjustedRect.top).assertLess(initRect.top);
      let sheetClose = await driver.findComponent(Constants.SHEET_CLOSE_BUTTON_FLAG);
      await sheetClose.click();
      await testDialogCosed(sheet.dialogId);
    });
    it('DialogStatusTest', 0, async () => {
      let actionButton = await driver.findComponent(ON.isAfter(ON.text('感知弹窗的打开和关闭状态')).type('Toggle'));
      let statusTextComp = await driver.findComponent(ON.text('当前弹窗状态：关闭'));
      expect(actionButton).not().assertNull();
      expect(statusTextComp).not().assertNull();

      await actionButton.click()
      await driver.delayMs(100);
      let dialog = await getTopDialog();
      // 等待展示
      await waitForDialogDisplay(dialog.dialogId);

      let status = await statusTextComp.getText();
      expect(status.slice(7)).assertEqual('打开')

      await actionButton.click()
      await testDialogCosed(dialog.dialogId);
      status = await statusTextComp.getText();
      expect(status.slice(7)).assertEqual('关闭')
    });
  })
  describe('reusePageTest', () => {
    beforeAll(async () => {
      await replaceToMainPage();
      await driver.delayMs(500);
      await findAndClickComponent(CopyCommonConstant.REUSE_EXAMPLE_TITLE);
    })
    beforeEach(async () => {
      await cleanCurentPageDialogs()
    })
    afterAll(async () => {
      await driver.delayMs(500);
    })
    it('createAndDeleteTemplateTest', DEFAULT, async () => {
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_CREATE);
      await findAndClickComponentById(CopyCommonConstant.POPUP_DIRECTLY_BUTTON_ID); // 点击“直接弹出弹窗模板”栏的“点击演示”按钮

      const dialogFlag = ON.text(CopyCommonConstant.TOAST_DISPLAYED_CONTENT);
      let dialogComp = await driver.findComponent(dialogFlag);
      while (!dialogComp) {
        await driver.delayMs(100);
        dialogComp = await driver.findComponent(dialogFlag);
      }
      expect(dialogComp).not().assertNull();
      const dialogCompText = await dialogComp.getText();
      expect(dialogCompText).assertEqual(CopyCommonConstant.TOAST_DISPLAYED_CONTENT);

      await findAndClickComponent(CopyCommonConstant.CLICK_TO_DELETE);
      await findAndClickComponentById(CopyCommonConstant.POPUP_DIRECTLY_BUTTON_ID);
      let displayedMessage = await driver.findComponent(ON.text(CopyCommonConstant.TOAST_DISPLAYED_CONTENT));
      const displayedMessageText = await displayedMessage?.getText();
      expect(displayedMessageText).assertUndefined();
    })

    it('dialogColorModificationTest', DEFAULT, async () => {
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_CREATE);
      await findAndClickComponentById(CopyCommonConstant.POPUP_DIRECTLY_BUTTON_ID); // 点击“直接弹出弹窗模板”栏的“点击演示”按钮
      const myToast1 = await getTopDialog();
      const myToast1BackgroundColor = getComponentAttrsStr(myToast1?.dialogId, 'backgroundColor').replace(/^"|"$/g, '');
      expect(myToast1BackgroundColor).assertEqual(CopyCommonConstant.TOAST_DEFAULT_BACKGROUNDCOLOR);

      await driver.delayMs(1500);
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_MODIFY);
      await findAndClickComponentById(CopyCommonConstant.POPUP_DIRECTLY_BUTTON_ID); // 点击“直接弹出弹窗模板”栏的“点击演示”按钮
      const myToast2 = await getTopDialog();
      const myToast2BackgroundColor = getComponentAttrsStr(myToast2?.dialogId, 'backgroundColor').replace(/^"|"$/g, '');
      expect(myToast2BackgroundColor).not().assertEqual(CopyCommonConstant.TOAST_DEFAULT_BACKGROUNDCOLOR);
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_DELETE);

    })

    // 备注:此处需要测试动画效果，需要人工肉眼判断动画效果是否生效
    it('dialogWithAnimationTest', DEFAULT, async () => {
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_CREATE);
      await findAndClickComponentById(CopyCommonConstant.POPUP_WITH_ANIMATION_BUTTON_ID);
      const myToast = await getTopDialog();
      const curDialog: ESObject = myToast;
      const curAnimationDuration: number = curDialog.builderOptions.duration;
      expect(curAnimationDuration).assertEqual(CopyCommonConstant.TOAST_DISPLAY_DURATION);
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_DELETE);
    })

    it('dialogWithCustomPositionTest', DEFAULT, async () => {
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_CREATE);
      await findAndClickComponentById(CopyCommonConstant.POPUP_WITH_CUSTOM_POSITION_BUTTON_ID);
      const myToast = await getTopDialog();
      await waitForDialogDisplay(myToast?.dialogId);
      const curDialog = await driver.findComponent(ON.id(myToast?.dialogId));
      const boundsCenter = await curDialog.getBoundsCenter();
      const bounds = await curDialog.getBounds();
      expect(boundsCenter.x).assertEqual(screenWidth / 2);
      expect(bounds.top).assertEqual(uiContext.vp2px(CopyCommonConstant.Y_OFFSET));
    })

    it('singletonDialogTest', DEFAULT, async () => {
      await findAndClickComponent(CopyCommonConstant.CLICK_TO_CREATE);
      await findAndClickComponentById(CopyCommonConstant.SINGLETON_DIALOG_ID); // 点击“直接弹出弹窗模板”栏的“点击演示”按钮
      const myToast1 = await getTopDialog();
      expect(myToast1.dialogId).not().assertUndefined();
      await driver.delayMs(1500);

      await findAndClickComponentById(CopyCommonConstant.SINGLETON_DIALOG_ID);
      const myToast2 = await getTopDialog();
      expect(myToast2.dialogId).not().assertUndefined();
      expect(myToast1.dialogId).assertEqual(myToast2.dialogId);
    })

  })
  describe('multiDialogExamplePageTest', () => {
    beforeAll(async () => {
      await replaceToMainPage();
      await driver.delayMs(500);
      await findAndClickComponent(CopyCommonConstant.MULTI_DIALOG_EXAMPLES);
    })
    beforeEach(async () => {
      await cleanCurentPageDialogs()
    })
    it('preventDialogBWhenDialogAIsOpenTest', DEFAULT, async () => {
      await findAndClickComponentById(CopyCommonConstant.DIALOG_A_BINDING_BUTTON);
      const dialogA = await driver.findComponent(ON.text(CopyCommonConstant.DIALOG_A));
      const dialogAText = await dialogA?.getText();
      expect(dialogAText).assertEqual(CopyCommonConstant.DIALOG_A);
      await findAndClickComponentById(CopyCommonConstant.DIALOG_B_BINDING_BUTTON);
      const tipDialog = await driver.findComponent(ON.text(CopyCommonConstant.DIALOG_B_SUPPRESSION));
      const tipDialogText = await tipDialog?.getText();
      expect(tipDialogText).assertEqual(CopyCommonConstant.DIALOG_B_SUPPRESSION);
    })

    it('ensureSingleDialogAtATimeTest', DEFAULT, async () => {
      const curDisplayedDialogsNum = DialogHub.getCurrentPageDialogs().length;
      expect(curDisplayedDialogsNum).assertEqual(0);
      await findAndClickComponentById(CopyCommonConstant.DIALOG_C_BINDING_BUTTON);
      const dialogC = await driver.findComponent(ON.text(CopyCommonConstant.DIALOG_C));
      const dialogCText = await dialogC?.getText();
      expect(dialogCText).assertEqual(CopyCommonConstant.DIALOG_C);
      await findAndClickComponentById(CopyCommonConstant.DIALOG_MULTI_BINDING_BUTTON);

      await findAndClickComponentById(CopyCommonConstant.DIALOG_A_BINDING_BUTTON);
      const dialogA = await driver.findComponent(ON.text(CopyCommonConstant.DIALOG_A));
      const dialogATest = await dialogA.getText();
      expect(dialogATest).assertEqual(CopyCommonConstant.DIALOG_A);
      await findAndClickComponentById(CopyCommonConstant.DIALOG_C_BINDING_BUTTON);
      const tipDialog = await driver.findComponent(ON.text(CopyCommonConstant.DIALOG_C_SUPPRESSION));
      const tipDialogTest = await tipDialog?.getText();
      expect(tipDialogTest).assertEqual(CopyCommonConstant.DIALOG_C_SUPPRESSION);
    })

    it('topmostDialogLayerControlTest', DEFAULT, async () => {
      const clickOrderOfButtons: string[][] = [
        [CopyCommonConstant.DIALOG_D_BINDING_BUTTON, CopyCommonConstant.DIALOG_D],
        [CopyCommonConstant.DIALOG_F_BINDING_BUTTON, CopyCommonConstant.DIALOG_F],
        [CopyCommonConstant.DIALOG_G_BINDING_BUTTON, CopyCommonConstant.DIALOG_G]
      ];
      const exceptedDialogOrder: string[] = [
        CopyCommonConstant.DIALOG_D,
        CopyCommonConstant.DIALOG_F,
        CopyCommonConstant.DIALOG_G
      ];
      await verifyDialogLayerIndexOrder(clickOrderOfButtons, exceptedDialogOrder);
    })

    it('topmostDialogLayerControlTest2', DEFAULT, async () => {
      const clickOrderOfButtons: string[][] = [
        [CopyCommonConstant.DIALOG_G_BINDING_BUTTON, CopyCommonConstant.DIALOG_G],
        [CopyCommonConstant.DIALOG_F_BINDING_BUTTON, CopyCommonConstant.DIALOG_F],
        [CopyCommonConstant.DIALOG_D_BINDING_BUTTON, CopyCommonConstant.DIALOG_D],
      ];
      const exceptedDialogOrder: string[] = [
        CopyCommonConstant.DIALOG_D,
        CopyCommonConstant.DIALOG_F,
        CopyCommonConstant.DIALOG_G
      ];
      await verifyDialogLayerIndexOrder(clickOrderOfButtons, exceptedDialogOrder);
    })

    it('topmostDialogLayerControlTest3', DEFAULT, async () => {
      const clickOrderOfButtons: string[][] = [
        [CopyCommonConstant.DIALOG_G_BINDING_BUTTON, CopyCommonConstant.DIALOG_G],
        [CopyCommonConstant.DIALOG_H_BINDING_BUTTON, CopyCommonConstant.DIALOG_H]
      ];
      const exceptedDialogOrder: string[] = [
        CopyCommonConstant.DIALOG_G
      ];
      await verifyDialogLayerIndexOrder(clickOrderOfButtons, exceptedDialogOrder);
    })

    it('topmostDialogLayerControlTest4', DEFAULT, async () => {
      const clickOrderOfButtons: string[][] = [
        [CopyCommonConstant.DIALOG_H_BINDING_BUTTON, CopyCommonConstant.DIALOG_H],
        [CopyCommonConstant.DIALOG_G_BINDING_BUTTON, CopyCommonConstant.DIALOG_G],
      ];
      const exceptedDialogOrder: string[] = [
        CopyCommonConstant.DIALOG_H,
        CopyCommonConstant.DIALOG_G
      ];
      await verifyDialogLayerIndexOrder(clickOrderOfButtons, exceptedDialogOrder);
    })


  })
  describe('operableExamplePageTest', () => {
    beforeEach(async () => {
      await cleanCurentPageDialogs();
      await replaceToMainPage();
      await driver.delayMs(500);
      await findAndClickComponent('弹窗与页面/用户交互示例');
    })
    it('backPressToPageTest', 0, async () => {
      let receiverContent = '当前配置: 返回手势作用于'
      let textReceiver = await driver.findComponent(ON.text(receiverContent, MatchPattern.STARTS_WITH));
      await findButtonInSamplePageAndClick('返回手势作用于页面');
      expect((await textReceiver.getText()).slice(receiverContent.length)).assertEqual('页面');

      let dialogOneContent = '弹出普通弹窗1';
      await findButtonInSamplePageAndClick(dialogOneContent);
      await driver.delayMs(200);
      let dialogOne = await getTopDialog();
      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(dialogOne.dialogId))).assertNull();

      await findAndClickComponent('弹窗与页面/用户交互示例');

      let interceptDialogContent = '弹出不响应返回手势弹窗3';
      await findButtonInSamplePageAndClick(interceptDialogContent);
      await driver.delayMs(200);
      let interceptDialog = await getTopDialog();
      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(interceptDialog.dialogId))).assertNull();
    })
    it('backPressToDialogTest', 0, async () => {
      let counterContent = '当前配置: 返回手势作用于';
      await findButtonInSamplePageAndClick('返回手势作用于弹窗');
      await driver.delayMs(200);
      let counterComp = await driver.findComponent(ON.text(counterContent, MatchPattern.STARTS_WITH));
      expect((await counterComp.getText()).slice(counterContent.length)).assertEqual('弹窗');

      await findButtonInSamplePageAndClick('弹出普通弹窗1');
      await driver.delayMs(200);
      let dialogOne = await getTopDialog();
      let navRouterCall = () => {
        throw new Error('功能异常，出现异常的路由跳转')
      }
      // 此时不应该有路由跳转
      uiContext.getUIObserver().on("navDestinationSwitch", navRouterCall)
      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(dialogOne.dialogId))).assertNull();
      uiContext.getUIObserver().off("navDestinationSwitch", navRouterCall);

      await findButtonInSamplePageAndClick('弹出普通弹窗1');
      await driver.delayMs(200);
      dialogOne = await getTopDialog();
      await driver.delayMs(200);
      await findAndClickComponent('打开普通弹窗2');
      let dialogTwo = await getTopDialog();

      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(dialogOne.dialogId))).not().assertNull();
      expect(await driver.findComponent(ON.id(dialogTwo.dialogId))).assertNull();
      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(dialogOne.dialogId))).assertNull();
      expect(await driver.findComponent(ON.id(dialogTwo.dialogId))).assertNull();

      let interceptDialogContent = '弹出不响应返回手势弹窗3';
      await findButtonInSamplePageAndClick(interceptDialogContent);
      await driver.delayMs(200);
      let interceptDialog = await getTopDialog();
      await driver.pressBack();
      await driver.delayMs(200);
      expect(await driver.findComponent(ON.id(interceptDialog.dialogId))).not().assertNull();
    })
    it('gestureTest', 0, async () => {
      let sampleButton = await findButtonInSamplePageAndClick('可透传手势的弹窗');
      let toastDialog = await getTopDialog();
      expect(toastDialog.type).assertEqual(DialogType.TOAST);
      let dialogComp = await waitForDialogDisplay(toastDialog.dialogId)
      // 判定透传效果
      await testDialogPassThroughGesture(dialogComp, sampleButton, true);
    })
    it('sendMessageTest', 0, async () => {
      let pageReceiver = await driver.findComponent(ON.isAfter(ON.text('标签名:')))
      await findButtonInSamplePageAndClick('需要向页面返回数据的弹窗');
      let dialog = await getTopDialog();
      expect(dialog.type).assertEqual(DialogType.CUSTOM);
      await waitForDialogDisplay(dialog.dialogId)
      let dialogInput = await driver.findComponent(ON.within(ON.id(dialog.dialogId)).type('TextInput'))
      let submitButton = await driver.findComponent(ON.within(ON.id(dialog.dialogId)).type('Button').text('储存'))
      expect(!!(dialogInput && submitButton && pageReceiver)).assertTrue();
      // 输入
      await dialogInput.click()
      let testMessage = JSON.stringify(new Date().getTime());
      await dialogInput.inputText(testMessage);
      // 关闭并提交
      await submitButton.click()
      await testDialogCosed(dialog.dialogId);
      let receiveText = (await pageReceiver.getText());
      expect(receiveText).assertEqual(testMessage)
    })
    it('receiveMessageTest', 0, async () => {
      await findButtonInSamplePageAndClick('父页面可刷新弹窗内容的弹窗');
      let dialog = await getTopDialog();
      expect(dialog.type).assertEqual(DialogType.CUSTOM);
      await driver.delayMs(3000);
      expect((await driver.findComponent(ON.id(dialog.dialogId)))).assertNull();
    })
    it('dialogNumberTest', 0, async () => {
      let counterContent = '当前页面弹窗数: ';
      await findButtonInSamplePageAndClick('返回手势作用于弹窗');
      await driver.delayMs(200);
      let counterComp = await driver.findComponent(ON.isAfter(ON.text(counterContent)));
      expect((await counterComp.getText())).assertEqual('0');

      await driver.delayMs(200);
      await findButtonInSamplePageAndClick('弹出普通弹窗1');
      await driver.delayMs(200);
      expect((await counterComp.getText())).assertEqual('1');

      await driver.delayMs(200);
      await findAndClickComponent('打开普通弹窗2');
      await driver.delayMs(200);
      expect((await counterComp.getText())).assertEqual('2');

      await driver.pressBack();
      await driver.delayMs(200);
      expect((await counterComp.getText())).assertEqual('1');
      await driver.pressBack();
      await driver.delayMs(200);
      expect((await counterComp.getText())).assertEqual('0');
    })
    it('routerNavTest', 0, async () => {
      let windowRect = mainWindow.getWindowProperties().windowRect;
      await driver.swipe(windowRect.width / 2, windowRect.height / 2, windowRect.width / 2, 0, 2000);
      await driver.delayMs(200);
      await findButtonInSamplePageAndClick('存在跳转链接的弹窗(Router)');
      let dialog = await getTopDialog();
      expect(dialog.type).assertEqual(DialogType.CUSTOM);
      await waitForDialogDisplay(dialog.dialogId)
      await findAndClickComponent('同意')
      await driver.delayMs(500);
      expect((await driver.findComponent(ON.id(dialog.dialogId)))).assertNull();
    })
    it('navigationNavTest', 0, async () => {
      let windowRect = mainWindow.getWindowProperties().windowRect;
      await driver.swipe(windowRect.width / 2, windowRect.height / 2, windowRect.width / 2, 0, 2000);
      await driver.delayMs(200);
      await findButtonInSamplePageAndClick('存在跳转链接的弹窗(Navigation)');
      let dialog = await getTopDialog();
      expect(dialog.type).assertEqual(DialogType.CUSTOM);
      await waitForDialogDisplay(dialog.dialogId);
      await findAndClickComponent('同意');
      await driver.delayMs(500);
      expect((await driver.findComponent(ON.id(dialog.dialogId)))).assertNull();
    })
    it('displayPositionTest', 0, async () => {
      let windowRect = mainWindow.getWindowProperties().windowRect;
      await driver.swipe(windowRect.width / 2, windowRect.height / 2, windowRect.width / 2, 0, 2000);
      await driver.delayMs(500);
      await findButtonInSamplePageAndClick('在特定分屏展示弹窗', 200, MatchPattern.CONTAINS);
      let dialog = await getTopDialog();
      expect(dialog.type).assertEqual(DialogType.CUSTOM);
      await waitForDialogDisplay(dialog.dialogId);
      await findAndClickComponent('同意');
      await driver.delayMs(500);
      expect((await driver.findComponent(ON.id(dialog.dialogId)))).assertNull();
    })
  })
}

async function replaceToMainPage() {
  await driver.delayMs(500);
  uiContext?.getRouter().clear()
  uiContext?.getRouter().pushUrl({ url: 'pages/Index' })
}

/**
 * 按照clickOrderOfButtons中button的点击顺序弹出的弹窗层级顺序是否和期望的弹窗弹出顺序一致
 * @param clickOrderOfButtons, 存储的是button id和点击该按钮弹窗显示的text内容, 按照index升序依次点击该数组中id对应的button
 * @param exceptedDialogOrder, 期望按照clickOrderOfButtons顺序点击弹出的弹窗层级顺序
 */
async function verifyDialogLayerIndexOrder(clickOrderOfButtons: string[][], exceptedDialogOrder: string[]) {
  if (!clickOrderOfButtons || !exceptedDialogOrder) {
    return;
  }
  // 点击操作
  await findAndClickComponentById(clickOrderOfButtons[0][0]);
  let dialogDContent = await driver.findComponent(ON.text(clickOrderOfButtons[0][1]));
  expect(dialogDContent).not().assertUndefined();
  const dialogD = await getTopDialog();
  const overlayNode = uiContext.getFrameNodeById(dialogD.dialogId)?.getParent()?.getParent()?.getParent();
  // 点击操作
  for (let i = 1; i < clickOrderOfButtons.length; i++) {
    await findAndClickComponentById(clickOrderOfButtons[i][0]);
    let dialogGContent = await driver.findComponent(ON.text(clickOrderOfButtons[i][1]));
    expect(dialogGContent).not().assertUndefined();
  }
  // 获取组件树上弹窗的层级顺序
  let actualDialogOrder: string[] = []
  for (let i = 0; i < (overlayNode?.getChildrenCount() ?? 0); i++) {
    const contentNode = overlayNode?.getChild(i)?.getFirstChild()?.getFirstChild();
    const curText = await (await driver.findComponent(ON.type('Text').within(ON.id(contentNode?.getId())))).getText()
    actualDialogOrder.push(curText);
  }
  expect(arraysEqual(actualDialogOrder, exceptedDialogOrder)).assertTrue();
}

function arraysEqual(a: string[], b: string[]): boolean {
  if (a === b) {
    return true;
  } // 相同引用
  if (!a || !b || a.length !== b.length) {
    return false;
  }
  return a.every((value, index) => value === b[index]);
}

async function findButtonInSamplePageAndClick(title: string, delay: number = 200,
  pattern: MatchPattern = MatchPattern.EQUALS) {
  let button = await driver.findComponent(ON.isAfter(ON.text(title, pattern)).type('Button'))
  expect(button).not().assertNull()
  await button.click();
  await driver.delayMs(delay);
  return button;
}

async function getBoundsCenter(bound: Rect) {
  return (bound.left + bound.right) / 2
}