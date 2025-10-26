/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { BlogData, ImagePixelMap, User } from "../model/types";
import { image, sendableImage } from "@kit.ImageKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { http } from "@kit.NetworkKit";
import { Logger } from '../common/util/Logger';

const IMAGES = [
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/d/v3/Rl6Z4LI7QXmSBJwPdI0f7w/NV54hLP8S8CmSeamBgFN9w.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/b3/v3/_-sFheFMR8C4yT1OLCTWcg/DqGBYPLBS0mcnhVsoTFOmw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f6/v3/2QgjOIy2Q_65C--t0AaThg/6iRAKTeoRnu0T0WxhTECRw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/28/v3/804UGQS0Se6XzgIAGHv4Wg/FtN7zRQUQuG25HIGPwmShw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/fd/v3/LJJ0rNvaTjeHDMdm1O9ODw/4JFmSgudQ_uRvttdVGlnqA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/05/v3/y44v1Z6bShO-zsJmHVY-eg/34_FWLSPSYKjzAMS7reozg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/4f/v3/hayg9LgaSxKV0H3ZLPlwJg/lXD9fhObTCW1i0tGA1n_yg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/47/v3/iQWIeqMsTm-oytN9x0N12Q/OIoyti5vSjGR7uyCP3lKJA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/04/v3/Kh7sLUNWRVW0Lu2PjHFF0g/4fJVwfsMT5SB6lW5wVwa1g.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/d3/v3/Chth8Vi1TdutekSVrzlmTg/V-j53IY9QP6RN7Ft0RbDrA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f3/v3/WI8L6FQ9SFm9FruCVWqOZw/Bgoku8BbRIaAcaXnBlkqjg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f6/v3/2QgjOIy2Q_65C--t0AaThg/6iRAKTeoRnu0T0WxhTECRw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/ac/v3/F609IcNNTGGWYUtKYFCLTA/SNFRbgzxRmC2QS3-Rb-msw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/e9/v3/bje5By14Say27qEV2Ga9_w/9tYMSW7hR527EIIn5f60mg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/9a/v3/YJTfU1sdS0arE6kBjeOvUg/eE711PUTQeGwjTgcuIpfug.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/78/v3/kZ1U1fgyQIyq17iRVbGkbQ/7yEHTwC7Ri6mp8X_C2CnsA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/4f/v3/hayg9LgaSxKV0H3ZLPlwJg/lXD9fhObTCW1i0tGA1n_yg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/93/v3/zSOgMcKxT1CnOv7uois9ew/BtP71mQGQumwZ8Df_Flygg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/cf/v3/iAPHU1RiQ3C6N1VcaqPsmA/A9YzlO-KSqSgH57-DW-H4A.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/68/v3/9NmVtlQeRJuo32B9D_4oaA/OEeS8ybIS9W0bQxQEXAySg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f1/v3/oaTbF6rrRnifVmUz6Kx8pg/vE11Pq99SeiZ-lJj6y1oeQ.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/ac/v3/F609IcNNTGGWYUtKYFCLTA/SNFRbgzxRmC2QS3-Rb-msw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/68/v3/9NmVtlQeRJuo32B9D_4oaA/OEeS8ybIS9W0bQxQEXAySg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/96/v3/3-X0DsxbRH6AlbimBxnPog/HDC3_rmpRRussgr3MeNHWg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/b3/v3/_-sFheFMR8C4yT1OLCTWcg/DqGBYPLBS0mcnhVsoTFOmw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/7b/v3/O-qz81abT7ygFvSOGTnqtA/LUYXmSmGRhWD7S7oCrcb6A.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/bb/v3/-Xaw2zTeRYGQL1Y02xOCgA/SZqcqvfTTbec-rU0XS4VuQ.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/9d/v3/BdpN9f4GQEquwXR0Q9JzsA/X5vM2p69SnWEKFsJb4TtaQ.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/ac/v3/F609IcNNTGGWYUtKYFCLTA/SNFRbgzxRmC2QS3-Rb-msw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f8/v3/NlvkqPP4TqOp5tR-9v8IKg/w-urENTfRcOj9bJ44ZwooA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/a2/v3/2B0wltJbSASAHTK6Cq6riw/HJd3q3OpSqSg6I3IDdlTwA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/55/v3/B5QRS67VS-6uutH-uyfFsQ/f4PJOe6oRACFGW3B1NDyhw.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/96/v3/3-X0DsxbRH6AlbimBxnPog/HDC3_rmpRRussgr3MeNHWg.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/78/v3/kZ1U1fgyQIyq17iRVbGkbQ/7yEHTwC7Ri6mp8X_C2CnsA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/f8/v3/NlvkqPP4TqOp5tR-9v8IKg/w-urENTfRcOj9bJ44ZwooA.png',
  'https://contentcenter-drcn.dbankcdn.cn/pub_1/DevEcoSpace_1_900_9/a4/v3/sWmOw1KVTlaMNDBa_hBWuw/sF8e_Z1MR7Cd1-ZIjZl5JA.png',
];


