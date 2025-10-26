/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const logTag: string = 'TitleTextModifier';
const domainId: number = 0x0000;

export class TitleTextModifier implements AttributeModifier<TextAttribute> {
  private readonly MAX_FONT_SIZE_SCALE: number = 1.75;
  private readonly MIN_FONT_SIZE_SCALE: number = 0.7;
  private baseFontSize = $r('sys.float.ohos_id_text_size_headline6');
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * Set text UI properties
   *
   * @param instance - TextAttribute object
   */
  applyNormalAttribute(instance: TextAttribute): void {
    instance
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .layoutWeight(1)
      .height('100%')
      .minFontScale(this.MIN_FONT_SIZE_SCALE)
      .maxFontScale(this.MAX_FONT_SIZE_SCALE)
      .maxFontSize(getSysFontSize(this.baseFontSize, this.MAX_FONT_SIZE_SCALE, this.context, false))
      .minFontSize('14vp')
      .maxLines(2)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
      .fontWeight(FontWeight.Bold)
      .heightAdaptivePolicy(TextHeightAdaptivePolicy.MAX_LINES_FIRST)
  }
}

/**
 * get front size
 *
 * @param fontsBaseSize - the resource ID
 * @param maxFontScale - maximum font scaling ratio
 * @param context - UI ability context
 * @returns { string } the front size
 */
function getFontSize(fontsBaseSize: number, maxFontScale: number, context: common.UIAbilityContext): string {
  const sysFontSizeScale = context.config.fontSizeScale
  if (!sysFontSizeScale || sysFontSizeScale <= 0) {
    hilog.info(domainId, logTag, 'getFontSize sysFontSizeScale error: ' + sysFontSizeScale);
    return `${fontsBaseSize}vp`;
  }

  if (sysFontSizeScale > maxFontScale) {
    return `${fontsBaseSize * maxFontScale}vp`;
  } else {
    return `${fontsBaseSize * sysFontSizeScale}vp`;
  }
}

/**
 * get system front size
 *
 * @param fontsBaseSize - the resource ID
 * @param maxFontScale - maximum font scaling ratio
 * @param context - UI ability context
 * @param canEnlarge - whether to enlarge, default to enlarge
 * @returns { string | ResourceStr } the front size
 */
function getSysFontSize(fontRes: Resource, maxFontScale: number,
  context: common.UIAbilityContext, canEnlarge = true): string | ResourceStr {
  try {
    if (!canEnlarge) {
      return fontRes;
    }
    const fontsBaseSize: number = resourceManager.getSysResourceManager().getNumber(fontRes.id);
    const fontSize = getFontSize(fontsBaseSize, maxFontScale, context);
    return fontSize;
  } catch (e) {
    hilog.info(domainId, logTag, `getSysFontSize error ${e?.message}`);
    return fontRes;
  }
}