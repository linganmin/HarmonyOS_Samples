/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Config
 */
public class Config {
    @JsonProperty("service_timeline_server_domain")
    private String serviceTimelineServerDomain;

    @JsonProperty("project_id")
    private String projectId;

    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("scene_id")
    private String sceneId;

    @JsonProperty("sub_scene_id")
    private String subSceneId;

    public Config() {
    }

    public String getServiceTimelineServerDomain() {
        return serviceTimelineServerDomain;
    }

    public void setServiceTimelineServerDomain(String serviceTimelineServerDomain) {
        this.serviceTimelineServerDomain = serviceTimelineServerDomain;
    }

    public String getProjectId() {
        return projectId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getSceneId() {
        return sceneId;
    }

    public void setSceneId(String sceneId) {
        this.sceneId = sceneId;
    }

    public String getSubSceneId() {
        return subSceneId;
    }

    public void setSubSceneId(String subSceneId) {
        this.subSceneId = subSceneId;
    }
}
