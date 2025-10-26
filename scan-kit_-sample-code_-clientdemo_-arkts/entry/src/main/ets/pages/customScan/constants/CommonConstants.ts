/**
 * Common constants of all function
 */
export class CommonConstants {
  /**
   *  Screen status change listener ID
   */
  static readonly COMMON_EVENT_SCREEN_CHANGE: number = 2;

  /**
   *  Screen size change listener ID
   */
  static readonly WINDOW_SIZE_CHANGE: number = 1;

  /**
   *  Height of the close button area
   */
  static readonly TOP_BUTTON_HEIGHT: number = 56;

  /**
   *  Top title margin
   */
  static readonly TITLE_MARGIN_TOP: number = 8;
  /**
   *  Title row height
   */
  static readonly TITLE_MAIN_LINE_HEIGHT: number = 24;

  /**
   *  Flash light height
   */
  static readonly FLASH_HEIGHT: number = 52;
  /**
   *  Flash light bottom margin
   */
  static readonly FLASH_MARGIN_BOTTOM: number = 12;
  /**
   *  Scanning area height
   */
  static readonly PLACEHOLDER_HEIGHT: number = 56;
  /**
   *  Image press area height
   */
  static readonly ICON_PRESS_HEIGHT: number = 72;
  /**
   *  Image press text height
   */
  static readonly ICON_PRESS_TEXT_HEIGHT: number = 80;
  /**
   *  TabBar height
   */
  static readonly TAB_BAR_HEIGHT: number = 32;
  /**
   *  Ai Bottom Bar height
   */
  static readonly AI_BOTTOM_BAR_HEIGHT: number = 40;
  /**
   *  Close icon size
   */
  static readonly CLOSE_IMAGE_SIZE: number = 40;
  /**
   *  SM device padding
   */
  static readonly PADDING_SM: number = 16;
  /**
   *  MD device padding
   */
  static readonly PADDING_MD: number = 24;
  /**
   *  LG device padding
   */
  static readonly PADDING_LG: number = 32;
  /**
   *  SCAN_FONT_SIZE_SCALE_LIMIT
   */
  static readonly SCAN_FONT_SIZE_SCALE_LIMIT_SYMBOL_TEXT: number = 1.45;
  static readonly SCAN_FONT_SIZE_SCALE_LIMIT_TITLE_TEXT: number = 1.75;
  static readonly SCAN_FONT_SIZE_SCALE_LIMIT_DIALOG_TEXT: number = 3.2;

  static readonly GLOBAL_SCAN_IS_DECODING_GALLERY: string = 'scan_is_decoding_gallery';
  static readonly GLOBAL_SCAN_SELECT_A_PICTURE: string = 'scan_select_a_picture';
  static readonly EVENT_SCREEN_OFF: boolean = false;
  static readonly EVENT_SCREEN_ON: boolean = true;
  static readonly DELAY_RETRY_SCAN_TIME: number = 100;
  static readonly MAX_RETRY_SCAN_TIMES: number = 3;
  static readonly GALLERY_AREA_WIDTH_LG: number = 166;
  static readonly GALLERY_AREA_WIDTH_MD: number = 96;
  static readonly GALLERY_MARGIN_LEFT_LG: number = 24;
  static readonly GALLERY_MARGIN_LEFT_MD: number = 12;
  static readonly TIP_MARGIN_TOP: number = 16;
  static readonly TOP_AVOID_HEIGHT_DEFAULT: number = 39;
  static readonly MIN_ZOOM_RATIO: number = 1;
  static readonly MAX_ZOOM_RATIO: number = 4;
}
export enum DisplayRotationAngle {
  ROTATION_0 = 0,
  ROTATION_90 = 1,
  ROTATION_180 = 2,
  ROTATION_270 = 3
};

