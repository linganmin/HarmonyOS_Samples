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

export class FileConstants {
  /**
   * Preset file name.
   */
  static readonly PRESET_FILE_NAME: string = 'test';

  /**
   * Txt file type.
   */
  static readonly TXT_FILE_TYPE: string = '.txt';

  /**
   * Preset file content.
   */
  static readonly PRESET_FILE_CONTENT: string = 'XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成' +
    '熟的安全标准，为您的个人信息提供相应的保护措施。\n\n（其它补充）\n\n1、我们如何收集和使用您的信息\n\n2、个性化推荐（可选）\n\n3、广告' +
    '（可选）\n\n4、对儿童的保护\n\n5、与第三方共享（共享）\n\n6、管理您的数据\n\n7、数据存储地点及期限\n\n8、如何联系我们\n';

  /**
   * 100 percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * 90 percent.
   */
  static readonly NINETY_PERCENT: string = '90%';

  /**
   * Title.
   */
  static readonly TITLE: Resource[] = [
    $r('app.string.text_document'),
    $r('app.string.text_preview'),
    $r('app.string.compressed_file_type')
  ];

  /**
   * List space.
   */
  static readonly LIST_SPACE: string = '12vp';

  /**
   * Font weight 500.
   */
  static readonly FONT_WEIGHT_500: number = 500;

  /**
   * Operation list.
   */
  static readonly OPERATION_LIST: Resource[] = [
    $r('app.string.text_preview'),
    $r('app.string.text_compress'),
    $r('app.string.text_uncompress')
  ];

  /**
   * Byte conversion.
   */
  static readonly BYTE_CONVERSION: number = 1024;

  /**
   * Size units.
   */
  static readonly SIZE_UNITS: string[] = ['B', 'KB', 'MB'];

  /**
   * Button text list.
   */
  static readonly BUTTON_TEXTS: Resource[] = [
    $r('app.string.text_confirm'),
    $r('app.string.import_resource_path')
  ];

  /**
   * Compress type list.
   */
  static readonly COMPRESS_TYPES: Resource[] = [
    $r('app.string.gzip_compress'),
    $r('app.string.zip_compress'),
    $r('app.string.7z_compress'),
    $r('app.string.tar_compress')
  ];

  /**
   * Compress group.
   */
  static readonly COMPRESS_GROUP: string = 'compress';

  /**
   * Toast text list.
   */
  static readonly TOAST_TEXTS: Resource[] = [
    $r('app.string.compression_status_prompt1'),
    $r('app.string.compression_status_prompt2'),
    $r('app.string.compression_status_prompt3'),
    $r('app.string.compression_status_prompt4')
  ];

  /**
   * Compressed file suffix list.
   */
  static readonly COMPRESSED_FILE_SUFFIXES: string[] = ['.gz', '.zip', '.7z', '.tar'];

  /**
   * Decompressed file directory.
   */
  static readonly DECOMPRESSED_FILE_DIRECTORY: string = '/decompressedFile';

  /**
   * Tar type.
   */
  static readonly TAR_TYPE: string = 'tar';

  /**
   * Tar archive entry mode.
   */
  static readonly TAR_ARCHIVE_ENTRY_MODE: number = 0o100000;

  /**
   * Record size list.
   */
  static readonly RECORD_SIZES: number[] = [512, 512 * 20];

  /**
   * Encode params for 7z.
   */
  static readonly ENCODE_PARAMS_7Z: number[] = [0, 1, 2, 3, 23, 128, 8, -1];

  /**
   * Decode params for 7z.
   */
  static readonly DECODE_PARAMS_7Z: number[] = [5, 8];

  /**
   * Border width.
   */
  static readonly BORDER_WIDTH: number = 0.5;

  /**
   * Compress into tar file directory.
   */
  static readonly TAR_FILE_DIRECTORY: string = 'decompressedFile/';
}