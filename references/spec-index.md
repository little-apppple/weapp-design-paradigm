# 规范索引与来源台账（集中 Review 用）

> 本文件是 skill 的「单一事实来源」索引：每个主题只对应一处权威文档，避免多处冲突。改动任何规范前先查此表。

---

## 一、本 skill 文档地图

| 文件 | 负责内容 | 不负责 |
|------|---------|--------|
| `SKILL.md` | 入口、红线、决策流程、五大范式、检查清单 | 原文细节 |
| `references/official-design-guide.md` | 官方设计指南七章原文整理 | 适配实现 |
| `references/layout-adaptation.md` | 单位(rpx/vw)、设计稿基准、断点、旋转、媒体查询、大屏 7 布局、栅格、分栏 | 具体机型数值 |
| `references/api-guide.md` | getWindowInfo / 胶囊 / 设备信息 API 字段与降级 | 布局策略 |
| `references/device-data.md` | iOS/Android/平板机型实测数值、rpx 换算、异常阈值 | 编码取值 |
| `references/theme-accessibility.md` | DarkMode、适老化、无障碍 | 布局适配 |
| `references/navbar-component.md` | 自定义导航栏组件四件套 | 其他组件 |

---

## 二、官方来源台账

| # | 文档 | URL | 抓取日期 | 用于 |
|---|------|-----|---------|------|
| 1 | 微信小程序设计指南（7 章） | https://developers.weixin.qq.com/miniprogram/design/ | 2026-10-26 | official-design-guide.md |
| 2 | 小程序大屏适配指南（设计） | https://developers.weixin.qq.com/miniprogram/design/adapt | 2026-10-26 | layout-adaptation.md §5 |
| 3 | 大屏适配指南（框架） | https://developers.weixin.qq.com/miniprogram/dev/framework/ability/adapt.html | 2026-10-26 | layout-adaptation.md §4/5.5 |
| 4 | 响应显示区域变化（resizable） | https://developers.weixin.qq.com/miniprogram/dev/framework/view/resizable.html | 2026-10-26 | layout-adaptation.md §3 |
| 5 | WXSS 尺寸单位 | https://developers.weixin.qq.com/miniprogram/dev/framework/view/wxss.html | 2026-10-26 | layout-adaptation.md §2 |
| 6 | app.json 全局配置 | https://developers.weixin.qq.com/miniprogram/dev/reference/configuration/app.html | 2026-10-26 | layout / SKILL 配置 |
| 7 | page.json 页面配置 | https://developers.weixin.qq.com/miniprogram/dev/reference/configuration/page.html | 2026-10-26 | SKILL 范式一 |
| 8 | wx.getWindowInfo | https://developers.weixin.qq.com/miniprogram/dev/api/base/system/wx.getWindowInfo.html | 2026-10-26 | api-guide.md |
| 9 | button 组件 | https://developers.weixin.qq.com/miniprogram/dev/component/button.html | 2026-10-26 | official-design-guide.md §5.5 |
| 10 | DarkMode 适配指南 | https://developers.weixin.qq.com/miniprogram/dev/framework/ability/darkmode.html | 2026-10-26 | theme-accessibility.md §1 |
| 11 | 小程序适老化设计指南 | https://developers.weixin.qq.com/miniprogram/design/elderly.html | 2026-10-26 | theme-accessibility.md §2 |
| 12 | 小程序无障碍设计指南 | https://developers.weixin.qq.com/miniprogram/design/accessibility.html | 2026-10-26 | theme-accessibility.md §3 |
| 13 | WeUI 组件库 | https://weui.io | 2026-10-26 | 视觉参考 |

---

## 三、单一事实来源（SSOT）

