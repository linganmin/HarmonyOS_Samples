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
import { MediaData, PlayerSpeed } from '../model/CommonModel';


export class CommonConstant {
  /**
   * Ten percent wide
   */
  static readonly TEN_PERCENT_WIDTH: string = '10%';
  /**
   * Ten percent high
   */
  static readonly TEN_PERCENT_HEIGHT: string = '10%';
  /**
   * Twenty percent wide
   */
  static readonly TWENTY_PERCENT_WIDTH: string = '20%';
  /**
   * Twenty percent high
   */
  static readonly TWENTY_PERCENT_HEIGHT: string = '20%';
  /**
   * Twenty-five percent wide
   */
  static readonly TWENTY_FIVE_PERCENT_WIDTH: string = '25%';
  /**
   * Thirty percent wide
   */
  static readonly THIRTY_PERCENT_WIDTH: string = '30%';
  /**
   * Thirty percent high
   */
  static readonly THIRTY_PERCENT_HEIGHT: string = '30%';
  /**
   * Forty percent high
   */
  static readonly FORTY_PERCENT_HEIGHT: string = '40%';
  /**
   * Fifty percent wide
   */
  static readonly FIFTY_PERCENT_WIDTH: string = '50%';
  /**
   * Fifty percent high
   */
  static readonly FIFTY_PERCENT_HEIGHT: string = '50%';
  /**
   * Sixty percent high
   */
  static readonly SIXTY_PERCENT_WIDTH: string = '60%';
  /**
   * Seventy percent wide
   */
  static readonly SEVENTY_PERCENT_WIDTH: string = '70%';
  /**
   * Seventy percent high
   */
  static readonly SEVENTY_PERCENT_HEIGHT: string = '70%';
  /**
   * Seventy-five percent high
   */
  static readonly SEVENTY_FIVE_PERCENT_HEIGHT: string = '75%';
  /**
   * Eighty percent wide
   */
  static readonly EIGHTY_PERCENT_WIDTH: string = '80%';
  /**
   * Eighty-five percent wide
   */
  static readonly EIGHTY_FIVE_PERCENT_WIDTH: string = '85%';
  /**
   * Ninety percent wide
   */
  static readonly NINETY_PERCENT_WIDTH: string = '90%';
  /**
   * Ninety-five percent wide
   */
  static readonly NINETY_FIVE_PERCENT_WIDTH: string = '95%';
  /**
   * 100% wide
   */
  static readonly FULL_PERCENT_WIDTH: string = '100%';
  /**
   * 100% high
   */
  static readonly FULL_PERCENT_HEIGHT: string = '100%';
  /**
   * The system customizes the background color
   */
  static readonly SYSTEM_CUSTOM_BACKGROUND_COLOR: string = '#F1F3F5';
  /**
   * Pause the width of the icon
   */
  static readonly PAUSE_IMAGE_WIDTH: string = '56vp';
  /**
   * Pause the high of the icon
   */
  static readonly PAUSE_IMAGE_HEIGHT: string = '56vp';
  /**
   * The default width of your surface
   */
  static readonly SURFACE_WIDTH: number = 1920;
  /**
   * The default high of your surface
   */
  static readonly SURFACE_HEIGHT: number = 1080;
  /**
   * Z-axis index level 1
   */
  static readonly Z_INDEX_LEVER_1: number = 1;
  /**
   * Z-axis index level 2
   */
  static readonly Z_INDEX_LEVER_2: number = 2;
  /**
   * Z-axis index level 3
   */
  static readonly Z_INDEX_LEVER_3: number = 3;
  /**
   * The default number of Swiper caches
   */
  static readonly DEFAULT_SWIPER_CACHE_COUNT: number = 2;
  /**
   * Animation duration
   */
  static readonly DURATION_TIME: number = 300;
  /**
   * Customize the component text color
   */
  static readonly CUSTOM_FONT_COLOR: string = '#FFFFFF';
  /**
   * The text of the custom component is bolded
   */
  static readonly CUSTOM_FONT_WEIGHT: string | FontWeight = FontWeight.Bold;
  /**
   * Customize the component button icon
   */
  static readonly CUSTOM_IMAGE: Resource[] =
    [$r('app.media.like_1'), $r('app.media.comments'), $r('app.media.share'), $r('app.media.collection'),
      $r('app.media.fullScreenPlay'), $r('app.media.full_screen'), $r('app.media.like')];
  /**
   * Share icon width
   */
  static readonly SHARE_ICON_WIDTH_OR_HEIGHT: number = 35;
  /**
   * Customize the component button width
   */
  static readonly CUSTOM_BUTTON_WIDTH: number = 140;
  /**
   * Customize the component button height
   */
  static readonly CUSTOM_IMAGE_WIDTH_OR_HEIGHT: number = 40;
  /**
   * Video play button
   */
  static readonly VIDEO_FILL_PLAY: Resource = $r('app.media.play_fill');
  /**
   * The maximum number of lines in the video introduction information
   */
  static readonly VIDEO_TEXT_MAX_LINES: number = 2;
  /**
   * Font transparency
   */
  static readonly TEXT_OPACITY: number = 0.7;
  /**
   * Search button icon
   */
  static readonly SEARCH_ICON: Resource = $r('app.media.search');
  /**
   * Search button icon width
   */
  static readonly SEARCH_ICON_WIDTH: number = 24;

