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

import React, { useState } from "react";
import Banner from "./components/Banner";
import QuickFunction from "./components/QuickFunction";
import CustomDialog from "./components/CustomDialog";
import SelectRecommend from "./components/SelectRecommend";
import { LanguageManager } from "./utils/LanguageManager";
import translations from "./utils/translations";
import "./App.css";

function App() {
  const [isShow, setIsShow] = useState<boolean>(false);
  const lang = new URLSearchParams(window.location.search).get("lang") ?? "zh";
  const lm = LanguageManager.getInstance();
  lm.setLanguage(lang);
  lm.setTranslations(translations);

  return (
    <div className="app">
      <div className="page-header">
        <span className="title">{lm.get("home")}</span>
        <div className="share" onClick={() => setIsShow(true)}>
          <img src="assets/icon/arrowshape_turn_up_right.svg" alt="" />
        </div>
      </div>
      <CustomDialog isShow={isShow} close={() => setIsShow(false)} />
      <Banner />
      <QuickFunction />
      <SelectRecommend />
    </div>
  );
}

export default App;