| 主题 | 唯一权威文件 | 关键结论 |
|------|-------------|---------|
| 字号阶梯 | official-design-guide.md §5.1 | 22/17/15/14/12pt = 44/34/30/28/24rpx |
| 单位选择 | layout-adaptation.md §2 | 官方优先 vw；rpx 需防大屏放大 |
| 设计稿基准 | official-design-guide.md §6 | 375px 固定 / 390px 响应式 |
| 断点 | layout-adaptation.md §4.4 | 480/768/1024/1200（经验值） |
| 大屏布局 | layout-adaptation.md §5.3 | 官方 7 种模式 |
| 导航栏高度 | api-guide.md 核心公式 | `navBarHeight = menu.bottom + gap` |
| 安全区计算 | api-guide.md | `screenHeight - safeArea.bottom` |
| Tab 数量 | official-design-guide.md §2.1 | 2-5，建议 ≤4 |
| 触控尺寸 | official-design-guide.md §3.2 | 7-9mm；适老化最小 40×40pt |
| 暗色配置 | theme-accessibility.md §1 | `darkmode` + `theme.json` @变量 |
| 无障碍 | theme-accessibility.md §3 | aria-component + 4.5:1 |

---

## 四、版本基线

| 能力 | 最低基础库 |
|------|-----------|
| `wx.getWindowInfo` / `getDeviceInfo` / `getAppBaseInfo` | 2.20.1 |
| `wx.getMenuButtonBoundingClientRect` | 2.1.0 |
| `pageOrientation: auto` | 2.4.0 |
| `pageOrientation: landscape` | 2.5.0 |
| `resizable` | 2.3.0 |
| 大屏模式 | 2.21.3 |
| DarkMode | 2.11.0 |
| `convertRpxToVw` | 3.3.0 |
| Skyline 渲染 | 2.29.2+（需后台开通） |

---

## 五、已知冲突与修正记录

| 项 | 问题 | 处理 |
|----|------|------|
| `safeAreaInsets` | 旧 api-guide 将其列为 `getWindowInfo` 字段，官方无此字段（仅旧 `getSystemInfo` 有） | 已从 getWindowInfo 表移除，改为由 `screenHeight - safeArea.bottom` 计算 |
| rpx 定位 | 旧文档把 rpx 当唯一推荐单位 | 已按官方 WXSS 更新：优先 vw，rpx 需配合响应式，3.3.0+ 可 `convertRpxToVw` |
| 媒体查询支持度 | 旧文档称「@media 支持度一般」 | 已更正：官方明确支持 CSS 媒体查询，并提供 match-media / MediaQueryObserver |
| iPad 旋转 | 旧表述「后台开启屏幕旋转」 | 统一为 `app.json` 配 `resizable: true` |
| 导航栏总高 | device-data 按原生「状态 + 44」，组件/公式按胶囊对齐「状态 + 40」，相差 4px | 统一为胶囊对齐；device-data 已更新并注明与原生差 4px |
| onResize 重算 | 旧示例直接读 globalData 缓存，旋转后导航高度不更新 | 改为先调用 `calcNavBarInfo()` 重算，再读取 |
| safeArea 判空 | 旧示例直接 `win.safeArea.bottom`，部分机型无 safeArea 会报错 | 全部改为 `win.safeArea ? ... : 0` |

---

## 六、Review 记录

| 日期 | 范围 | 结果 |
|------|------|------|
| 2026-10-26 | 全量整合 + 集中 review | 链接 0 死链；11 个 JS 块语法通过；表格列数一致；修正 7 处（见上表），新增 layout-adaptation / theme-accessibility / spec-index 三份文档 |

---

## 七、待验证项（需真机确认）

- Skyline 下 `env(safe-area-inset-*)` 的实际支持程度（官方文档未给明确结论，以真机为准）。
- iPad 分屏/横屏下胶囊 `getMenuButtonBoundingClientRect` 返回值是否为估算值。
- `row/col` 组件需引入扩展库（`useExtendedLib`）后的实际表现。
- 适老化 1.4 倍率对自定义导航栏的实际影响（官方要求单独适配，未给具体公式）。
