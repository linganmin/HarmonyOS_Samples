import { DialogConfig } from "@hadss/dialoghub";
/**
 * 以下常量copy自sample/DialogHubSample/entry/src/main/ets/Utils/CommonConstant.ets
 */
export default class CopyCommonConstant {
  static readonly FULL_LENGTH = "100%";
  static readonly HALF_FULL_LENGTH = "50%";
  static readonly SHEET_MIDDLE: number = 260;
  static readonly SHEET_LARGE: number = 514;
  static readonly DURATION_1000: number = 1000;
  static readonly DURATION_2000: number = 2000;
  static readonly DURATION_3000: number = 3000;
  static readonly Interval_20: number = 20;
  static readonly MODEL_DIALOG: string = '模态弹窗';
  static readonly NON_MODEL_DIALOG: string = '非模态弹窗';
  static readonly INPUT_DEFAULT_VALUE: string = "空";
  static readonly TIMED_DIALOG: string = "定时弹窗";
  static readonly TIMED_CLOSED: string = "秒后关闭";
  static readonly LOGOUT: string = "退出登录";
  static readonly LOGOUT_TIPS: string = "是否要确定退出当前账号";
  static readonly CANCEL: string = "取消";
  static readonly OUT: string = "退出";
  static readonly OPEN: string = "打开";
  static readonly CLOSE: string = "关闭";
  static readonly SAVE: string = "储存";
  static readonly AGREE: string = "同意";
  static readonly DIALOG_STATE_OPEN: string = "当前弹窗状态：打开";
  static readonly DIALOG_STATE_CLOSE: string = "当前弹窗状态：关闭"
  static readonly CUSTOM_TEMPLATE_SIMPLE: string = "SimpleCustom";
  static readonly PURE_TEXT: string = "纯文本";
  static readonly SKIP_ACTION_PATH: string = "SkipAction";
  static readonly SKIP_ACTION_TITLE: string = "SkipAction";
  static readonly SKIP_ACTION_PARAM: string = "SkipAction Success!";
  static readonly ROUTER_PATH: string = 'pages/Others/RouterSkip';
  static readonly COMMON_ACTION_PATH: string = "CommonExamples";
  static readonly OPERABLE_ACTION_PATH: string = "OperableExample";
  static readonly REUSE_ACTION_PATH: string = "ReuseExample";
  static readonly MULTI_ACTION_PATH: string = "MultiDialogExample";
  static readonly DIALOG_HUB_EXAMPLES = "DialogHub弹窗示例";
  static readonly COMMON_DIALOG_EXAMPLES = "常见弹窗示例";
  static readonly OPERABLE_DIALOG_EXAMPLES = "弹窗与页面/用户交互示例";
  static readonly REUSE_DIALOG_EXAMPLES = "弹窗复用示例";
  static readonly MULTI_DIALOG_EXAMPLES = "多个弹窗处理示例";
  static readonly DIALOG_A = "我是弹窗A";
  static readonly DIALOG_B = "我是弹窗B";
  static readonly DIALOG_C = "我是弹窗C";
  static readonly DIALOG_D = "我是弹窗D";
  static readonly DIALOG_E = "我是弹窗E";
  static readonly DIALOG_F = "我是弹窗F";
  static readonly DIALOG_G = "我是弹窗G";
  static readonly DIALOG_H = "我是弹窗H";
  static readonly DIALOG_A_CONTENT = "AAAAAAAAAAAAAAAAAAAAAA";
  static readonly DIALOG_B_CONTENT = "BBBBBBBBBBBBBBBBBBBBBB";
  static readonly DIALOG_C_CONTENT = "CCCCCCCCCCCCCCCCCCCCCC";
  static readonly DIALOG_D_CONTENT = "DDDDDDDDDD";
  static readonly DIALOG_E_CONTENT = "EEEEEEEEEE";
  static readonly DIALOG_F_CONTENT = "FFFFFFFFFF";
  static readonly DIALOG_G_CONTENT = "GGGGGGGGGG";
  static readonly DIALOG_H_CONTENT = "HHHHHHHHHH";
  static readonly EXISTING_DIALOG_TITLE = "新弹窗被已有弹窗抑制";
  static readonly DIALOG_B_SUPPRESSION = "弹窗B弹出失败";
  static readonly DIALOG_C_SUPPRESSION_TIPS = "当前页面无弹窗时才可弹出的弹窗C";
  static readonly DIALOG_C_SUPPRESSION = "弹窗C弹出失败";
  static readonly DIALOG_A_BINDING_BUTTON = "dialogAButton";
  static readonly DIALOG_B_BINDING_BUTTON = "dialogBButton";
  static readonly DIALOG_C_BINDING_BUTTON = "dialogCButton";
  static readonly DIALOG_D_BINDING_BUTTON = "dialogDButton";
  static readonly DIALOG_E_BINDING_BUTTON = "dialogEButton";
  static readonly DIALOG_F_BINDING_BUTTON = "dialogFButton";
  static readonly DIALOG_G_BINDING_BUTTON = "dialogGButton";
  static readonly DIALOG_H_BINDING_BUTTON = "dialogHButton";
  static readonly DIALOG_MULTI_BINDING_BUTTON = "multiDialogExampleCloseButton";
  static readonly DIALOG_F_LAYER_INDEX = 10;
  static readonly SHUT_DOW_ALL_DIALOG = "关闭当前页面所有弹窗";
  static readonly CURRENT_BREAK_POINT = "currentBreakpoint";
  static readonly CURRENT_BREAK_POINT_XS = 'xs';
  static readonly CURRENT_BREAK_POINT_SM = 'sm';
  static readonly CURRENT_BREAK_POINT_md = 'md';
  static readonly CURRENT_BREAK_POINT_lg = 'lg';
  static readonly CURRENT_BREAK_POINT_XS_SIZE = 320;
  static readonly CURRENT_BREAK_POINT_SM_SIZE = 600;
  static readonly CURRENT_BREAK_POINT_md_SIZE = 840;
  static readonly TAG_NAME = '鸿蒙';
  static readonly UPDATE_TAG = '修改标签';
  static readonly TAG_NAME_TEXT = '标签名: ';
  static readonly Now_Dialogs = '当前页面弹窗数: ';
  static readonly DIALOG_1 = '感知弹窗1';
  static readonly DIALOG_2 = '感知弹窗2';
  static readonly DIALOG_3 = '弹窗3';
  static readonly DIALOG_3_NO_RESPONSE = '不响应返回手势';
  static readonly DIALOG_NOW_STATE = '当前状态：';
  static readonly BREAK_ON_DIALOG = '当前配置: 返回手势作用于弹窗';
  static readonly BREAK_ON_PAGE = '当前配置: 返回手势作用于页面';
  static readonly ProgressName = '上传中';
  static readonly ProgressNameStart = 0;
  static readonly ProgressNameTotal = 100;
  static readonly SkipBuilderSpan_2 = '关于XX业务与隐私的声明';
  static readonly REUSE_SIMPLE_DIALOG = 'This is a Toast message';
  static readonly My_template_model_name = "SimpleToast";
  static readonly CUSTOM_SAMPLE_STYLE_SHADOW: ShadowOptions = {
    radius: $r('app.float.custom_sample_shadow_radius'),
    color: $r('app.color.custom_sample_shadow_color'),
    offsetY: $r('app.float.custom_sample_shadow_offset')
  };
  static readonly CUSTOM_SAMPLE_CONFIG: DialogConfig = {
    dialogPosition: {
      alignment: DialogAlignment.Bottom,
      offset: {
        dx: 0, dy: $r('app.float.custom_sample_offset')
      }
    }
  };
  static readonly TOP_BOTTOM_MARGIN: Margin = {
    top: 10, bottom: 10
  };
  static readonly LEFT_DIALOG_OFFSET: Offset = {
    dx: '-25%', dy: 0
  };
  static readonly Right_DIALOG_OFFSET: Offset = {
    dx: '25%', dy: 0
  };
  static readonly REUSE_EXAMPLE_TITLE = '弹窗复用示例';
  static readonly POPUP_DIRECTLY_BUTTON_ID = 'popupDirectlyButton'
  static readonly POPUP_WITH_ANIMATION_BUTTON_ID = 'popupWithAnimationButton'
  static readonly POPUP_WITH_CUSTOM_POSITION_BUTTON_ID = 'popupWithCustomPositionButton'
  static readonly TOAST_DISPLAYED_CONTENT = 'This is a Toast message'
  static readonly TOAST_DISPLAY_DURATION: number = 1500

