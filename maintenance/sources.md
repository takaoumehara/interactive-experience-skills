# 監視する情報源

`UPDATE-ROUTINE.md` の月次調査で起点にする情報源。**ここに無い情報源を使ってはいけないという意味ではない**が、毎回ここは見る。

一次情報（公式・レジストリ・官報）を優先し、まとめ記事は「何が起きたかを知る入口」としてのみ使う。数値と日付は必ず一次情報で裏を取る。

---

## 1. 姿勢推定・身体トラッキング

| 種別 | 情報源 | 見るもの |
|---|---|---|
| レジストリ | npm `@mediapipe/tasks-vision` / `onnxruntime-web` / `@huggingface/transformers` / `@tensorflow/tfjs` | 最終公開日。**更新が止まったら、それ自体が最重要の情報** |
| レジストリ | PyPI `mmpose` / `ultralytics` / `pose2sim` / `sports2d` | 同上 |
| 公式 | github.com/google-ai-edge/mediapipe/releases | C++側とWeb側で更新状況が乖離することがある |
| 公式 | docs.ultralytics.com | 現行世代の型番とpose対応 |
| 公式 | Apple Developer（WWDCセッション、Vision / ARKit ドキュメント） | 身体系APIの更新有無。**「更新が無かった」も記録する** |
| 不具合 | Apple Developer Forums / Feedback の既知バグ | ARKit Body Tracking のような「壊れたまま放置」を検出する |
| 研究 | CVPR / SIGGRAPH のチュートリアルページ | 何が現行SOTAとして名指しされているか |

## 2. センサー・入力機材

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 直販 | store.orbbec.com / shop.luxonis.com / stereolabs.com | 現行ラインと**在庫状況**（売り切れは調達不能を意味する） |
| 公式 | realsenseai.com | 事業継続と新機種、出荷時期 |
| 公式 | Microsoft Azure Kinect リポジトリの Issue | EOLと後継の案内 |
| 価格 | Move.ai 料金ページ / Rokoko 価格ページ / MoCap Online の価格ガイド | mocapの課金単位（秒課金かどうか） |
| 買収 | 各社ニュースリリース、Crunchbase | 買収・分社・事業停止 |

## 3. リアルタイムエンジン・制作ソフト

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 公式 | docs.derivative.ca/Release_Notes（TouchDesigner） | ビルド番号、価格ページ、Python版 |
| 公式 | unrealengine.com/news + /license | メジャー版、ロイヤリティ、非ゲーム席料金、ロードマップ |
| 公式 | unity.com/releases + /products/pricing-updates | LTS、料金改定、バンドル除外 |
| 公式 | notch.one/pricing | プラン体系、ドングル要否 |
| 公式 | github.com/gpuweb/gpuweb/wiki/Implementation-Status | WebGPUのブラウザ別出荷状況 |
| 公式 | threejs.org（WebGPURenderer のステータス） | experimental が取れたか |
| まとめ | radiancefields.com | 3D Gaussian Splatting のエンジン対応状況 |
| 公式 | resolume.com / madmapper.com / thegraybook.vvvv.org / cycling74.com | 現行版 |

## 4. 出力機材・計算機

| 種別 | 情報源 | 見るもの |
|---|---|---|
| メーカー | Epson / Panasonic / Christie / Barco の製品ページとISE・InfoCommの発表 | 輝度あたり価格、新製品、出荷時期 |
| レンタル | 国内レンタル会社のカタログ（光和 等） | 定価ベースの相場。**実勢は定価の3〜5割**であることを注記して使う |
| 価格 | LEDメーカーの価格ガイド、国内SIerの価格ページ | ピッチ別 $/m²、COBとSMDの差、内外価格差 |
| 公式 | meta.com/blog（Quest価格） / apple.com/newsroom / samsung | XR機の価格と世代 |
| 市況 | GPU実売価格（複数小売の実売）、メモリ市況の報道 | **2026年はここが最大の変動要因** |

## 5. リアルタイムAI

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 公式 | Krea / Decart / fal.ai の製品ページと料金 | リアルタイム映像生成のfpsと秒単価 |
| モデル | Hugging Face のモデルカード | オープンウェイトの有無、必要GPU、ライセンス |
| 料金 | 各社Realtime API の料金ページ | 音声対話の分単価 |
| 実測 | 遅延・料金の実測記事 | p50/p95 の実測レンジ |

## 6. 法規制

| 種別 | 情報源 | 見るもの |
|---|---|---|
| EU | EUR-Lex（規則の官報掲載）/ digital-strategy.ec.europa.eu の AI Act FAQ | 施行日の変更、Article 50 の適用範囲 |
| EU | EDPB のガイドライン | 映像機器・生体データの解釈 |
| 日本 | 個人情報保護委員会 ppc.go.jp（改正法、政令、ガイドライン、カメラ関連資料） | **政令で何が「特定生体個人識別符号」に指定されるか** |
| 日本 | 総務省・経産省 カメラ画像利活用ガイドブック | 版の更新 |
| 日本 | 厚労省・PMDA のプログラム医療機器（SaMD）ガイダンス | 該当性判断の基準 |
| 米国 | Illinois BIPA の判例、Texas AG のプレスリリース、FTC の COPPA | 訴訟トレンドと執行 |

## 7. スタジオ・事業環境

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 各社 | 参照スタジオの公式サイト・ニュース | 存続、改称、買収、拠点の開閉 |
| 業界 | blooloop / AVNation / rAVe / Live Design | 施設の開業・閉館、導入事例 |
| 潮流 | Ars Electronica / SIGGRAPH / IDFA DocLab / Sónar+D / MUTEK / 文化庁メディア芸術祭系の受賞・出展作 | **どんな体験形式が出てきたか。**ファイルには書かず報告に留める |
| 潮流 | 主要な常設イマーシブ施設の新規オープンと閉館 | 体験形式の飽和と入れ替わり |
| 数値 | 実在施設のチケット価格ページ、運営企業のIR | 客単価と来場者数の実績値 |

---

## 8. 音・音楽

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 公式 | Web Audio API の仕様とブラウザ対応（MDN / caniuse）| AudioWorklet 等の対応状況 |
| 公式 | Cycling '74（Max）、Ableton、SuperCollider | 現行版と機能 |
| 権利 | JASRAC / NexTone の利用料規程、各国の管理団体 | **展示・イベントでの演奏権・シンクロ権の料率**（最も更新の見落としが痛い） |
| 素材 | IR（インパルス応答）素材の配布元とライセンス | 商用可否 |

## 9. 道場・スタジオの経済

| 種別 | 情報源 | 見るもの |
|---|---|---|
| 相場 | 道場・スタジオの公開料金ページ、業界団体の統計 | 月謝と付加サービスの相場 |
| 価格 | 同種の指導支援SaaSの価格ページ | サブスクの価格帯 |
| 決済 | 決済事業者の手数料表 | 提供モデルの選択肢 |

## 情報源そのものが腐ることについて

上の表のURLやサービスも、いずれ消える。**リンク切れを見つけたら、代替を探して sources.md 側を直すのも月次ルーチンの仕事である。**情報源リストの更新は CHANGELOG に「情報源の更新」として記録する。
