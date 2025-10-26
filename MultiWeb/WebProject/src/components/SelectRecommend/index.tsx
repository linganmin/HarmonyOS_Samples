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

import { useState } from "react";
import { BannerItem } from "src/types";
import { LanguageManager } from "src/utils/LanguageManager";
import "./index.css";

const SelectRecommend = () => {
  const [recommends] = useState<BannerItem[]>([
    {
      id: "001",
      url: "assets/recommend01.png",
    },
    {
      id: "002",
      url: "assets/recommend02.png",
    },
    {
      id: "003",
      url: "assets/recommend03.png",
    },
    {
      id: "004",
      url: "assets/recommend04.png",
    },
    {
      id: "005",
      url: "assets/recommend05.png",
    },
    {
      id: "006",
      url: "assets/recommend06.png",
    },
    {
      id: "007",
      url: "assets/recommend07.png",
    },
    {
      id: "008",
      url: "assets/recommend08.png",
    },
  ]);
  const lm = LanguageManager.getInstance();

  return (
    <>
      <div className="subtitle">{lm.get("selectRecommend")}</div>
      <div className="recommends">
        {recommends.map((recommend) => (
          <div key={recommend.id} className="recommends-item">
            <img src={recommend.url} alt="" />
            <div className="first-line"></div>
            <div className="second-line"></div>
          </div>
        ))}
      </div>
    </>
  );
};
export default SelectRecommend;
