// [Start embed]
<template>
  <div>
    <embed
      id= "embedId"
      type="native/lottie"
      :width="300" :height="150" />
  </div>
</template>

<script>
export default {
  name: "HlLottie",
  props: {
    sourceJson: {
      type: String,
      required: false,
    },
  },
  // ...
  methods: {
    play() { /*..*/ },
  },
}
</script>
// [End embed]