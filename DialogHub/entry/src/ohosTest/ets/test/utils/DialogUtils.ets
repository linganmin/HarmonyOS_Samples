import { AnimationType, DialogHub, DialogType, InfDialog } from "@hadss/dialoghub"
import { display } from "@kit.ArkUI"
import { Component, ON } from "@kit.TestKit"
import { driver } from "./CommonTestUtil"
import { expect } from "@ohos/hypium"
import { On, Point } from "@ohos.UiTest"
import { Rect } from "@kit.ArkGraphics3D"
import { Constants } from "../constant/Constants"
import { uiContext } from '../DialogHubSampleTest.test'

const ERROR_RATE = 0.18;

export const MODAL_ID = 'hadssDialogModalColumn'

export async function cleanCurentPageDialogs() {
  await driver.delayMs(500);
  let dialogs = DialogHub.getCurrentPageDialogs()
  dialogs.forEach(dialog => {
    dialog.dismiss()
  })
  await driver.delayMs(900);
  expect(DialogHub.getCurrentPageDialogs().length).assertEqual(0);
}

export async function getTopDialog(): Promise<InfDialog> {
  let dialogs = DialogHub.getCurrentPageDialogs()
  while (dialogs.length === 0) {
    dialogs = DialogHub.getCurrentPageDialogs()
    // 每5ms查询一次
    await driver.delayMs(5);
  }
  return dialogs[0];
}

export async function waitForDialogDisplay(dialogId: string, type?: string) {
  let target: On = ON.id(dialogId)
  if (type) {
    target = ON.type(type)
  }
  let dialogComponent = await driver.findComponent(target)
  while (!dialogComponent) {
    dialogComponent = await driver.findComponent(target)
  }
  return dialogComponent;
}

async function testDialogAnimation(dialog: InfDialog, animationType: AnimationType, isInAnimation: boolean,
  expectAnimationTime: number) {
  let dialogFlag = ON.id(dialog.dialogId)
  let dialogComponent = await driver.findComponent(dialogFlag);
  expect(dialogComponent).not().assertNull();

  // 检测进场动画

  let position: Point | null = null;
  let startTime = new Date().getTime();
  while (driver.assertComponentExist(dialogFlag)) {
    let newPosition = await dialogComponent.getBoundsCenter()
    if (position === null) {
      position = newPosition
    } else {
      // 位置变化, 预计x没有变化
      expect(newPosition.x).assertEqual(position.x);
      let distance = newPosition.y - position.y
      if (distance === 0) {
        // 动画结束
        break;
      } else {
        // 向下移动 y变大
        expect(distance).not().assertLessOrEqual(0)
      }
    }
    driver.delayMs(10);
  }
  let inTime = new Date().getTime()
  let animationTime = inTime - startTime
  let errorValue = Math.abs(expectAnimationTime - animationTime);
  expect(errorValue).assertLessOrEqual(expectAnimationTime * ERROR_RATE)
}


export function getComponentRect(componentId: string): Rect {
  let inspectorRectStr = `[${getInfoFromInspector(getInspectorByKey(componentId), 'rect')}]`
  let inspectorRect: number[][] = JSON.parse(inspectorRectStr)
  let rectInfo: Rect = {
    x: inspectorRect[0][0],
    y: inspectorRect[0][1],
    width: inspectorRect[1][0] - inspectorRect[0][0],
    height: inspectorRect[1][1] - inspectorRect[0][1],
  }
  console.log(`Dialo-${componentId} Position ${JSON.stringify(rectInfo)}`)
  return rectInfo
}

export function getComponentAttrsStr(componentId: string, attrName?: string): string {
  if (attrName) {
    return getInfoFromInspector(getInspectorByKey(componentId), attrName)
  } else {
    return getInfoFromInspector(getInspectorByKey(componentId), 'attrs')
  }
}

export async function testDialogAnimationType(dialog: InfDialog, expectAnimationType: AnimationType,
  expectDuration: number = 300) {
  let curDialog: ESObject = dialog;
  let curAnimation: TransitionEffects = curDialog.builderOptions.animation.dialogAnimation;
  let curAnimationDuration: number = curDialog.builderOptions.animation.duration;
  expect(curAnimationDuration).assertEqual(expectDuration);
  expect(curAnimation).assertDeepEquals(getAnimationEffect(expectAnimationType, expectDuration));
}

