<template>
  <div class="tab-view">
    <pull-refresh v-model="isLoading" @refresh="onRefresh" :loosing-text="isEn ? 'loosing to refresh' : '释放刷新'"
      :pulling-text="isEn ? 'drop down to refresh' : '下拉刷新'" :loading-text="isEn ? 'Loading' : '加载中'">
      <list v-model:loading="loading" :finished="finished" :loading-text="isEn ? 'Loading' : '加载中'"
        :finished-text="isEn ? 'No More Data' : '没有更多了'" :offset="80" @load="onLoad">
        <!-- 列表内容 -->
        <div class="list" v-for="(item, index) in list" :key="index">
          <div class="list-title">
            <img :src="require('@/assets/news.png')" alt="">
            <span>{{ item.title }}</span>
          </div>
          <p class="list-content">{{ item.content }}</p>
          <div class="list-imgs" :style="{ gridTemplateColumns: '1fr '.repeat(item.imagesUrl?.length ?? 0) }">
            <div class="img" v-for="(img, i) in item.imagesUrl" :key="i">
              <img :src="img.url" alt="">
            </div>
          </div>
          <p class="list-date">{{ item.source }}</p>
        </div>
      </list>
    </pull-refresh>
  </div>
</template>

<script>
import { PullRefresh, List } from 'vant'
import 'vant/lib/pull-refresh/style'
import 'vant/lib/list/style'

export default {
  name: 'Tab1View',
  components: {
    PullRefresh,
    List,
  },
  data() {
    return {
      params: new URLSearchParams(window.location.search),
      list: [], // 列表数据
      finished: false, // 是否加载完成
      loading: false, // 是否正在加载
      isLoading: false, // 是否正在下拉刷新
      pageNumber: 1, // 当前页码
      pageSize: 5, // 每页数据量
      total: 20, // 总数据量
    }
  },
  computed: {
    isEn() {
      return this.params.get('filename') === 'newsData_en';
    }
  },
  mounted() {
    window.addEventListener('online', this.setOnline);
  },
  unmounted() {
    window.removeEventListener('online', this.setOnline);
  },
  methods: {
    setOnline() {
      this.loading =  false;
      this.isLoading = false;
    },
    // 下拉刷新
    onRefresh() {
      if (!window.navigator.onLine) return;
      this.isLoading = true;
      this.finished = false;
      this.pageNumber = 1; // 重置页码
      this.fetchData().finally(() => {
        this.isLoading = false;
      });
    },
    // 上拉加载更多
    onLoad() {
      if (this.finished || !window.navigator.onLine) return; // 如果已经加载完成，则不执行
      this.loading = true;
      this.fetchData().then(() => {
        if (this.list.length >= this.total) {
          this.finished = true; // 更新完成状态
        }
      }).finally(() => {
        this.loading = false;
      });
    },
    // 数据请求
    async fetchData() {
      const filename = this.params.get('filename') ?? 'newsData';
      const response = await fetch(`/api/getSceneMockData?scene=newsData&fileName=${filename}.json&pageNum=${this.pageNumber}&pageSize=${this.pageSize}`);
      const data = await response.json();
      this.list = this.pageNumber === 1 ? data.data : this.list.concat(data.data);
      this.pageNumber++;
    },
  }
}
</script>

<style scoped>
.tab-view {
  width: 100%;
  height: 100%;
  padding: 0 3.3%;
  background-color: #f1f3f5;
  overflow-y: scroll;
  text-align: left;
}

.list {
  width: 100%;
  background-color: #fff;
  margin-bottom: 2.8%;
  border-radius: 16px;
}

.list-title {
  display: flex;
  align-items: center;
}

.list-title span {
  font-size: 16px;
  color: #000;
  width: 78.6%;
  height: 20px;
  font-weight: 700;
  margin-left: 10px;
  margin-top: 16px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.list-title img {
  height: 20px;
  margin-top: 16px;
  margin-left: 3.5%;
  object-fit: contain;
}

.list-content {
  font-size: 14px;
  color: #000;
  width: 93%;
  line-height: 20px;
  margin: 0;
  margin-top: 10px;
  margin-left: 3.5%;
  overflow: hidden;
  text-overflow: ellipsis;
  word-wrap: normal;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.list-imgs {
  width: 93%;
  display: grid;
  grid-template-rows: 1fr;
  margin: 10px 3.5% 0;
  column-gap: 5px;
  overflow: hidden;
}

.list-imgs .img {
  height: 80px;
}

.list-imgs img {
  border-radius: 8px;
  object-fit: cover;
  width: 100%;
  height: 100%;
}

.list-date {
  font-size: 12px;
  color: #989898;
  padding: 10px 0;
  margin: 0;
  margin-left: 3.5%;
}
</style>