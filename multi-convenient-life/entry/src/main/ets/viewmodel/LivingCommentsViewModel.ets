/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export class LivingCommentsViewModel {
  type: number = 1;
  name: string = '';
  content: string = '';

  constructor(type: number, name: string, content: string) {
    this.type = type;
    this.name = name;
    this.content = content;
  }

  public static getLivingCommentsList(): LivingCommentsViewModel[] {
    let array: LivingCommentsViewModel[] = [];
    array.push(new LivingCommentsViewModel(1, '米***米：', '你好，请问现在海鸥多吗？'));
    array.push(new LivingCommentsViewModel(1, '超***萌：', '这是哪里呀？'));
    array.push(new LivingCommentsViewModel(1, '喵***妹：', '风景不错，求地址'));
    array.push(new LivingCommentsViewModel(2, '   通知   ',
      '    欢迎来到直播间！平台提倡文明健康的直播环境，严禁违法违规、色情低俗等' +
        '不良内容，严禁未成年人打赏或进行直播，购买商品请谨慎判断，切勿轻信可疑广告信息，谨防网络诈骗，理性消费。如发现违规行为请及时举报！'));
    array.push(new LivingCommentsViewModel(3, '', '大漠鹰 通过首页推荐来了'));
    array.push(new LivingCommentsViewModel(1, '张***天：', '好想去呀！'));
    array.push(new LivingCommentsViewModel(1, '狗***西：', '我也要来一场说走就走的旅行'));
    array.push(new LivingCommentsViewModel(1, '麦***袁：', '这个季节去会不会冷？'));
    array.push(new LivingCommentsViewModel(1, '嘟***嘟：', '想去诶！'));
    array.push(new LivingCommentsViewModel(1, '天***海：', '走'));
    array.push(new LivingCommentsViewModel(1, '风***雨：', '这是哪里呀？'));
    array.push(new LivingCommentsViewModel(1, '山***经：', '好美，是哪？'));
    array.push(new LivingCommentsViewModel(3, '', '自由人 通过首页推荐来了'));
    array.push(new LivingCommentsViewModel(1, '旅***记：', '好想去，能发一下地址吗？'));
    return array;
  }
}