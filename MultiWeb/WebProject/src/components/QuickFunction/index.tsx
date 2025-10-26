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

import QuickFunctionItem from "../QuickFunctionItem";
import { QuickFunctionItemType } from "../../types";
import { LanguageManager } from "src/utils/LanguageManager";
import "./index.css";

const QuickFunction = () => {
  const lm = LanguageManager.getInstance();
  const quickFunctions: QuickFunctionItemType[] = [
    {
      label: lm.get("myLike"),
      icon: "assets/icon/heart.svg",
    },
    {
      label: lm.get("history"),
      icon: "assets/icon/history.svg",
    },
    {
      label: lm.get("message"),
      icon: "assets/icon/message.svg",
    },
    {
      label: lm.get("cart"),
      icon: "assets/icon/cart.svg",
    },
    {
      label: lm.get("target"),
      icon: "assets/icon/target.svg",
    },
    {
      label: lm.get("circle"),
      icon: "assets/icon/circle.svg",
    },
    {
      label: lm.get("collection"),
      icon: "assets/icon/collection.svg",
    },
    {
      label: lm.get("recycleBin"),
      icon: "assets/icon/clean.svg",
    },
    {
      label: lm.get("message"),
      icon: "assets/icon/message.svg",
    },
    {
      label: lm.get("myLike"),
      icon: "assets/icon/heart.svg",
    },
    {
      label: lm.get("circle"),
      icon: "assets/icon/circle.svg",
    },
    {
      label: lm.get("cart"),
      icon: "assets/icon/cart.svg",
    },
    {
      label: lm.get("collection"),
      icon: "assets/icon/collection.svg",
    },
    {
      label: lm.get("history"),
      icon: "assets/icon/history.svg",
    },
    {
      label: lm.get("recycleBin"),
      icon: "assets/icon/clean.svg",
    },
    {
      label: lm.get("target"),
      icon: "assets/icon/target.svg",
    },
  ];

  return (
    <div className="grid-functions">
      {quickFunctions.map((item: QuickFunctionItemType, index: number) => (
        <QuickFunctionItem key={item.label + index} {...item} />
      ))}
    </div>
  );
};
export default QuickFunction;
