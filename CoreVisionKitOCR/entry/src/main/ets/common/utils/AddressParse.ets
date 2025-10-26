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
import { ConsigneeInfo } from '../../viewmodel/DataModel';


/**
 * This example uses regular expression processing to extract formatted data,
 * and simply extracts common recipient information.
 * To cover comprehensive and complex scenarios and achieve accurate extraction,
 * consider using professional cloud services or NLP tools.
 */
export class AddressParse {
  static nameBeforeRegex = /([\w\u4e00-\u9fa5]+[\s\,\，\。]+|[\s\,\，\。]*)([\u4e00-\u9fa5]{2,4})[\s\,\，\。]+/;
  static nameAfterRegex = /[\s\,\，\。]+([\u4e00-\u9fa5]{2,4})[\s\,\，\。]*/;
  static nameTagRegex = /(?:收货人|收件人|姓名|联系人)[:：\s]*([\u4e00-\u9fa5]{2,4})/i;
  static namePlainRegex = /[\u4e00-\u9fa5]{2,4}/;
  static phoneRegex =
    /(1[3-9]\d[\s-]?\d{4}[\s-]?\d{4})|(\d{3,4}[\s-]?\d{7,8})|(\(\d{2,4}\)[\s-]?\d{4,8})|(\+\d{1,4}[\s-]?\d{5,15})/g;
  static phoneHyphenRegex = /[\(\)\s-]/g;
  static addressKeywords =
    ['收货地址', '收件地址', '配送地址', '所在地区', '位置',
      '地址', '寄至', '寄往', '送至', '详细地址'];
  static addressNoiseWords = ['收货人', '收件人', '姓名', '联系人', '电话', '手机', '联系方式', '：', ':', '，', ','];

  static extractInfo(text: string, info: ConsigneeInfo[]): ConsigneeInfo[] {
    const baseText: string = text.replace(/\s+/g, ' ')
    const phoneResult: string = AddressParse.extractPhone(baseText);
    const nameResult: string = AddressParse.extractName(baseText, phoneResult);
    const addressResult: string = AddressParse.extractAddress(baseText, phoneResult, nameResult);
    info[0].value = nameResult;
    info[1].value = phoneResult.replace(AddressParse.phoneHyphenRegex, '');
    info[2].value = addressResult;
    return info;
  }

  static extractPhone(text: string): string {
    const phoneMatch: RegExpMatchArray | null = text.match(AddressParse.phoneRegex);
    return phoneMatch ? phoneMatch[0] : '';
  }

  static extractName(text: string, phone: string): string {
    let name = '';

    // Try to extract from the label
    const nameFromTag = text.match(AddressParse.nameTagRegex);
    if (nameFromTag) {
      name = nameFromTag[1];
    }

    // Try to extract before or after the phone
    if (!name && phone) {
      const phoneIndex = text.indexOf(phone);

      const beforePhone = text.substring(0, phoneIndex);
      const nameBefore = beforePhone.match(AddressParse.nameBeforeRegex);
      if (nameBefore) {
        name = nameBefore[2];
      }

      if (!name) {
        const afterPhone = text.substring(phoneIndex + phone.length);
        const nameAfter = afterPhone.match(AddressParse.nameAfterRegex);
        if (nameAfter) {
          name = nameAfter[1];
        }
      }
    }

    // Try to extract 2-4 Chinese characters directly
    if (!name) {
      const nameMatch = text.match(AddressParse.namePlainRegex);
      if (nameMatch) {
        name = nameMatch[0];
      }
    }
    return name;
  }

  static extractAddress(text: string, phone: string, name: string): string {

    for (const keyword of AddressParse.addressKeywords) {
      const keywordIndex = text.indexOf(keyword);
      if (keywordIndex !== -1) {
        const possibleAddress = text.substring(keywordIndex + keyword.length).trim();

        // Clean up the beginning punctuation
        const cleanedAddress = possibleAddress.replace(/^[：:，,。、\s]+/, '');

        if (cleanedAddress.length > 5) {
          return cleanedAddress;
        }
      }
    }

    // Try to remove name and phone number
    let cleanedText = text;
    if (name) {
      cleanedText = cleanedText.replace(name, '');
    }
    if (phone) {
      cleanedText = cleanedText.replace(phone, '');
    }

    // Remove common distracting words
    AddressParse.addressNoiseWords.forEach(word => {
      cleanedText = cleanedText.replace(word, '');
    });

    // Extract the longest text segment that may contain an address
    const segments = cleanedText.split(/[\s,，。；;]+/).filter(seg => seg.length > 4);
    if (segments.length > 0) {

      // The segment containing the address key is preferred
      const addressSegments = segments.filter(seg =>
      seg.includes('省') || seg.includes('市') || seg.includes('区') ||
      seg.includes('县') || seg.includes('路') || seg.includes('街') ||
      seg.includes('号') || seg.includes('栋') || seg.includes('单元')
      );

      if (addressSegments.length > 0) {
        return addressSegments.join(' ');
      }

      // Otherwise select the longest segment
      return segments.reduce((longest, current) =>
      current.length > longest.length ? current : longest, '');
    }

    // Finally, return the entire text
    return cleanedText;
  }
}