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

export class HandleData {
  /*
   * Process the text into the final display attribute string
   */
  // [Start handle_styled_string]
  static handleStyledString(styledStrings: MutableStyledString[]): TextController {
    let controller: TextController = new TextController();
    let paragraphStyledString: MutableStyledString = new MutableStyledString('', []);

    // Append the attribute string generated for each text fragment to the attribute string paragraphStyledString
    styledStrings.forEach((mutableStyledString: MutableStyledString) => {
      paragraphStyledString.appendStyledString(mutableStyledString);
    })

    controller.setStyledString(paragraphStyledString);
    return controller;
  }

  // [End handle_styled_string]
}