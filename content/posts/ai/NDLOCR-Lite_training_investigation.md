---
title: "NDLOCR-Lite モデル学習機能調査レポート"
date: 2026-02-26T14:50:00+09:00
categories: ["ai"]
draft: false
---

# NDLOCR-Lite モデル学習機能調査レポート

**調査日時**: 2026-02-26 14:50
**調査担当**: 秘書1 ひなた
**対象リポジトリ**: https://github.com/ndl-lab/ndlocr-lite

---

## 📊 調査結果サマリー

### モデル学習機能の有無

**✅ Yes — 学習機能あり**

NDLOCR-Liteには、**完全な学習機能**が含まれています。`train/` ディレクトリに学習用コード、設定ファイル、データ変換スクリプトが完備されています。

### ローカルで完結するか

**⚠️ 条件付きYes — 初回セットアップ時のみインターネット接続が必要**

- **初回セットアップ時**: インターネット接続必須（リポジトリクローン、ライブラリインストール、データセットダウンロード）
- **学習実行時**: 完全オフライン可能（すべてローカルで完結）

---

## 🔍 モデル学習機能の詳細

### 1. 学習対象モデル

NDLOCR-Liteでは、以下の2つのモデルを独自データで学習できます：

| モデル | 用途 | 元リポジトリ | 学習フレームワーク |
|--------|------|--------------|-------------------|
| **DEIMv2** | レイアウト認識（文字領域検出） | [Intellindust-AI-Lab/DEIMv2](https://github.com/Intellindust-AI-Lab/DEIMv2) | PyTorch 2.0+ |
| **PARSeq** | 文字列認識（OCR） | [baudm/parseq](https://github.com/baudm/parseq) | PyTorch 1.10+ |

### 2. 学習用ディレクトリ構成

```
train/
├── README.md                      # 学習手順ドキュメント
├── deimv2code/                    # DEIMv2カスタマイズコード
│   ├── part1/                     # 第1段階学習
│   ├── part2/                     # 第2段階学習
│   └── configs/                   # 設定ファイル
├── parseqcode/                    # PARSeqカスタマイズコード
│   ├── convertkotensekidata2lmdb.py  # データ→LMDB変換
│   ├── convert2onnx.py            # 学習済モデル→ONNX変換
│   ├── main_tiny768.yaml          # 100文字対応設定
│   ├── main_tiny384.yaml          # 50文字対応設定
│   └── main_tiny256.yaml          # 30文字対応設定
├── honkoku_rawdata/               # 学習データ（行ごと切り出し画像+テキスト）
└── data/
    ├── train/real/                # LMDB形式学習データ
    └── val/                       # LMDB形式検証データ
```

### 3. 学習手順（概要）

#### DEIMv2（レイアウト認識）の学習

1. **第1段階**: 基本モデルの学習
2. **第2段階**: チェックポイントからの継続学習（`-t` オプションで指定）
3. **分散学習**: 3つのGPUを使用した分散学習の実例あり

#### PARSeq（文字列認識）の学習

1. **データ準備**: 行ごと切り出し画像とテキストを準備
2. **LMDB変換**: `convertkotensekidata2lmdb.py` でLMDB形式に変換
3. **学習実行**: 3種類のモデルサイズ（100/50/30文字対応）で並列学習可能
4. **ONNX変換**: `convert2onnx.py` で学習済みモデルをONNX形式に変換

---

## 📦 外部依存関係

### 1. 学習データセット

#### みんなで翻刻 OCR学習用データセット

**名称**: NDL古典籍OCR学習用データセット（みんなで翻刻加工データ）

**提供元**: 国立国会図書館（NDL Lab）

**ライセンス**: CC BY-SA 4.0

**入手方法**:
- GitHub: https://github.com/ndl-lab/ndl-minhon-ocrdataset
- ZIP直接ダウンロード: https://lab.ndl.go.jp/dataset/ndlkotensekiocr/ndl-minhon-ocrdataset_20240207.zip
- **ファイルサイズ**: 45MB

**特徴**:
- みんなで翻刻データに座標情報を紐づけて構造化
- v1（リニューアル前）とv2（リニューアル後）に分かれている
- 古典籍資料のOCR学習に特化

**データ形式**:
- 行ごとの切り出し画像
- 対応する翻刻テキスト
- 学習時はLMDB形式に変換して使用

### 2. クラウドサービス・外部APIへの依存

**❌ なし**

学習処理は完全にローカルで実行されます：
- クラウドGPU（TPU、GPU as a Service等）への依存なし
- 外部学習プラットフォーム（Google Colab、AWS SageMaker等）への依存なし
- 学習中のデータ送信なし

### 3. 元モデルリポジトリへの依存

#### DEIMv2

**リポジトリ**: https://github.com/Intellindust-AI-Lab/DEIMv2

**特徴**:
- DINOv3バックボーンを使用したリアルタイム物体検出モデル
- COCO2017データセットでの学習例あり
- S-sizedモデルでCOCO 50 AP超えを達成

**学習要件**:
- PyTorch 2.0以上
- CUDA対応GPU
- COCO形式のアノテーションデータ

#### PARSeq

**リポジトリ**: https://github.com/baudm/parseq

**特徴**:
- Permuted Autoregressive Sequence Modelsを用いたシーンテキスト認識
- ECCV 2022で発表
- 双方向コンテキストによる反復予測改良機能

**学習要件**:
- Python 3.7以上
- PyTorch 1.10以上（PyTorch 2.0、Lightning 2.0対応）
- train.pyスクリプトで任意のサポート済みモデルを学習可能

---

## 🖥️ 学習環境の要件

### 1. ハードウェア要件

#### GPU（必須）

**種類**: CUDA対応NVIDIA GPU

**理由**:
- PyTorch 2.5.1とCUDA 12.1を使用
- ディープラーニングモデルの学習にはGPU必須

**推奨構成**:
- **DEIMv2**: 3つのGPUを使用した分散学習の実例あり
- **PARSeq**: 最低1GPU（詳細な推奨スペックは不明）

**CPU学習の可否**: 理論上は可能だが、学習時間が膨大になるため非現実的

#### メモリ・ストレージ

- **RAM**: 16GB以上推奨（GPU VRAMとは別）
- **ストレージ**:
  - データセット: 45MB（みんなで翻刻）
  - ライブラリ・依存関係: 数GB（PyTorch、CUDA等）
  - 学習済みモデル保存: 数百MB〜数GB
  - **推奨合計**: 20GB以上の空き容量

### 2. ソフトウェア要件

#### 必須ライブラリ

| 種別 | ライブラリ | バージョン | 用途 |
|------|-----------|-----------|------|
| 機械学習 | PyTorch | 2.0以上（2.5.1推奨） | モデル学習 |
| GPU | CUDA | 12.1 | GPU計算 |
| 画像処理 | torchvision | - | 画像処理 |
| 評価 | faster-coco-eval | - | DEIMv2評価 |
| 設定管理 | PyYAML | - | 設定ファイル読み込み |
| ログ | tensorboard | - | 学習ログ可視化 |
| データベース | LMDB | - | PARSeqデータ保存 |

#### Python環境

- **Python**: 3.7以上（3.11推奨）
- **パッケージ管理**: pip、conda

### 3. 完全オフライン環境での学習可否

#### ✅ 可能（初回セットアップ後）

**前提条件**:

1. **オンライン環境で初回セットアップを完了**（以下の作業）:
   - リポジトリクローン: `git clone https://github.com/ndl-lab/ndlocr-lite.git`
   - 依存ライブラリインストール: `pip install -r requirements.txt`
   - 学習データセットダウンロード: みんなで翻刻（45MB ZIP）
   - 元モデルリポジトリのクローン（DEIMv2、PARSeq）

2. **セットアップ完了後**:
   - インターネット接続を切断
   - オフライン環境に移動（環境ごとコピー）

3. **オフライン環境で学習実行**:
   ```bash
   # DEIMv2学習（例）
   cd train/deimv2code/part1
   python train.py --config configs/ndl_deimv2/deimv2_dinov3_s_coco_r4_800.yml

   # PARSeq学習（例）
   cd train/parseqcode
   python train.py main_tiny768.yaml
   ```

---

## 🔄 学習から推論までのパイプライン

### 全体の流れ

```
1. データ準備
   ↓
2. モデル学習（PyTorchフレームワーク）
   ↓
3. ONNX変換（convert2onnx.py）
   ↓
4. ONNX推論（ndlocr-lite本体で使用）
```

### ONNX形式について

**ONNX（Open Neural Network Exchange）**:
- **目的**: 機械学習モデルの相互運用性を実現
- **利点**:
  - 軽量・高速な推論実行
  - GPU不要での実行が可能
  - 複数のフレームワーク（PyTorch、TensorFlow等）からエクスポート可能

**NDLOCR-Liteでの利用**:
- **学習時**: PyTorchフレームワークで学習
- **推論時**: ONNX Runtime（CPU/GPU両対応）で推論
- **変換**: `convert2onnx.py` で学習済みPyTorchモデル→ONNX形式に変換

**推論専用か？**:
- ❌ ONNX形式自体は推論専用
- ✅ ただし、学習→ONNX変換のパイプラインが完備されている
- ✅ 学習はPyTorchで行い、デプロイ時にONNXに変換する設計

---

## 🔗 NDLOCR本体（フル版）との比較

### NDLOCRフル版

**リポジトリ**: https://github.com/ndl-lab/ndlocr_cli

**学習機能**: あり
- テキスト認識モジュール: https://github.com/ndl-lab/text_recognition_lightning
- 古典籍OCR学習スクリプト: https://github.com/ndl-lab/ndlkotenocr_cli/blob/master/src/text_kotenseki_recognition/train.py

**違い**:
| 項目 | NDLOCR-Lite | NDLOCRフル版 |
|------|-------------|--------------|
| **GPU要件** | 学習時のみ必須、推論時は不要 | 推論時もGPU推奨 |
| **対象ユーザー** | 一般ユーザー・ライトユース | 研究者・大規模処理 |
| **学習機能** | ✅ あり（train/） | ✅ あり |
| **推論速度** | CPU対応、軽量 | GPU使用、高速 |
| **精度** | 軽量版（実用レベル） | 高精度 |

---

## ✅ 結論

### モデル学習機能の有無

**✅ Yes — 完全な学習機能あり**

NDLOCR-Liteは、以下の学習機能を提供しています：

1. ✅ **独自データセットでのファインチューニングが可能**
   - みんなで翻刻データセットを使用
   - LMDB形式に変換して学習

2. ✅ **新規モデルのトレーニング機能あり**
   - DEIMv2（レイアウト認識）
   - PARSeq（文字列認識）

3. ✅ **学習用のスクリプト・ドキュメントあり**
   - `train/README.md` に詳細手順記載
   - `train/deimv2code/`、`train/parseqcode/` に学習スクリプト
   - `convertkotensekidata2lmdb.py`（データ変換）、`convert2onnx.py`（ONNX変換）

### ローカルで完結するか

**⚠️ 条件付きYes — 初回セットアップ時のみインターネット接続が必要**

#### 初回セットアップ時（インターネット接続必須）

| 項目 | 内容 | 理由 |
|------|------|------|
| リポジトリクローン | GitHubからクローン | ソースコード取得 |
| 依存ライブラリインストール | pip install | PyTorch、CUDA等のインストール |
| 学習データセットダウンロード | みんなで翻刻（45MB） | 学習用データ取得 |
| 元モデルリポジトリ取得 | DEIMv2、PARSeq | カスタマイズベース取得 |

#### 学習実行時（オフライン可能）

| 項目 | 状態 |
|------|------|
| インターネット接続 | ❌ 不要 |
| クラウドサービス | ❌ 依存なし |
| データ送信 | ❌ なし |
| ローカル完結性 | ✅ 完全にローカルで完結 |

### 学習に必要な環境・要件

#### ハードウェア（必須）

- **GPU**: CUDA対応NVIDIA GPU（DEIMv2では3GPU推奨の分散学習例あり）
- **RAM**: 16GB以上推奨
- **ストレージ**: 20GB以上の空き容量

#### ソフトウェア（必須）

- **Python**: 3.7以上（3.11推奨）
- **PyTorch**: 2.0以上（2.5.1推奨）
- **CUDA**: 12.1
- **その他**: torchvision、PyYAML、tensorboard、LMDB等

#### データセット（必須）

- **みんなで翻刻**: 45MB、CC BY-SA 4.0ライセンス
- **入手先**: https://github.com/ndl-lab/ndl-minhon-ocrdataset

#### オフライン学習の可否

- ✅ **可能**（初回セットアップ後）
- ⚠️ 初回セットアップ時のみインターネット接続必須

---

## 📚 参考資料

### NDLOCR-Lite関連

1. [GitHub - ndl-lab/ndlocr-lite](https://github.com/ndl-lab/ndlocr-lite)
2. [train/README.md - ndlocr-lite](https://github.com/ndl-lab/ndlocr-lite/blob/master/train/README.md)

### 学習データセット

3. [GitHub - ndl-lab/ndl-minhon-ocrdataset](https://github.com/ndl-lab/ndl-minhon-ocrdataset)
4. [OCR学習用データセット - NDLラボ](https://lab.ndl.go.jp/data_set/ocr/r3_text/)

### 元モデルリポジトリ

5. [GitHub - Intellindust-AI-Lab/DEIMv2](https://github.com/Intellindust-AI-Lab/DEIMv2)
6. [DEIMv2公式ページ](https://intellindust-ai-lab.github.io/projects/DEIMv2/)
7. [GitHub - baudm/parseq](https://github.com/baudm/parseq)
8. [PARSeq論文（ECCV 2022）](https://arxiv.org/abs/2207.06966)

### NDLOCRフル版

9. [GitHub - ndl-lab/ndlocr_cli](https://github.com/ndl-lab/ndlocr_cli)
10. [GitHub - ndl-lab/text_recognition_lightning](https://github.com/ndl-lab/text_recognition_lightning)

---

**調査完了日時**: 2026-02-26 15:00
**調査担当**: 秘書1 ひなた
**次のアクション**: 副室長 凛へ報告
