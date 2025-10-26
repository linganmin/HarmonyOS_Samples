/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class DetailConstants {
  /**
   * Living.
   */
  static readonly LIVING: string = uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.LIVING').id);
  /**
   * Product detail resources.
   */
  static readonly PRODUCT_DETAIL_RESOURCES: Resource[] = [$r('app.media.product_detail_1'),
    $r('app.media.product_detail_2'), $r('app.media.product_detail_2'), $r('app.media.product_detail_2'),
    $r('app.media.product_detail_3')];
  /**
   * Product small resources.
   */
  static readonly PRODUCT_SMALL_RESOURCES: Resource[] = [$r('app.media.product_small_1'),
    $r('app.media.product_small_2'), $r('app.media.product_small_2'), $r('app.media.product_small_2'),
    $r('app.media.product_small_3')];
  /**
   * Gradient color list.
   */
  static readonly GRADIENT_COLORS: string[] = ['#FF6354', '#CF0A2C', '#FAE8E0', '#FFC9C9'];
  /**
   * Product color selection.
   */
  static readonly PRODUCT_COLOR_SELECTION: Resource[] = [$r('app.media.product_small_1'),
    $r('app.media.product_small_2'), $r('app.media.product_small_3')];
  /**
   * Recommended config products.
   */
  static readonly RECOMMENDED_CONFIG_PRODUCTS: Resource[] = [$r('app.media.recommended_config_1'),
    $r('app.media.recommended_config_2'), $r('app.media.recommended_config_3'), $r('app.media.recommended_config_4')];
  /**
   * Param string list.
   */
  static readonly PARAM_STRING_LIST: string[] = ['shoppingBag', 'customerService'];
  /**
   * Customer service contents.
   */
  static readonly CUSTOMER_SERVICE_CONTENTS: string[] = [
    '华为官方旗舰店',
    '12999',
    '13999',
    '购买',
    'HUAWEI Mate X5 12GB+512GB 幻影紫 超轻薄四曲折叠 超高清高分辨率临境双屏 超智慧灵犀通信',
    '您好！想咨询一下今年秋季最新发布的手机～',
    '您好，智能客服助手为您服务！',
    '欢迎光临华为官方商城，为提升服务质量，您的咨询可能会被记录。目前店铺客服数量较少，建议您优先通过商品详情页或华为官网获取商品信息，若智能客服无法解决您的问题，您可以输入“人工”联系人工客服。感谢您的理解和支持～'];
  /**
   * Product color list.
   */
  static readonly COLOR_SELECT_NAME_LIST: string[] = ['幻影紫', '羽砂黑', '羽砂白', '青山黛'];
  /**
   * Product name list.
   */
  static readonly CAPACITY_SELECT_NAME_LIST: string[] = ['12GB+512GB', '12GB+1T'];
  /**
   * Product type list.
   */
  static readonly TYPE_SELECT_NAME_LIST: string[] = ['官方标配'];
  /**
   * Product select type list.
   */
  static readonly SELECT_NAME_LIST: string[] =
    [uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.SELECT_NAME_LIST1').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.SELECT_NAME_LIST2').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.SELECT_NAME_LIST3').id)];
  /**
   * Product image list.
   */
  static readonly COLOR_SELECT_IMAGE_LIST: Resource[] = [$r('app.media.pay_product_1'),
    $r('app.media.pay_product_2'), $r('app.media.pay_product_3'), $r('app.media.pay_product_4')];
  /**
   * Button names.
   */
  static readonly BUTTON_NAMES: string[] =
    [uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.BUTTON_NAMES1').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.BUTTON_NAMES2').id)];
  /**
   * Pay address and contact.
   */
  static readonly PAY_INFO: string[] =
    ['XXXX大道XXXXX楼XX单元XX号', uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_INFO1').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_INFO2').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_INFO3').id),
      uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.PAY_INFO4').id)];
  /**
   * Product config list.
   */
  static readonly PRODUCT_CONFIG_NAMES: string[] = ['已选', '幻影紫·512GB·现货速发', '搭配', '推荐', '回收',
    '高价回收送多重新补贴', '满48元包邮', '由华为终端提供商品、发货开票及售后服务'];
  /**
   * User comment list.
   */
  static readonly USER_COMMENT_NAMES: string[] = ['用户评价（1500+）', '最热门77', '有内容858', '有图217', '几**********',
    '华为手机续航很好，拍照清晰，运行畅快，功能也很强大，关键是颜值出众，非常值得推荐！', '全部评价',
    '曜金黑，256GB，现货速发'];
  /**
   * List space.
   */
  static readonly PRODUCT_CONFIG_LIST_SPACE: number = 12;
  /**
   * Y position of live row.
   */
  static readonly LIVE_ROW_Y_POSITION: number = 12;
  /**
   * Live stack aspect ratio.
   */
  static readonly LIVE_STACK_ASPECT_RATIO: number[] = [1.2, 2.2];
  /**
   * Picture number.
   */
  static readonly PICTURE_INDICATOR: string[] = ['/5', '3D', '机型对比'];
  /**
   * Picture list space list.
   */
  static readonly PICTURE_LIST_SPACES: string[] = ['8vp', '12vp', '16vp'];
  /**
   * Product discount name list.
   */
  static readonly PRODUCT_DISCOUNT_NAMES: string[] = ['【现货速发】HUAWEI Mate X5 12GB+512GB 幻影紫',
    '【华为超级新品季】1.限量买赠价值299元智能视窗保护套 2.学生认证优惠100元（下拉了了解详情）3.以旧换新至高补贴500元｜更多甄选手机点击了解>>超清临镜双屏｜超轻薄四曲折叠',
    'Mate X5:', '限量赠无限耳机活力版'];
  /**
   * Product price name list.
   */
  static readonly PRODUCT_PRICE_NAMES: string[] = ['￥', '12999', '￥13999', '距离结束还剩', '07', ':', '14', ':', '50',
    '最高可享12期0分期利息', '精品', '限时直降800元', '以旧换新补贴', '优惠', '广东 深圳市 龙岗区', '现货'];
  /**
   * 80 percent.
   */
  static readonly EIGHTY_PERCENT: string = '80%';
  /**
   * Comments list.
   */
  static readonly COMMENTS_LIST: number[] = [1, 2];
  /**
   * Navigation id.
   */
  static readonly NAVIGATION_ID: string = 'navId';
}