  static readonly CREATE_DIALOG_TEMPLATE = '创建弹窗模板'
  static readonly CLICK_TO_CREATE = '点击创建'
  static readonly DELETE_TEMPLATE = '删除弹窗模板'
  static readonly CLICK_TO_DELETE = '点击删除'
  static readonly RANDOMIZE_TEMPLATE_BACKGROUND = '修改弹窗模板为随机背景色'
  static readonly CLICK_TO_MODIFY = '点击修改'
  static readonly DIRECTLY_POPUP_DIALOG = '直接弹出弹窗模板'
  static readonly CLICK_TO_DEMONSTRATE = '点击演示'
  static readonly POPUP_WITH_ANIMATION = '定义本次弹出动画后弹出'
  static readonly POPUP_AFTER_DEFINING_POSITION = '定义本次弹出位置后弹出'
  static readonly DIALOG_TEXT = '弹窗'
  static readonly SINGLETON_DIALOG_ID = 'singletonPopup'
  static readonly CREATE_DIALOG_FROM_SAME_INSTANCE = '通过同一对象进行弹窗'
  static readonly REUSEEXAMPLE_ITEMHEAD = '通过自定义弹窗模板进行弹窗'
  static readonly TOAST_DEFAULT_BACKGROUNDCOLOR = '#88000000'

  static readonly Y_OFFSET: number = 80

}