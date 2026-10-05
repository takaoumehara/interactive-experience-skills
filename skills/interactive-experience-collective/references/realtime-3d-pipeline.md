# リアルタイム3D・アセットパイプライン設計リファレンス

<!-- volatile: 2026-09 — Babylon.js / Three.js / PlayCanvas / Unreal Engine / Blender の現行バージョン、WebGPU・WebXR・Pixel Streaming の対応状況、拡張機能名、CLI オプション。製品名・機能・対応端末を回答に使う時は公式情報と対象実機で再確認する。 -->

## このファイルを読む条件

次のいずれかが中心なら読む。

- Babylon.js / Three.js / React Three Fiber / PlayCanvas / WebXR の選定
- Blender から Web または Unreal へ渡す 3D アセットパイプライン
- Unreal Engine の nDisplay / Live Link / Niagara / DMX / Pixel Streaming を使うライブ体験
- glTF / GLB、リグ、アニメーション、LOD、テクスチャ圧縮、描画負荷の設計

API の網羅ではなく、**何をどこに持たせ、どう壊れ、何を実機で証明するか**を決めるためのリファレンスである。

## 1. 最初に分ける — 制作道具、実行環境、制御系

この3つを同列の「ソフト候補」にしない。

| 層 | 主な候補 | 所有させるもの |
|---|---|---|
| DCC / 正本 | Blender | モデル、リグ、アニメーション、UV、マテリアル元データ、衝突用形状、書き出し設定 |
| リアルタイム実行 | Babylon.js / Three.js / PlayCanvas / Unreal Engine | ワールド状態、描画、物理、音、入力に対する反応 |
| 入出力・ショー制御 | OSC、Live Link、DMX、MIDI、専用 show control | 外部データの受け渡し、キュー、安全状態、手動 GO、監視、復旧 |

**Blender はランタイムの代替ではない。** Unreal と Babylon.js も同じ土俵ではない。Web 配布と会場の GPU クラスターでは、最適化すべきものが違う。

## 2. 何が作れるか — 器から逆算しない

| 作りたいもの | 第一候補 | 理由 | 主な代償 |
|---|---|---|---|
| URL で即開始する 3D / AR / VR、物理楽器、参加型作品 | **Babylon.js** | WebXR、物理、音、glTF、デバッグ・ノード編集を一体で持たせやすい | バンドルと抽象層が増える。端末別の WebGPU / WebXR 検証が必要 |
| 独自シェーダー、生成表現、最小限のシーン管理、巨大な Web エコシステム活用 | **Three.js** | レンダラーを細かく制御しやすく、周辺資産が多い | XR・物理・音・編集環境は組み合わせの設計が増える |
| ブラウザ3Dをエディター中心で共同制作・運用 | **PlayCanvas** | シーン・資産・公開をチームで扱いやすい | ホスティング／エディターの作法への依存が増える |
| フォトリアルな大型会場、複数投影・LED、仮想撮影、高密度 VFX | **Unreal Engine** | Niagara、Live Link、nDisplay、DMX、Sequencer 等が会場制作に接続する | GPU・同期機材・運用要員・ビルド／復旧設計のコスト |
| モデル、リグ、アニメーション、ベイク、プロシージャル生成、オフライン画作り | **Blender** | オープンな DCC と Python 自動化。Web と Unreal の両方へ供給できる | 書き出し後の見え方と実行性能は別工程で検証が必要 |

**選定原則:** 機能数ではなく、作品の中心となる状態を最も少ない境界で所有できる器を選ぶ。

- WebXR + 物理 + 音 + glTF が一体なら Babylon.js を先に検討する。
- レンダリング技法そのものが作品で、独自の GPU パスを握りたいなら Three.js / 生 WebGPU を先に検討する。
- アーティストがブラウザ上のエディターで資産を更新するなら PlayCanvas を検討する。
- 複数出力の同期、舞台入力、高密度 VFX が本質なら Unreal を検討する。
- Blender はどのランタイムを選んでも、資産の正本と再現可能な書き出し工程として使える。

## 3. Babylon.js — 「Three.js の代替」で終わらせない

