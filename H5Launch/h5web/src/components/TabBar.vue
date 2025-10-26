<template>
  <div class="tabs">
    <div class="tab-list">
      <span class="tab-item" v-for="(tab, index) in tabs" :key="index" :class="{ 'active': activeIdx === index }"
        @click="switchTab(index)">
        {{ tab.name }}
      </span>
    </div>
    <swiper @swiper="onSwiper" @slideChange="onSlideChange">
      <swiper-slide v-for="(tab, index) in tabs" :key="index">
        <TabContent />
      </swiper-slide>
    </swiper>
  </div>
</template>

<script>
import { Swiper, SwiperSlide } from 'swiper/vue';
import 'swiper/css';
import { ref } from 'vue';
import TabContent from './TabContent.vue'

export default {
  components: {
    TabContent,
    Swiper,
    SwiperSlide
  },
  data() {
    return {
      tabs: (() => {
        const params = new URLSearchParams(window.location.search);
        const isEn = params.get('filename') === 'newsData_en';
        return isEn ? [
          { id: 0, name: 'Home' },
          { id: 1, name: 'Recommended' }
        ] : [
          { id: 0, name: '首页' },
          { id: 1, name: '推荐' }
        ]
      })(),
      swiperOptions: {
        slidesPerView: 1,
        spaceBetween: 30,
        freeMode: true,
        longSwipesMs: 200,
        longSwipesRatio: 0.5,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
      }
    }
  },
  setup() {
    let activeIdx = ref(0);
    let _s;
    const onSwiper = (swiper) => {
      _s = swiper;
    };
    const onSlideChange = (swiper) => {
      activeIdx.value = swiper.activeIndex;
    };
    const switchTab = (index) => {
      _s.slideTo(index);
      activeIdx.value = index;
    }
    return {
      activeIdx,
      switchTab,
      onSwiper,
      onSlideChange,
    };
  },
}
</script>

<style scoped>
.tabs {
  position: relative;
  width: 100%;
  height: 100%;
  background-color: #f1f3f5;
}

.tab-list {
  display: flex;
  height: 7.2%;
  width: 93.3%;
  margin-left: 3.3%;
  align-items: center;
}

.swiper {
  height: 92.8%;
}

.tab-item {
  cursor: pointer;
  padding: 0 2.2%;
  font-size: 18px;
  font-weight: 400;
  color: #182431;
}

.tab-item.active {
  font-size: 24px;
  font-weight: 600;
}

.swiper-slide {
  text-align: center;
  font-size: 18px;
  background: #fff;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}
</style>