const getRandomNumber = (min: number, max: number): number => {
  // Generates integers in the range [min, max].
  return Math.floor(Math.random() * (max - min + 1)) + min;
};

const EMOJIS = ["😊", "🎉", "🚀", "❤️", "🔥", "💡", "🌟", "📱", "💻", "🌍"];

const USERS: User[] = [
  { name: "科技前沿", avatar: IMAGES[getRandomNumber(0, IMAGES.length - 1)] },
  { name: "数码达人", avatar: IMAGES[getRandomNumber(0, IMAGES.length - 1)] },
  { name: "生活分享家", avatar: IMAGES[getRandomNumber(0, IMAGES.length - 1)] },
  { name: "新闻速递", avatar: IMAGES[getRandomNumber(0, IMAGES.length - 1)] },
  { name: "旅行日记", avatar: IMAGES[getRandomNumber(0, IMAGES.length - 1)] }
];


// Generate random user
function generateRandomUser(): User {
  const count = getRandomNumber(0, USERS.length - 1);
  return USERS[count];
}

// Generate random image array
function generateRandomImages(): Array<string> {
  const count = Math.floor(Math.random() * 9) + 1;
  const shuffled = IMAGES.sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
}

// Time formatting function
function formatTime(timestamp: number): string {
  const date = new Date(timestamp);
  const diff = (Date.now() - timestamp) / 1000;

  if (diff < 60) {
    return "刚刚";
  }
  if (diff < 3600) {
    return `${Math.floor(diff / 60)}分钟前`;
  }
  if (diff < 86400) {
    return `${Math.floor(diff / 3600)}小时前`;
  }
  return `${date.getMonth() + 1}-${date.getDate()}`;
}

// Generate random text content (with emoji)
export function generateRandomContent(): string {
  const sentences = [
    "HarmonyOS最新功能体验分享 ",
    "今天发现一个有趣的技术点：",
    "推荐大家试试这个开发技巧 ",
    "行业动态：",
    "生活小贴士："
  ];

  const sentence = sentences[Math.floor(Math.random() * sentences.length)];
  const emojiCount = getRandomNumber(1, EMOJIS.length % 3);
  let emojis = "";

  for (let j = 0; j < emojiCount; j++) {
    emojis += EMOJIS[Math.floor(Math.random() * EMOJIS.length)];
  }

  return (sentence + emojis + " ").repeat(Math.floor(Math.random() * 50 + 10));
}

export function generateRandomBlogData(count: number, onlyImage: boolean = false,
  contentCanNull: boolean = true): Array<BlogData> {
  const blogData: BlogData[] = [];
  const oneWeekAgo = new Date().getTime() - 7 * 24 * 60 * 60 * 1000;

  for (let i = 0; i < count; i++) {
    // Random blog type (1:text, 2:image, 3:hybrid)
    const type = Math.floor(Math.random() * 3) + 1;

    // Generate dynamic content
    let content = type !== 2 ? generateRandomContent() : "";
    if (contentCanNull === false) {
      content = generateRandomContent();
    }
    let images: string[] = [];
    if (onlyImage) {
      images = type !== 1 ? generateRandomImages() : [IMAGES[Math.floor(Math.random() * IMAGES.length)]];
    } else {
      images = type !== 1 ? generateRandomImages() : [];
    }
    let a = new BlogData();
    a.id = i + 1;
    a.user = generateRandomUser();
    a.content = content;
    a.images = images;
    a.time = formatTime(oneWeekAgo + Math.random() * 7 * 24 * 60 * 60 * 1000);
    a.likes = getRandomNumber(0, 1000);
    a.comments = getRandomNumber(0, 500);
    a.reposts = getRandomNumber(0, 500);
    // When an image needs to be preloaded, the imagePixelMapArray is initialized first
    a.imagePixelMapArray = a.images.map((value: string) => {
      let pix = new ImagePixelMap();
      pix.imageUrl = value;
      pix.imagePixelMap = undefined;
      return pix;
    })

    blogData.push(a);
  }
  return blogData;
}

export function HttpGet(url: string,
  callback: (error: number, pixelMap?: sendableImage.PixelMap) => void): http.HttpRequest {
  let request = http.createHttp();
  request.request(url, {
    maxLimit: 10 * 1024 * 1024,
    priority: 10000,
  }, (error: BusinessError, data: http.HttpResponse) => {
    if (error) {
      callback(-1);
      request.destroy();
      return;
    } else {
      const imageData: ArrayBuffer = data.result as ArrayBuffer;
      let imgSource: sendableImage.ImageSource = sendableImage.createImageSource(imageData);
      let options: image.DecodingOptions = {
        'editable': false,
      }
      if (imgSource) {
        imgSource.createPixelMap(options).then((pixelMapImg: sendableImage.PixelMap) => {
          callback(0, pixelMapImg);
          pixelMapImg.release();
          imgSource.release();
        })
      } else {
        Logger.warn('warn, imgSource is undefined');
      }
      request.destroy();
    }
  })
  return request
}