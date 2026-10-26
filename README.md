# 微信小程序设计范式（weapp-design-paradigm）

微信小程序界面设计与适配规范合集，面向 AI Agent 的 Skill 包。整合微信官方设计指南、大屏适配指南、DarkMode、适老化、无障碍五套规范，并给出可落地的代码方案。

当前版本：**1.2.0**

## 解决什么问题

小程序界面适配的坑高度集中，且几乎全部源于硬编码：

| 问题 | 典型症状 | 本 Skill 的答案 |
|------|---------|----------------|
| 状态栏沉浸 | 内容被状态栏压住，或顶部留出奇怪空白 | `navigationStyle: custom` 配合动态计算导航栏高度 |
| 胶囊避让 | 自定义标题被胶囊按钮遮住 | `getMenuButtonBoundingClientRect` 动态测量，不写死 87px |
| 安全区 | iPhone 底部 Home 条压住吸底按钮 | `env(safe-area-inset-bottom)` 加 JS 兜底 |
| 大小屏 | iPad 上内容被拉伸成一条 | `max-width` 封顶加断点布局，大屏 7 种官方布局模式 |
| 系统组件 | 覆盖层被 map/video 盖住 | cover-view 与同层渲染边界 |
| 主题与无障碍 | 暗色模式失效，字号放大后布局崩 | `theme.json`、关怀模式 1.4 倍、aria-component |

核心原则只有一条：**所有边界尺寸动态获取，禁止硬编码**。

## 仓库结构

```
.
├── SKILL.md                          # 主文件：六套范式 + 决策流程 + 检查清单
└── references/
    ├── official-design-guide.md      # 官方设计指南七章 + 视觉规范 + 落地映射
    ├── layout-adaptation.md          # 单位/基准/断点/旋转/媒体查询/大屏布局/栅格
    ├── theme-accessibility.md        # DarkMode / 适老化 / 无障碍
    ├── api-guide.md                  # getWindowInfo / 胶囊 / safeArea 字段与降级
    ├── device-data.md                # 主流机型状态栏、导航栏、安全区实测数据
    ├── navbar-component.md           # 自定义导航栏组件四件套（可按文件名直接保存使用）
    └── spec-index.md                 # 规范索引、官方来源台账、冲突修正记录
```

## 安装

方式一，直接复制到 WorkBuddy 用户级技能目录：

```bash
git clone https://github.com/little-apppple/weapp-design-paradigm.git
cp -r weapp-design-paradigm ~/.workbuddy/skills/
```

方式二，从 SkillHub 安装（slug 保持不变，按版本更新）：

```bash
skillhub install weapp-design-paradigm
```

安装后按触发词自动加载：小程序设计、设计规范、小程序适配、导航栏、状态栏、沉浸式、胶囊、安全区、刘海屏、rpx、vw、大小屏、大屏、PC 适配、暗色模式、适老化、无障碍。

## 关键规范速查

- 字体梯度：22 / 17 / 15 / 14 / 12 pt 对应 44 / 34 / 30 / 28 / 24 rpx，正文不小于 24rpx
- 触控热区：7 至 9 mm，适老化场景不小于 40×40 pt
- 底部 Tab：2 至 5 个，建议不超过 4 个，图标 81px
- 设计稿基准：375px 固定布局；390px 响应式布局
- 对比度：正文不低于 4.5:1，大字号不低于 3:1
- 单位策略：官方已优先推荐 vw，rpx 需配合响应式；3.3.0 起可用 `convertRpxToVw`
- 大屏默认：PC 未适配时按 414×736 与 768×1024 渲染，需配 `resizable: true`
- 已废弃 API：`getSystemInfoSync` 一律替换为 `getWindowInfo`

## 数据来源

全部内容来自微信官方文档，抓取与整理时间 2026-10-26：

- 设计指南 `developers.weixin.qq.com/miniprogram/design/`
- 大屏适配指南 `/miniprogram/design/adapt`
- 适老化设计指南 `/miniprogram/design/elderly.html`
- 无障碍设计指南 `/miniprogram/design/accessibility.html`
- 框架大屏适配 `/miniprogram/dev/framework/ability/adapt.html`
- 响应显示区域变化 `/miniprogram/dev/framework/view/resizable.html`
- WXSS `/miniprogram/dev/framework/view/wxss.html`
- 全局配置 app.json 与页面配置 page.json
- `wx.getWindowInfo` API 文档
- DarkMode 适配指南 `/miniprogram/dev/framework/ability/darkmode.html`

机型实测数据来自公开机型适配实践汇总，个别数值在不同系统版本有浮动，已在 `references/device-data.md` 标注异常阈值。

## 版本记录

- **1.2.0**：深度整合 11 份官方文档。新增 layout-adaptation、theme-accessibility、spec-index 三份 reference；新增范式六（主题/适老化/无障碍）与 3.5 大屏适配；修正 safeAreaInsets 字段错误、导航栏总高两套算法统一、safeArea 判空、onResize 旧缓存等 7 处问题；检查清单扩至 16 项
- **1.1.0**：并入官方设计指南七章全文，补 pt 到 rpx 换算与 WeUI 色板
- **1.0.0**：首次发布，五大范式 + 机型数据表 + 可复用导航栏组件

## 许可

内部使用的规范整理，官方规范原文版权归腾讯所有。二次分发请注明来源。
