#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
指定されたディレクトリ内の .pcd (ASCII) ファイルを読み込み、
TAO PointPillars (KITTI形式) の .bin ファイルに一括変換するスクリプトです。

出力ディレクトリが既に存在する場合、自動的にナンバリングを行います。
"""

import argparse
import numpy as np
import os
from pathlib import Path
import time

# --- 関数: ユニークなディレクトリ名を取得する ---
def get_unique_directory(path: Path) -> Path:
    """
    指定されたディレクトリが存在する場合、末尾に数字(1, 2, ...)をつけて
    重複しないディレクトリ名を生成して返す。
    存在しなければそのまま返す。
    """
    # まだ存在しないならそのまま使う
    if not path.exists():
        return path

    # 存在する場合、数字をつけて探索する
    counter = 1
    while True:
        # 親ディレクトリ / (元の名前 + 数字)
        new_path = path.parent / f"{path.name}{counter}"
        if not new_path.exists():
            return new_path
        counter += 1

# --- 1. 引数 ---

parser = argparse.ArgumentParser(description="Convert PCD files to KITTI BIN files.")
parser.add_argument("-p", "--pcd", type=str, required=True, help="Input directory containing .pcd files.")
parser.add_argument("-b", "--bin", type=str, default='bin', help="Output directory name.")
args = parser.parse_args()

# ★ (A) 入力: PCDディレクトリ
PCD_DIR = Path(args.pcd)

# ★ (B) 出力: 保存ディレクトリ (自動ナンバリング処理)
# 引数で指定されたパスを元に、重複しないパスを取得します
base_output_dir = Path(args.bin)
BIN_DIR = get_unique_directory(base_output_dir)

# ---------------------------------------------------------

def convert_pcd_to_bin(pcd_file, bin_file):
    """
    指定された .pcd (ASCII) ファイルを読み込み、
    KITTI形式の .bin ファイル (float32, 4チャンネル)として書き出す
    """
    points = []
    try:
        # .pcd ファイルをテキストモードで開く
        with open(pcd_file, 'r') as f:
            data_started = False
            for line in f:
                if data_started:
                    # データ行の場合
                    line_parts = line.strip().split(' ')
                    # 空行などをスキップしつつ、要素数が4以上あるか確認
                    if len(line_parts) >= 4:
                        try:
                            # x, y, z, intensity を float としてリストに追加
                            points.append([float(line_parts[0]), 
                                           float(line_parts[1]), 
                                           float(line_parts[2]), 
                                           float(line_parts[3])])
                        except ValueError:
                            continue # 数値変換できない行はスキップ
                
                if line.startswith("DATA ascii"):
                    # "DATA ascii" の次の行からデータが始まるとマーク
                    data_started = True
        
        # リストを numpy 配列 (float32) に変換
        # PointPillars (KITTI) は float32 を想定しています
        point_array = np.array(points, dtype=np.float32)
        
        # バイナリファイルとして書き出し
        point_array.tofile(bin_file)
        return True

    except Exception as e:
        print(f"  [エラー] {pcd_file.name} の変換に失敗: {e}")
        return False

# --- メインの実行処理 ---
if __name__ == "__main__":
    
    # 1. 入力ディレクトリのチェック
    if not PCD_DIR.exists():
        print(f"エラー: 入力ディレクトリが見つかりません: {PCD_DIR}")
        exit(1)
        
    pcd_files = list(PCD_DIR.glob("*.pcd"))
    if not pcd_files:
        print(f"エラー: {PCD_DIR} に .pcd ファイルが見つかりません。")
        exit(1)

    # 2. 出力ディレクトリの作成 (ここでユニーク化されたパスを使用)
    os.makedirs(BIN_DIR, exist_ok=True)
    
    print(f"PCD to BIN 変換スクリプト")
    print("-" * 40)
    print(f"入力 (PCD) : {PCD_DIR}")
    print(f"出力 (BIN) : {BIN_DIR}  <-- このフォルダに保存されます")
    print("-" * 40)

    start_time = time.time()
    print(f"{len(pcd_files)} 件の .pcd ファイルを変換します...")
    
    success_count = 0
    for i, pcd_file_path in enumerate(pcd_files):
        # 出力ファイル名を .bin に変更してパスを構築
        bin_file_path = BIN_DIR / pcd_file_path.with_suffix(".bin").name
        
        # 変換関数を呼び出し
        if convert_pcd_to_bin(pcd_file_path, bin_file_path):
            success_count += 1
        
        # 50ファイルごと、または最後だけ進捗を表示
        if (i + 1) % 50 == 0 or (i + 1) == len(pcd_files):
            print(f"  ... {i + 1}/{len(pcd_files)} 件処理完了")

    end_time = time.time()
    print("-" * 40)
    print(f"変換完了！ (成功: {success_count} / {len(pcd_files)} 件)")
    print(f"保存先: {BIN_DIR}")
    print(f"所要時間: {end_time - start_time:.2f} 秒")