Babylon.js 9.x は WebGL と WebGPU を同じエンジン系で扱い、WebXR、Havok 物理、GPU パーティクル、glTF、空間音響、各種ノードエディター、Frame Graph 系の描画構成をまとめて持つ。したがって、**単一のブラウザ・ランタイムに XR / 物理 / 音 / 資産 / デバッグを集約したい時**に強い。

### 向く構成

```text
[camera / touch / controller / body features]
                    ↓
            [interaction state]
                    ↓
[Havok physics] ↔ [scene/world state] ↔ [audio state]
                    ↓
 [WebGPU or WebGL renderer + XR presentation]
```

状態の所有者を一つにする。React、アニメーションライブラリ、物理エンジン、Babylon の render loop が同じ transform を同時に書き換えない。

### Babylon.js を選ぶ前に証明すること

1. 対象端末の **ブラウザ × GPU backend × XR mode** の組み合わせが動く。
2. WebGPU 非対応または不安定時に WebGL へ落ちても、体験の中心が残る。
3. 物理更新、入力推論、描画、音声処理の時間を別々に計測できる。
4. XR を開始できない時に、非 XR の 3D / 2D 版へ戻れる。
5. GPU loss、タブ非表示、音声ロック、権限拒否から再開できる。

### 粒子・物理・XR の劣化順

固定の「10万粒子なら動く」とは言わない。対象機のフレーム時間で、次を一段ずつ落とす。

1. ポスト処理の品質と回数
2. 内部描画解像度
3. 粒子数・更新頻度・衝突対象
4. 物理 substep、剛体数、衝突形状の複雑さ
5. 動的ライト／影
6. WebGPU → WebGL の代替表現
7. XR → 非 XR の同一インタラクション

**粒子を減らすだけで済ませない。** 体験の署名的振る舞いが「密度」なら、数を落とす代わりに粒径・残像・流れ場・音で知覚密度を守る。

## 4. Blender → ランタイム — ファイルではなく契約を渡す

### 推奨パイプライン

```text
.blend 正本
  ↓ scene contract / deterministic export
GLB・glTF（Web） / FBX・USD・glTF 等（対象 Unreal 工程）
  ↓ post-process: geometry / animation / texture compression
validator
  ↓
空の対象プロジェクトへ fresh import
  ↓
見た目・階層・アニメーション・負荷の比較
```

### `.blend` 側のシーン契約

- 単位、上方向、原点、前方向、スケールを固定する。
- export 対象 collection を分け、命名を安定させる。
- 見た目用 mesh、collision proxy、socket / attachment、LOD を分ける。
- 変換適用の方針を決め、リグとアニメーションで不用意に破らない。
- マテリアルは対象フォーマットが運べる PBR 表現へ寄せる。Blender 内だけのノードはベイクまたは代替する。
- runtime が名前で参照する node、custom property / extras、animation clip を一覧にする。
- Python を使うなら、GUI 操作の記録ではなく同じ入力から同じ export を再生成できる処理にする。

### 書き出し後の工程

- Web の第一候補は glTF / GLB。glTF-Blender-IO の対象 Blender 版に合う設定を使う。
- gltfpack / meshoptimizer 等で geometry、animation、quantization、pruning を行えるが、**名前付き node や extras を runtime が使う場合は、merge / prune から守る。**
- KTX2 / Basis 系の GPU texture compression は転送量と GPU memory の両方に効く。color texture は sRGB、normal / ORM 等の data texture は linear として扱う。
- ORM の channel packing、normal map の向き、alpha mode、double-sided、skin weights、morph target は対象 runtime で確認する。
- glTF Validator の成功だけで完了にしない。**最終成果物を新規シーンへ読み直し、見た目と実行性能を比較する。**

### 一律の上限値を置かない

「1モデル5MB」「5万 polygon」「texture は必ず2K」のような数字を設計原則にしない。次を対象機・最悪シーンで予算化する。

- draw call と material / shader variant 数
- 可視 triangle / vertex と overdraw
- skinning 対象数、bone 数、animation clip の容量と更新時間
- texture の GPU memory、転送量、decode 時間、同時常駐量
- shader compile / pipeline creation による初回停止
- asset download、parse、GPU upload、最初の操作可能時刻
- LOD 切替時の視覚差と frame-time 改善量

