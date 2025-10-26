/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { window, promptAction, UIContext } from '@kit.ArkUI';
import Logger from '../util/Logger'

const TAG: string = 'WindowController'

let windowClass = null

export default class WindowController {
  UIContext: UIContext

  constructor(UIContext: UIContext) {
    this.UIContext = UIContext
  }

  // Obtain the last window displayed in the current application and
  // use the callback asynchronous callback function.
  // Corresponding to the getWindow() of the FA.
  getTopWindow(context) {
    window.getLastWindow(context, (err, data) => {
      if (err.code) {
        Logger.info(TAG, `Failed to obtain the top window. Cause: ${JSON.stringify(err)}`)
        this.UIContext.getPromptAction().showToast({
          message: `Failed to obtain the top window. Cause: ${JSON.stringify(err)}`
        })
        return
      }
      Logger.info(TAG, `Succeeded in obtaining the top window. Data: ${JSON.stringify(data)}`)
      this.UIContext.getPromptAction().showToast({
        message: `Succeeded in obtaining the top window`
      })
    })
  }

  // Sets the display direction of the current capability,
  // corresponding to setDisplayOrientation() of the FA model.
  setPreferredOrientation(context) {

    window.getLastWindow(context, (err, data) => {
      if (err.code) {
        Logger.info(TAG, `Failed to obtain the top window. Cause: ${JSON.stringify(err)}`)
        this.UIContext.getPromptAction().showToast({
          message: `Failed to obtain the top window. Cause: ${JSON.stringify(err)}`
        })
        return
      }
      windowClass = data
      let orientation = window.Orientation.AUTO_ROTATION
      let promise = windowClass.setPreferredOrientation(orientation)
      promise.then((data) => {
        Logger.info(TAG, `Succeeded in setting the window orientation. Data: ${JSON.stringify(data)}`)
        this.UIContext.getPromptAction().showToast({
          message: `Succeeded in setting the window orientation`
        })
      }).catch((error) => {
        Logger.error(TAG, `Failed to set the window orientation. Cause: ${JSON.stringify(error)}`)
        this.UIContext.getPromptAction().showToast({
          message: `Failed to set the window orientation. Cause: ${JSON.stringify(error)}`
        })
      })
    })
  }
}