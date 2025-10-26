import { ON, On } from "@kit.TestKit";

export class Constants {
  /**
   * Full screen width.
   */
  static readonly FULL_WIDTH: string = '100%';
  /**
   * Full screen height.
   */
  static readonly FULL_HEIGHT: string = '100%';
  /**
   * custom dialog model name
   */
  static readonly CUSTOM_DIALOG_MODEL_NAME: string = 'MyCustomDialog'
  /**
   * custom dialog constructor name
   */
  static readonly CUSTOM_DIALOG_CONSTRUCTOR_NAME: string = 'CustomBuilder'
  /**
   *  Content to be displayed in a custom type dialog
   */
  static readonly CUSTOM_DIALOG_DISPLAYED_CONTENT: string = 'I am custom dialog !';
  /**
   * Content displayed in the second custom dialog
   */
  static readonly SECOND_CUSTOM_DIALOG_DISPLAYED_CONTENT: string = 'I am second custom dialog !';
  /**
   *  Content to be displayed in a custom type dialog
   */
  static readonly CUSTOM_DIALOG_DISPLAYED_UPDATED_CONTENT: string = 'I am updated custom dialog !';
  /**
   * toast dialog model name
   */
  static readonly TOAST_DIALOG_MODEL_NAME: string = 'MyToastDialog'
  /**
   * toast dialog constructor name
   */
  static readonly TOAST_DIALOG_CONSTRUCTOR_NAME: string = 'ToastBuilder'
  /**
   *  Content to be displayed in a toast type dialog
   */
  static readonly TOAST_DIALOG_DISPLAYED_CONTENT: string = 'I am toast dialog !';
  /**
   *  Content to be displayed in a toast type dialog
   */
  static readonly TOAST_DIALOG_DISPLAYED_UPDATED_CONTENT: string = 'I am updated toast dialog !';
  /**
   * popup dialog model name
   */
  static readonly POPUP_DIALOG_MODEL_NAME: string = 'MyPopupDialog'
  /**
   * popup dialog constructor name
   */
  static readonly POPUP_DIALOG_CONSTRUCTOR_NAME: string = 'PopupBuilder'
  /**
   *  Content to be displayed in a popup type dialog
   */
  static readonly POPUP_DIALOG_DISPLAYED_CONTENT: string = 'I am popup dialog !';
  /**
   *  Content to be displayed in a popup type dialog
   */
  static readonly POPUP_DIALOG_DISPLAYED_UPDATED_CONTENT: string = 'I am updated popup dialog !';
  /**
   * sheet dialog model name
   */
  static readonly SHEET_DIALOG_MODEL_NAME: string = 'MySheetDialog'
  /**
   * sheet dialog constructor name
   */
  static readonly SHEET_DIALOG_CONSTRUCTOR_NAME: string = 'SheetBuilder'
  /**
   *  Content to be displayed in a sheet type dialog
   */
  static readonly SHEET_DIALOG_DISPLAYED_CONTENT: string = 'I am sheet dialog !';
  /**
   *  Content to be displayed in a sheet type dialog
   */
  static readonly SHEET_DIALOG_DISPLAYED_UPDATED_CONTENT: string = 'I am updated sheet dialog !';
  /**
   * the cost time threshold of quick response to in-app click actions, time unit: ms
   */
  static readonly CLICK_RESPONSE_TIME_THRESHOLD: number = 100;
  /**
   * the cost time threshold of operation completion of in-app click actions, time unit: ms
   */
  static readonly OPERATION_COMPLETED_TIME_THRESHOLD: number = 900;
  /**
   * Number of tests
   */
  static readonly ITERATOR_TIMES: number = 1000;
  /**
   * 弹窗蒙层的Id
   */
  static readonly DIALOG_MODEL_ID: string = 'hadssDialogModalColumn';
  static readonly DIALOG_CONTENT_TEST: string = 'ContentByCallBack';
  static readonly DIALOG_CONTENT_BY_CALL_BACK_TEST: string = 'NormalContent';
  static readonly TOAST_TEXT_CONTENT: string = 'ToastText';
  static readonly POPUP_TEXT_CONTENT: string = 'PopupText';
  /**
   * 待绑定的目标组件Id
   */
  static readonly TARGET_COMP_ID: string = 'TestComp';
  /**
   * sheet测试弹窗的属性
   */
  static readonly SHEET_TITLE: string = 'TestSheetTitle';
  static readonly SHEET_SUB_TITLE: string = 'TestSheetSubTitle';
  static readonly SHEET_DETENTS: [number, number, number] = [200, 500, 800];
  /**
   * 用于找到sheet弹窗
   */
  static readonly SHEET_FLAG: string = 'SheetPage';
  static readonly SHEET_MODEL_FLAG: string = 'SheetWrapper';
  static readonly SHEET_DRAG_BAR_FLAG: string = 'SheetDragBar';
  static readonly SHEET_CLOSE_BUTTON_FLAG: On =
    ON.within(ON.type(Constants.SHEET_FLAG)).isAfter(ON.type('Scroll')).type('Button');
  /**
   * 用于判断首页
   */
  static readonly INDEX_PAGE_TITLE = 'DialogHub弹窗示例'

  static readonly REUSE_EXAMPLE_TITLE = '弹窗复用示例';

  static readonly POPUP_DIRECTLY_BUTTON_ID = 'popupDirectlyButton'

  static readonly POPUP_WITH_ANIMATION_BUTTON_ID = 'popupWithAnimationButton'

  static readonly POPUP_WITH_CUSTOM_POSITION_BUTTON_ID = 'popupWithCustomPositionButton'

  static readonly TOAST_DISPLAYED_CONTENT = 'This is a Toast message'

  static readonly TOAST_DISPLAY_DURATION: number = 1500
}