10体のキャラクターなら「10体だから重い」ではなく、**同一 mesh / material を共有できるか、各体が別 skin / animation を持つか、画面占有率、影、透明、表情 morph がいくつ同時に動くか**で決める。

## 5. Unreal — 一つの箱ではなく複数の役割として組む

| 系統 | 役割 | 持たせないもの |
|---|---|---|
| **Live Link** | 外部 mocap、camera、animation stream の取り込み | show 全体の安全制御 |
| **OSC / Remote Control** | scalar、event、operator control、外部 UI | skeletal stream の主経路 |
| **Niagara / Data Channels** | 大量 VFX、game code と Niagara 間／system 間の data-driven simulation | 会場全体の唯一の状態管理 |
| **nDisplay** | 複数 render node / display の clustered rendering | 物理 display の同期保証そのもの |
| **DMX** | fixture control、Unreal 内の照明可視化／連携 | 最終的な非常停止と法的安全責任 |
| **Pixel Streaming** | GPU host 上の Unreal を WebRTC で browser へ届ける | 端末内実行と同等の無運用・無遅延 |
| **Motion Design / PCG** | procedural motion graphics / world generation | 入出力・復旧のオーケストレーション |

### ライブ設備の基本構成

```text
[mocap] ─Live Link──────────────┐
[sensors] ─OSC / adapter────────┤
                                ▼
                     [authoritative world state]
                                │
                     [Niagara / scene / audio]
                                │
                     [nDisplay render cluster]
                                ▼
                  [projectors / LED processors]

[operator/show control] ─OSC/Remote Control─┐
[lighting console] ←──────── DMX / Art-Net ─┤
[health + watchdog + manual GO/failsafe] ───┘
```

**world state の所有者**と**show-control / safety の所有者**を分ける。Unreal が描画を所有しても、全装置の非常停止を Unreal の生存に依存させない。

### 同期は3層に分ける

1. **time source:** timecode、共通 clock、入力 timestamp。
2. **cluster frame sync:** nDisplay node が同じ frame を進める同期。
3. **physical display sync:** GPU・display processor・projector / LED の genlock / framelock。

nDisplay の frame sync があるだけで、カメラ撮影時の継ぎ目や複数 display の tear が消えるとは限らない。必要なら専門ハードウェアを含めて実機で同期線と phase を確認する。

### 障害別の安全状態

| 障害 | 直後の状態 | 自動処理 | 手動復旧 |
|---|---|---|---|
| sensor / mocap loss | 最後の姿勢を凍結せず、neutral / idle へ補間 | source timeout、再接続 | operator が tracking 確認後 GO |
| input process 停止 | 反応を停止し attract / safe scene へ | watchdog restart | calibration 再確認 |
| render node 停止 | 壊れた面だけが誤情報を出さない safe output | node isolation / controlled restart | cluster 再同期後 GO |
| network loss | 危険な actuator / lighting cue を保持しない | local safe state | network と time source の確認 |
| Unreal crash | 外部 show control と照明安全系は生存 | supervised restart | content / sync / input の順に確認 |

## 6. 共通の性能予算 — fps だけを見ない

| 予算 | 見るもの |
|---|---|
| frame-time | CPU game/update、GPU、render thread、worst 1% frame、jitter |
| response | sensor exposure → inference → transport → state update → render/audio → display/speaker |
| scene | draw call、material、transparent overdraw、light/shadow、simulation count |
| asset | transfer、decode、parse、GPU upload、texture memory、animation memory |
| operation | cold start、scene change、device reconnect、process restart、full recovery |

60fps の予算は約16.7msだが、平均16.7msを目標にすると余白がない。**対象機の worst frame と、入力から知覚出力までの end-to-end latency を別に測る。** 音の thread は描画負荷から守る。

## 7. 検証マトリクス

