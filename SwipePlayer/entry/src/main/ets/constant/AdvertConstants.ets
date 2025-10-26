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
export class AdvertConstants {
  /**
   * Ad headline
   */
  static getAdvertTitle(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_TITLE')) || '';
  }

  /**
   * The spacing between the top and bottom of the ad headline
   */
  static readonly ADVERT_TITLE_MARGIN_TOP_OR_BOTTOM: number = 25;
  /**
   * Ad headline font size
   */
  static readonly ADVERT_TITLE_FONT_SIZE: number = 24;
  /**
   * Advertising Huawei icons
   */
  static readonly ADVERT_HUAWEI_ICON: Resource = $r('app.media.advert_top_image');
  /**
   * Advertising Huawei icon size
   */
  static readonly ADVERT_HUAWEI_ICON_WIDTH: number = 20;
  /**
   * Advertising Huawei icon spacing
   */
  static readonly ADVERT_HUAWEI_ICON_LETTER_SPACING: number = 5;

  /**
   * Advertising slogan
   */
  static getAdvertTextPublicize(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_TEXT_PUBLICIZE')) || '';
  }

  /**
   * Mask on the left side of the folded screen
   */
  static readonly ADVERT_FOLD_LEFT_MASK_IMAGE: Resource = $r('app.media.advert_right_mask');
  /**
   * Advertising pitch
   */
  static readonly ADVERT_PUBLICIZE_IMAGE: Resource = $r('app.media.advert_image');
  /**
   * Folded mask on the right side of the screen
   */
  static readonly ADVERT_FOLD_RIGHT_MASK_IMAGE: Resource = $r('app.media.advert_left_mask');
  /**
   * The size of the pitch image
   */
  static readonly ADVERT_FOLD_PUBLICIZE_IMAGE_WIDTH: number | string = '60%';
  /**
   * Promotional image borders, widths, and rounded corners
   */
  static readonly ADVERT_PUBLICIZE_IMAGE_BORDER: number[] = [1, 15];
  /**
   * The width of the folded screen mask
   */
  static readonly ADVERT_FOLD_MASK_IMAGE_WIDTH: string = '20%';
  /**
   * The height of the folded screen mask
   */
  static readonly ADVERT_FOLD_MASK_IMAGE_HEIGHT: string = '80%';
  /**
   * The width of the ad footprint
   */
  static readonly ADVERT_PLACE_HOLD_WIDTH: string = '100%';
  /**
   * The height of the ad footprint
   */
  static readonly ADVERT_PLACE_HOLD_HEIGHT: string = '60%';
  /**
   * The height of the advertising picture of the straight board machine
   */
  static readonly ADVERT_IMAGE_PUBLICIZE_WIDTH: string = '70%';
  /**
   * The spacing on the advertising picture of the straight board machine
   */
  static readonly ADVERT_IMAGE_PUBLICIZE_TOP_MARGIN: number = 20;
  /**
   * The spacing under the advertising picture of the straight board machine
   */
  static readonly ADVERT_IMAGE_PUBLICIZE_BOTTOM_MARGIN: number = 15;

  /**
   * Introductory text for the advertising pitch
   */
  static getAdvertPublicizeImageIntroText(uiContext: UIContext): string[] {
    return [
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT')) ||
        '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_OFFICIAL')) ||
        ''
    ];
  }
  /**
   * The promotional image describes the size of the text
   */
  static readonly ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_FONT_SIZE: number = 14;
  /**
   * The promotional image describes the size of the text official
   */
  static readonly ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_OFFICIAL_FONT_SIZE: number = 16;
  /**
   * The promotional image introduces the spacing under the text
   */
  static readonly ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_MARGIN_BOTTOM: number = 20;

  /**
   * Bottom text
   */
  static getAdvertBottomText(uiContext: UIContext): string[] {
    return ['￥', '12999',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_BOTTOM_TEXT_STORE')) || '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.ADVERT_BOTTOM_TEXT_MORE')) || ''];
  }

  /**
   * Bottom text spacing
   */
  static readonly ADVERT_BOTTOM_TEXT_MARGIN: number[] = [15, 10];
  /**
   * More icons at the bottom
   */
  static readonly ADVERT_BOTTOM_MORE_ICON: Resource = $r('app.media.advert_more');
  /**
   * Price text color
   */
  static readonly ADVERT_BOTTOM_TEXT_PRICE_FONT_COLOR: string = '#CF0A2C';
  /**
   * More icon width at the bottom
   */
  static readonly ADVERT_BOTTOM_MORE_ICON_WIDTH: number = 10;

  /**
   * The button is not interested in the text
   */
  static getButtonNoInterestText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.BUTTON_NO_INTEREST_TEXT')) || '';
  }

  /**
   * The button is not interested in the right spacing
   */
  static readonly BUTTON_NO_INTEREST_MARGIN_RIGHT: number = 10;
  /**
   * Button is not interested in the background color
   */
  static readonly BUTTON_NO_INTEREST_BACKGROUND_COLOR: string = '#F1F3F5';
  /**
   * The button is not interested in font color
   */
  static readonly BUTTON_NO_INTEREST_FONT_COLOR: string = '#0A59F7';

  /**
   * Button to view the details text
   */
  static getButtonLookDetailText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.BUTTON_LOOK_DETAIL_TEXT')) || '';
  }

  /**
   * Button to view the background color for details
   */
  static readonly BUTTON_LOOK_DETAIL_BACKGROUND_COLOR: string = '#0A59F7';
  /**
   * Button to view the font color for details
   */
  static readonly BUTTON_LOOK_DETAIL_FONT_COLOR: string = '#FFFFFF';
  /**
   * Straight machine button width
   */
  static readonly BUTTON_WIDTH: string = '45%';
  /**
   * The width of the folding screen button
   */
  static readonly FOLD_BUTTON_WIDTH: string = '30%';
  /**
   * Button bottom spacing
   */
  static readonly BUTTON_MARGIN_BOTTOM: number = 10;
  /**
   * In-ad spacing
   */
  static readonly ADVERT_PADDING: number = 10;
  /**
   * Ad Shift
   */
  static readonly ADVERT_OFFSET: number = 130;
  /**
   * Background color of the advertising window
   */
  static readonly ADVERT_BACKGROUND_COLOR: string = '#CDE9E7';
  /**
   * The full-screen background color of the ad page
   */
  static readonly ADVERT_FULL_BACKGROUND_COLOR: string[] = ['#92D2C7', '#429CAC'];
}
