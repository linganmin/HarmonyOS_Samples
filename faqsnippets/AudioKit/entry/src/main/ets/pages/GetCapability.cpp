/*
* FAQ:如何获取系统支持的编解码能力
 */
// [Start GetCapability1]
// Obtain an example of the recommended audio AAC decoder capability from the system
OH_AVCapability *capability = OH_AVCodec_GetCapability(OH_AVCODEC_MIMETYPE_AUDIO_AAC, false);
// [End GetCapability1]

// [Start GetCapability2]
// Obtain an instance of video AVC encoder capability for the specified hardware
OH_AVCapability *capability = OH_AVCodec_GetCapabilityByCategory(OH_AVCODEC_MIMETYPE_VIDEO_AVC, true, HARDWARE);
// [End GetCapability2]