  /**
   * Watch in full screen
   */
  static getRequestFullScreen(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.REQUEST_FULL_SCREEN')) || '';
  }

  /**
   * Short video full screen
   */
  static getFullScreenMessage(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.FULL_SCREEN_MESSAGE')) || '';
  }

  /**
   * Background color in the comment section
   */
  static readonly LIVE_COMMENTS_BACKGROUND_COLOR: string = '#FFFFFF';
  /**
   * The spacing of the list in the comment section
   */
  static readonly LIVE_COMMENTS_LIST_SPACE: number = 16;

  /**
   * Text content at the top of the comment section
   */
  static getLiveCommentsText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.LIVE_COMMENTS_TEXT')) || '';
  }

  /**
   * Text spacing at the top of the comment section
   */
  static readonly LIVE_COMMENTS_TEXT_MARGIN: number = 10;
  /**
   * The Y-axis of the pop-up window in the comment area is offset by 0
   */
  static readonly LIVE_COMMENTS_TRANSLATE_Y_ZERO: number = 0;
  /**
   * The Y-axis of the pop-up window in the comment area is offset by 100%
   */
  static readonly LIVE_COMMENTS_TRANSLATE_Y_FULL: string = '100%';
  /**
   * The size of the text at the top of the comment section
   */
  static readonly LIVE_COMMENTS_TEXT_FONTSIZE: number = 20;
  /**
   * The size of the content in the comment section
   */
  static readonly LIVE_COMMENTS_REPLY_TEXT_FONTSIZE: number = 14;
  /**
   * Comment section text color
   */
  static readonly LIVE_COMMENTS_FONT_COLOR: string = '#CCCCCC';
  /**
   * Avatar in the comment section
   */
  static readonly LIVE_COMMENTS_AVATAR: Resource[] =
    [$r('app.media.live_comments_avatar_1'), $r('app.media.live_comments_avatar_2'),
      $r('app.media.live_comments_avatar_3'), $r('app.media.live_comments_avatar_4'),
      $r('app.media.live_comments_avatar_5'), $r('app.media.live_comments_avatar_1'),
      $r('app.media.live_comments_avatar_2'), $r('app.media.live_comments_avatar_3'),
      $r('app.media.live_comments_avatar_4'), $r('app.media.live_comments_avatar_5')];
  /**
   * Avatar width in the comment section
   */
  static readonly LIVE_COMMENTS_AVATAR_WIDTH: number | string = 40;
  /**
   * The width of the like icon in the comment section
   */
  static readonly LIVE_COMMENTS_LIKE_WIDTH: number | string = 20;
  /**
   * The comment section closes the width of the icon
   */
  static readonly LIVE_COMMENTS_CLOSE_WIDTH: number | string = 40;
  /**
   * The left spacing in the comment section
   */
  static readonly LIVE_COMMENTS_LEFT_MARGIN: number = 10;
  /**
   * Spacing at the bottom of the comment section
   */
  static readonly LIVE_COMMENTS_BOTTOM_MARGIN: number = 5;
  /**
   * The value of the spacing inside the comment section
   */
  static readonly LIVE_COMMENTS_PADDING: number = 20;
  /**
   * The spacing at the bottom of the username in the comment section
   */
  static readonly LIVE_COMMENTS_USERNAME_BOTTOM_MARGIN: number | string = 10;
  /**
   * Comment section username
   */
  static readonly LIVE_COMMENTS_USERNAME: ResourceStr[] =
    [$r('app.string.LIVE_COMMENTS_USERNAME_1'), $r('app.string.LIVE_COMMENTS_USERNAME_2'),
      $r('app.string.LIVE_COMMENTS_USERNAME_3'), $r('app.string.LIVE_COMMENTS_USERNAME_4'),
      $r('app.string.LIVE_COMMENTS_USERNAME_5'), $r('app.string.LIVE_COMMENTS_USERNAME_6'),
      $r('app.string.LIVE_COMMENTS_USERNAME_7'), $r('app.string.LIVE_COMMENTS_USERNAME_8'),
      $r('app.string.LIVE_COMMENTS_USERNAME_9'), $r('app.string.LIVE_COMMENTS_USERNAME_10')];
  /**
   * Content in the comment section
   */
  static readonly LIVE_COMMENTS_CONTENT: ResourceStr[] =
    [$r('app.string.LIVE_COMMENTS_CONTENT_1'), $r('app.string.LIVE_COMMENTS_CONTENT_2'),
      $r('app.string.LIVE_COMMENTS_CONTENT_1'), $r('app.string.LIVE_COMMENTS_CONTENT_2'),
      $r('app.string.LIVE_COMMENTS_CONTENT_1'), $r('app.string.LIVE_COMMENTS_CONTENT_2'),
      $r('app.string.LIVE_COMMENTS_CONTENT_1'), $r('app.string.LIVE_COMMENTS_CONTENT_2'),
      $r('app.string.LIVE_COMMENTS_CONTENT_1'), $r('app.string.LIVE_COMMENTS_CONTENT_2')];
  /**
   * Like in the comment section
   */
  static readonly LIVE_COMMENTS_LIKE_ICON: Resource = $r('app.media.live_comments_like');
  /**
   * The number of likes in the comment section
   */
  static readonly LIVE_COMMENTS_LIKE_NUM: number[] = [876, 500, 216, 324, 153, 452, 502, 723, 401, 322];
  /**
   * Number of likes in the comment section, text size
   */
  static readonly LIVE_COMMENTS_LIKE_NUM_FONT_SIZE: number = 18;
  /**
   * Like the right spacing in the comment area
   */
  static readonly LIVE_COMMENTS_LIKE_NUM_MARGIN_RIGHT: number[] = [5, 15];
  /**
   * Comment section time
   */
  static readonly LIVE_COMMENTS_DATE: ResourceStr[] =
    [$r('app.string.LIVE_COMMENTS_DATE_2'), $r('app.string.LIVE_COMMENTS_DATE_1'),
      $r('app.string.LIVE_COMMENTS_DATE_2'), $r('app.string.LIVE_COMMENTS_DATE_1'),
      $r('app.string.LIVE_COMMENTS_DATE_2'), $r('app.string.LIVE_COMMENTS_DATE_1'),
      $r('app.string.LIVE_COMMENTS_DATE_2'), $r('app.string.LIVE_COMMENTS_DATE_1'),
      $r('app.string.LIVE_COMMENTS_DATE_2'), $r('app.string.LIVE_COMMENTS_DATE_1')];
  /**
   * Comment area area
   */
  static readonly LIVE_COMMENTS_FROM: ResourceStr[] =
    [$r('app.string.LIVE_COMMENTS_FROM_1'), $r('app.string.LIVE_COMMENTS_FROM_2'),
      $r('app.string.LIVE_COMMENTS_FROM_3'), $r('app.string.LIVE_COMMENTS_FROM_4'),
      $r('app.string.LIVE_COMMENTS_FROM_5'), $r('app.string.LIVE_COMMENTS_FROM_1'),
      $r('app.string.LIVE_COMMENTS_FROM_2'), $r('app.string.LIVE_COMMENTS_FROM_3'),
      $r('app.string.LIVE_COMMENTS_FROM_4'), $r('app.string.LIVE_COMMENTS_FROM_5')];
  /**
   * Reply in the comment section
   */
  static readonly LIVE_COMMENTS_REPLY: ResourceStr = $r('app.string.LIVE_COMMENTS_REPLY');
  /**
   * Comment replies on the spacing
   */
  static readonly LIVE_COMMENTS_REPLY_MARGIN_TOP: number = 10;
  /**
   * The number of replies to the comment
   */
  static readonly LIVE_COMMENTS_REPLY_NUM: ResourceStr = $r('app.string.LIVE_COMMENTS_REPLY_NUM');
  /**
   * Comments: See all reply text colors
   */
  static readonly LIVE_COMMENTS_LOOK_REPLY_FONT_COLOR: string = '#ff4580f5';
  /**
   * Reply to the text color in the comment section
   */
  static readonly LIVE_COMMENTS_REPLY_FONT_COLOR: string = '#000000';
  /**
   * The background color of the area in the comment area
   */
  static readonly LIVE_COMMENTS_REPLY_BACKGROUND_COLOR: string = '#EEEEEE';
  /**
   * Comment area, area background, rounded corners
   */
  static readonly LIVE_COMMENTS_REPLY_BACKGROUND_RADIUS: number = 15;
  /**
   * The comment area replies to the upper and lower spacing of the text
   */
  static readonly LIVE_COMMENTS_REPLY_MARGIN: number | string = 10;
  /**
   * Reply to the text content in the comment area
   */
  static readonly LIVE_COMMENTS_REPLY_TEXT: ResourceStr[] =
    [$r('app.string.LIVE_COMMENTS_REPLY_TEXT_1'), $r('app.string.LIVE_COMMENTS_REPLY_TEXT_2')];

  /**
   * Enter the content of the box in the comment area
   */
  static getLiveCommentsTextInputPlaceholder(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.LIVE_COMMENTS_TEXT_INPUT_PLACEHOLDER')) ||
      '';
  }

  /**
   * Icon at the bottom of the comment section
   */
  static readonly LIVE_COMMENTS_BOTTOM_IMAGE: Resource = $r('app.media.comments_bottom_image');
  /**
   * Send icon width at the bottom of the comment section
   */
  static readonly LIVE_COMMENTS_BOTTOM_IMAGE_WIDTH: number = 35;
  /**
   * Double-speed text
   */
  static readonly VIDEO_FAST_SPEED: PlayerSpeed[] = [{
    text: 0.75,
    playbackSpeed: 0
  }, {
    text: 1.0,
    playbackSpeed: 1
  }, {
    text: 1.5,
    playbackSpeed: 6
  }, {
    text: 2,
    playbackSpeed: 4
  }];

  /**
   * Double speed prompt window
   */
  static getVideoFastSpeedToast(uiContext: UIContext): string[] {
    return [uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.VIDEO_FAST_SPEED_TOAST_TURN')) ||
      '',
      uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.VIDEO_FAST_SPEED_TOAST_XSpeed')) || ''];
  }

  /**
   * Double speed prompt window spacing
   */
  static readonly VIDEO_FAST_SPEED_TOAST_MARGIN: number = 10;

  /**
   * Straight board machine double speed title
   */
  static getFastSpeedTopText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.FAST_SPEED_TOP_TEXT')) || '';
  }

  /**
   * Straight board speed title font size
   */
  static readonly FAST_SPEED_TOP_TEXT_FONT_SIZE: number = 22;
  /**
   * Double the width of the pop-up window
   */
  static readonly FOLD_FAST_SPEED_WIDTH: number[] = [200, 150];
  /**
   * The height of the pop-up window at double speed
   */
  static readonly FOLD_FAST_SPEED_HEIGHT: number = 35;
  /**
   * Double-speed pop-up offset
   */
  static readonly FOLD_FAST_SPEED_OFFSET: number[] = [0, 60, 250];
  /**
   * Rounded corners of the pop-up window at double speed
   */
  static readonly FOLD_FAST_SPEED_CORNER_RADIUS: number[] = [10, 32];
  /**
   * The rounded corners of the double-speed pop-up window above the straight board machine
   */
  static readonly FAST_SPEED_TOP_BORDER_RADIUS: number = 20;
  /**
   * Rounded corners of the double-speed pop-up window under the straight board machine
   */
  static readonly FAST_SPEED_BOTTOM_BORDER_RADIUS: number = 0;
  /**
   * The folding screen double-speed pop-up window has rounded corners
   */
  static readonly FOLD_FAST_SPEED_BORDER_RADIUS: number = 10;

  /**
   * The text of the button at the bottom of the folding screen double speed pop-up window
   */
  static getFoldFastSpeedBottomButtonText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.FOLD_FAST_SPEED_BOTTOM_BUTTON_TEXT')) ||
      '';
  }

  /**
   * The corners of the button at the bottom of the folding screen double speed pop-up window
   */
  static readonly FOLD_FAST_SPEED_BOTTOM_BUTTON_RADIUS: number = 10;

  /**
   * Video text at double speed
   */
  static getFastSpeedText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.FAST_SPEED_TEXT')) || '';
  }

  /**
   * The video is doubled and bolded
   */
  static readonly FAST_SPEED_TEXT_FONT_WEIGHT: FontWeight = FontWeight.Bold;
  /**
   * The text size of the video is doubled
   */
  static readonly FAST_SPEED_FONT_SIZE: number = 18;
  /**
   * Right spacing value
   */
  static readonly RIGHT_MARGIN: number = 10;
  /**
   * Double-speed text click on the color
   */
  static readonly SPEED_TEXT_CLICK_FONT_COLOR: string | Color = '#ffe70404';
  /**
   * Click on the background color of the pop-up window
   */
  static readonly SPEED_TEXT_CLICK_BACKGROUND: string | Color = '#80cccccc';
  /**
   * Multiply text color
   */
  static readonly SPEED_TEX_FONT_COLOR: string | Color = '#000000';
  /**
   * The color of the pop-up window at double speed
   */
  static readonly SPEED_BACKGROUND_COLOR: string | Color = '#FFFFFF';
  /**
   * The pop-up window is offset
   */
  static readonly SPEED_OFFSET: number[] = [0, 100];
  /**
   * Icon and text spacing
   */
  static readonly ICON_TEXT_MARGIN: number = 8;
  /**
   * Text-to-text spacing
   */
  static readonly TEXT_TEXT_MARGIN: number[] = [0, 12];
  /**
   * Speed icon
   */
  static readonly SPEED_IMAGE: Resource = $r('app.media.speed_image');
  /**
   * The size of the multiplier icon
   */
  static readonly SPEED_IMAGE_WIDTH: number = 25;
  /**
   * Double the bottom button spacing
   */
  static readonly SPEED_BUTTON_MARGIN: number = 12;
  /**
   * Speed up the bottom button text color
   */
  static readonly SPEED_BUTTON_FONT_COLOR: string = '#0A59F7';
  /**
   * The interval between closing the speed indicator window
   */
  static readonly CLOSE_SPEED_TOAST_DURATION: number = 1000;
  /**
   * Report icon
   */
  static readonly REPORT_IMAGE: Resource = $r('app.media.report_image');

  /**
   * Report text
   */
  static getReportText(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.REPORT_TEXT')) || '';
  }

  /**
   * Report icon size
   */
  static readonly REPORT_IMAGE_WIDTH: number = 25;
  /**
   * Report icon spacing
   */
  static readonly REPORT_IMAGE_MARGIN: number = 15;
  /**
   * Straight plate machine width
   */
  static readonly PHONE_WIDTH: number = 388;
  /**
   * Folding screen phone width
   */
  static readonly FOLD_PHONE_WIDTH: number = 712;
  /**
   * Close icon
   */
  static readonly IMAGE_CLOSE: Resource = $r('app.media.comments_close');
  /**
   * Turn off icon width
   */
  static readonly IMAGE_CLOSE_WIDTH: number = 40;
  /**
   * Time text size
   */
  static readonly TIME_TEXT_FRONT_SIZE: number = 14;
  /**
   * Five upper spacing
   */
  static readonly FiVE_TOP_PADDING: number = 5;
  /**
   * Five down spacing
   */
  static readonly FiVE_BOTTOM_PADDING: number = 5;
  /**
   * Ten on the spacing
   */
  static readonly TEN_TOP_PADDING: number = 10;
  /**
   * Ten right spacing
   */
  static readonly TEN_RIGHT_PADDING: number = 10;
  /**
   * Twenty left spacing
   */
  static readonly TWENTY_LEFT_PADDING: number = 20;
  /**
   * Twenty right spacing
   */
  static readonly TWENTY_RIGHT_PADDING: number = 20;
  /**
   * Forty left spacing
   */
  static readonly FORTY_LEFT_PADDING: number = 40;
  /**
   * Forty right spacing
   */
  static readonly FORTY_RIGHT_PADDING: number = 40;
  /**
   * The height of the progress bar
   */
  static readonly PROGRESS_BAR_HEIGHT: number = 20;
  /**
   * Bottom image size
   */
  static readonly BOTTOM_IMAGE_SIZE: number = 30;
  /**
   * The size of the spacing between the text
   */
  static readonly TEXT_SPACE_SIZE: number = 15;
  /**
   * The size of the spacing between buttons
   */
  static readonly BUTTON_SPACE_SIZE: number = 20;
  /**
   * The size of the button text spacing
   */
  static readonly BUTTON_TEXT_SPACE_SIZE: number = 5;
  /**
   * Avatar edge width
   */
  static readonly IMAGE_BORDER_WIDTH: number = 2;
  /**
   * The upper left corner returns the width
   */
  static readonly RETURN_BUTTON_WIDTH: number = 30;
  /**
   * The top left corner returns the height
   */
  static readonly RETURN_BUTTON_HEIGHT: number = 30;
  /**
   * Full-screen top-left font
   */
  static readonly FULL_SCREEN_TEXT_FONT_SIZE: number = 24;
  /**
   * X offset
   */
  static readonly X_OFFSET: number[] = [-20, 20, 100];
  /**
   * Y offset
   */
  static readonly Y_OFFSET: number[] = [-70, -60, -30, 60];
  /**
   * Full-screen button text size
   */
  static readonly FULL_SCREEN_TEXT_WIDTH: number = 20;
  /**
   * Full screen returns to hidden time
   */
  static readonly HIDE_TIME: number = 3000;
  /**
   * The size of the rounded corners of the right avatar border
   */
  static readonly IMAGE_BORDER_RADIUS: number = 20;
  /**
   * Full-screen button offset
   */
  static readonly OFFSET_Y: number = 50;
  /**
   * The maximum size of the text in the lower-left corner
   */
  static readonly CONSTRAINT_SIZE_MAX_WIDTH: string = 'calc(100% - 100vp)';

  /**
   * Video information
   */
  static getMediaData(uiContext: UIContext): MediaData[] {
    return [{
      likesNum: 587,
      commentsNum: 245,
      shareNum: 123,
      url: uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.url1')) || '',
      publisherImage: $r('app.media.publisher2'),
      publisherName: $r('app.string.PUBLISHER_NAME_1'),
      mediaIntro: $r('app.string.MEDIA_INFO_1'),
      isLike: false
    }, {
      likesNum: 229,
      commentsNum: 140,
      shareNum: 87,
      url: uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.url2')) || '',
      publisherImage: $r('app.media.publisher1'),
      publisherName: $r('app.string.PUBLISHER_NAME_2'),
      mediaIntro: $r('app.string.MEDIA_INFO_2'),
      isLike: false
    }, {
      likesNum: 166,
      commentsNum: 85,
      shareNum: 42,
      url: uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.url3')) || '',
      publisherImage: $r('app.media.publisher3'),
      publisherName: $r('app.string.PUBLISHER_NAME_3'),
      mediaIntro: $r('app.string.MEDIA_INFO_3'),
      isLike: false
    }, {
      likesNum: 854,
      commentsNum: 213,
      shareNum: 32,
      url: uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.url4')) || '',
      publisherImage: $r('app.media.publisher4'),
      publisherName: $r('app.string.PUBLISHER_NAME_4'),
      mediaIntro: $r('app.string.MEDIA_INFO_4'),
      isLike: false
    }];
  }

  /**
   * Release refresh
   */
  static getReleaseRefresh(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.RELEASE_REFRESH')) || '';
  }

  /**
   * Pull down refresh
   */
  static getRefresh(uiContext: UIContext): string {
    return uiContext.getHostContext()?.resourceManager.getStringSync($r('app.string.REFRESH')) || '';
  }

  /**
   * Pull down refresh text offset
   */
  static readonly REFRESH_OFFSET: number[] = [100, 200];
  /**
   * Pull down refresh text height
   */
  static readonly REFRESH_HEIGHT: number = 40;
}