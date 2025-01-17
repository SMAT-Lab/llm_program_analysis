/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export interface CameraConfig {
  mirrorBol: boolean, // 镜像使能
  videoStabilizationMode: number, // 视频防抖
  exposureMode: number, // 曝光模式
  focusMode: number, // 对焦模式
  photoQuality: number, // 拍照质量
  locationBol: boolean, // 显示地理位置
  photoFormat: number, // 照片格式
  photoOrientation: number, // 照片方向
  photoResolution: number, // 照片分辨率
  videoResolution: number, // 照片分辨率
  videoFrame: number, // 录像帧率
  referenceLineBol: boolean, // 分割线
  hdrPhotoBol: boolean, // HDR 拍摄
  hdrVideoBol: boolean, // HDR 录制
}