| 証明したいこと | 最小の証拠 |
|---|---|
| engine 選定 | 同じ中心インタラクションを候補2つで小さく作り、複雑さ・frame-time・配布／運用を比較 |
| browser 対応 | 対象端末 × browser × WebGPU/WebGL × XR/非XR の表と実測 |
| asset 契約 | 正本から自動 export → validator → fresh import のログと visual diff |
| performance | target device の capture。平均 fps だけでなく CPU/GPU 内訳と worst frame |
| large venue sync | frame counter / flash / grid の検証 content を全出力に出し、high-speed camera で確認 |
| failover | cable disconnect、process kill、node loss、再起動を本番順序で rehearsal |
| operator readiness | 非エンジニアが cold boot、GO、停止、復旧を runbook だけで実行 |

## 8. 実装時に使う補助リソース

この Skill は設計判断を担う。API・エディター操作が中心になったら、巨大な操作手順をここへ複製せず、現行の公式資料や専用 Skill / MCP を併用する。

- Babylon.js の API・source 検索: Babylon.js 公式 docs / repository。必要なら `babylon-mcp` のような索引ツールを別途導入する。
- Unreal Editor の操作自動化: Epic Games 公式の `unreal-engine-skills-for-claude-code-plugin` は MCP 操作と Skill authoring を分離している。
- Blender の制作自動化: deterministic Python、scene inspection、export artifact の fresh import を扱える専用 Skill を選ぶ。
- glTF の適合性: Khronos の glTF specification / Validator / Blender I/O を正とする。

## 9. 一次資料

- [Babylon.js Specifications](https://www.babylonjs.com/specifications/)
- [Babylon.js 9.0 announcement](https://blogs.windows.com/windowsdeveloper/2026/03/26/announcing-babylon-js-9-0/)
- [Babylon.js WebGPU documentation source](https://github.com/BabylonJS/Documentation/blob/master/content/setup/support/webGPU.md)
- [Babylon.js Havok physics documentation source](https://github.com/BabylonJS/Documentation/blob/master/content/features/featuresDeepDive/physics/v2/usingPhysicsEngine.md)
- [Blender release compatibility and LTS](https://developer.blender.org/docs/release_notes/compatibility/)
- [Khronos glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO)
- [Khronos glTF 2.0 specification](https://github.com/KhronosGroup/glTF/blob/main/specification/2.0/Specification.adoc)
- [Khronos glTF Validator](https://github.com/KhronosGroup/glTF-Validator)
- [meshoptimizer / gltfpack](https://github.com/zeux/meshoptimizer)
- [KTX 2.0 specification](https://github.khronos.org/KTX-Specification/ktxspec.v2.html)
- [Unreal Engine nDisplay overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/ndisplay-overview-for-unreal-engine)
- [Synchronization in nDisplay](https://dev.epicgames.com/documentation/en-us/unreal-engine/synchronization-in-ndisplay-in-unreal-engine)
- [Unreal Engine Live Link](https://dev.epicgames.com/documentation/en-us/unreal-engine/live-link-in-unreal-engine)
- [Niagara Data Channels](https://dev.epicgames.com/documentation/en-us/unreal-engine/data-channels-in-niagara-for-unreal-engine)
- [OSC plugin](https://dev.epicgames.com/documentation/en-us/unreal-engine/osc-plugin-overview-for-unreal-engine)
- [DMX quick start](https://dev.epicgames.com/documentation/en-us/unreal-engine/dmx-quick-start-in-unreal-engine)
- [Remote Control](https://dev.epicgames.com/documentation/en-us/unreal-engine/remote-control-for-unreal-engine)
- [Pixel Streaming](https://dev.epicgames.com/documentation/en-us/unreal-engine/pixel-streaming-in-unreal-engine)
- [Epic Games Unreal Engine Skills plugin](https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin)

## 吸収したローカル資料について

`designskill-main` の Babylon.js / Blender Web Pipeline / Web3D Integration / PlayCanvas / Substance 3D の各 Skill から、耐久性のある判断（状態所有の分離、glTF 書き出し契約、LOD、PBR texture の色空間、圧縮、検証）を統合した。特定バージョンの API 断片や一律の容量・polygon 上限は引き継がず、現行の公式一次資料と実測を優先する。