export async function testDuration(dialogId: string, expectDuration: number) {
  let startTime = new Date().getTime();
  let dialogFlag = ON.id(dialogId)
  let dialogComponent = await driver.findComponent(dialogFlag);
  expect(dialogComponent).not().assertNull();

  // 检测持续时间
  while (await driver.findComponent(dialogFlag)) {
    // 每20ms检测一次
    await driver.delayMs(20);
  }
  let endTime = new Date().getTime();
  let duration = endTime - startTime;
  console.log('durationTest:', duration);
  let errorValue = Math.abs(duration - expectDuration);
  expect(errorValue).assertLessOrEqual(expectDuration * ERROR_RATE);
}

// 拷贝自DialogHub内部的转换方法
function getAnimationEffect(animationType: AnimationType, duration: number = 300): TransitionEffect | undefined {
  switch (animationType) {
    case AnimationType.FADE_IN_AND_OUT:
      return TransitionEffect.OPACITY.animation({ duration: duration })
    case AnimationType.BOTTOM_UP:
      return TransitionEffect.OPACITY.animation({ duration: duration })
        .combine(TransitionEffect.translate({ y: uiContext!.px2vp(display.getDefaultDisplaySync().height) }))
    case AnimationType.UP_DOWN:
      return TransitionEffect.OPACITY.animation({ duration: duration })
        .combine(TransitionEffect.translate({ y: uiContext!.px2vp(-display.getDefaultDisplaySync().height) }))
    case AnimationType.LEFT_TO_RIGHT:
      return TransitionEffect.OPACITY.animation({ duration: duration })
        .combine(TransitionEffect.translate({ x: uiContext!.px2vp(-display.getDefaultDisplaySync().width) }))
    case AnimationType.RIGHT_TO_LEFT:
      return TransitionEffect.OPACITY.animation({ duration: duration })
        .combine(TransitionEffect.translate({ x: uiContext!.px2vp(display.getDefaultDisplaySync().width) }))
  }
  return undefined;
}

export async function testDialogCosed(dialogId: string) {
  await driver.delayMs(100);
  let dialogComp = await driver.findComponent(ON.id(dialogId));
  expect(dialogComp).assertNull();
}

export async function testDialogPassThroughGesture(dialogComp: Component, compareComp: Component,
  isPassThroughGesture = true) {
  let initPosition = await compareComp.getBoundsCenter();
  let dialogArea = await dialogComp.getBoundsCenter();
  await driver.swipe(dialogArea.x, dialogArea.y, dialogArea.x, dialogArea.y - 100);
  await driver.delayMs(500);
  let secondPosition = await compareComp.getBoundsCenter();
  if (isPassThroughGesture) {
    expect(initPosition.y).not().assertEqual(secondPosition.y);
  } else {
    expect(initPosition.y).assertEqual(secondPosition.y);
  }
  // 恢复位置
  await driver.swipe(dialogArea.x, dialogArea.y, dialogArea.x, dialogArea.y + 100);
  await driver.delayMs(500);
}

export function getInfoFromInspector(inspectorInfo: string, attrName: string): string {
  // 主属性
  let firstAttrs = ['ID', 'attrs', 'debugLine', 'rect', 'type']
  let neededInfo = JSON.parse(inspectorInfo) as Record<string, string>;
  if (!firstAttrs.includes(attrName)) {
    // 查找次属性 主要是attrs
    return JSON.stringify(neededInfo[`$attrs`][attrName])
  } else {
    return JSON.stringify(neededInfo[`$${attrName}`])
  }
}

export async function waitForDialogDisplayByDialog(dialog: InfDialog) {
  if (dialog.type === DialogType.SHEET) {
    return await waitForDialogDisplay('', Constants.SHEET_FLAG)
  } else {
    return await waitForDialogDisplay(dialog.dialogId)
  }
}

export async function dragComponent(comp: Component, xMove = 0, yMove = 0) {
  let rect = await comp.getBounds();
  let startX = (rect.left + rect.right) / 2;
  let startY = (rect.bottom + rect.top) / 2;
  await driver.drag(startX, startY, startX + xMove, startY + yMove, 4000);
  await driver.delayMs(500);
}