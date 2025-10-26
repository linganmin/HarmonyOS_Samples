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

import React, { useEffect, useState, useRef } from "react";
import "./index.css";
// [Start Rotating_broadcasting_layout]
const Banner = () => {
  const banner = [
    { id: "001", url: "assets/banner01.png" },
    { id: "002", url: "assets/banner02.png" },
    { id: "003", url: "assets/banner03.png" },
    { id: "004", url: "assets/banner04.png" },
  ];

  const [currentIndex, setCurrentIndex] = useState(1);
  const [currentDot, setCurrentDot] = useState(0);
  const [width, setWidth] = useState<number>(0);
  const [singleOffset, setSingleOffset] = useState<number>(0);
  const [initOffset, setInitOffset] = useState<number>(0);
  const [gap, setGap] = useState(16);
  const [animate, setAnimate] = useState("transform 0.5s ease");
  const [dotVisible, setDotVisible] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);
  const totalItems = banner.length;

  useEffect(() => {
    const updateLayout = () => {
      const winWidth = window.innerWidth;
      if (winWidth < 600) {
        setGap(0); // set the distance between elements under the sm breakpoint.
        setWidth(winWidth - 32); // set the element width under the sm breakpoint.
        setSingleOffset(winWidth - 32); // set the single displacement under the sm breakpoint.
        setInitOffset(0); // set the initial offset under the sm breakpoint.
        setDotVisible(true);
      } else if (winWidth < 840) {
        setGap(12); // set the distance between elements under the md breakpoint.
        setWidth((winWidth - 48 - gap) / 2); // set the element width under the md breakpoint.
        setSingleOffset(width + gap); // set the single displacement under the md breakpoint.
        setInitOffset(24); // set the initial offset under the md breakpoint.
        setDotVisible(false);
      } else {
        setGap(16); // set the distance between elements under the lg breakpoint.
        setWidth((winWidth - 250 - gap) / 2); // set the element width under the lg breakpoint.
        setSingleOffset(width + gap); // set the single displacement under the lg breakpoint.
        setInitOffset(125); // set the initial offset under the lg breakpoint.
        setDotVisible(false);
      }
    };

    updateLayout();
    window.addEventListener("resize", updateLayout);
    return () => window.removeEventListener("resize", updateLayout);
  }, [gap, width]);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prev) => prev + 1);
      setCurrentDot((p) => (p + 1) % banner.length);
    }, 3000);
    return () => clearInterval(interval);
  });

  useEffect(() => {
    if (currentIndex === totalItems + 1) {
      setTimeout(() => {
        setAnimate("none");
        setCurrentIndex(1);
        setTimeout(() => {
          setAnimate("transform 0.5s ease");
        }, 50);
      }, 550);
    }
  }, [currentIndex, totalItems]);

  return (
    <div className="banner-container">
      <div
        className="banner-wrapper"
        ref={wrapperRef}
        style={{
          transform: `translateX(-${
            currentIndex * singleOffset - initOffset
          }px)`,
          transition: animate,
          gap: `${gap}px`,
        }}
      >
        {[banner[banner.length - 1], ...banner, ...banner].map(
          (item, index) => (
            <div
              style={{
                width,
              }}
              key={`${item.id}-${index}`}
              className="banner-item"
            >
              <img src={item.url} alt={`banner-${item.id}`} />
            </div>
          )
        )}
      </div>
      {dotVisible ? (
        <div className="swiper-dot">
          {banner.map((item, index) => (
            <div
              key={item.id}
              className={`dot${currentDot === index ? " dot-active" : ""}`}
            ></div>
          ))}
        </div>
      ) : (
        <></>
      )}
    </div>
  );
};

export default Banner;
// [End Rotating_broadcasting_layout]