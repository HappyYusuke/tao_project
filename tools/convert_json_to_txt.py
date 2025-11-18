#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ご自身のJSONラベル形式を、TAO PointPillarsが要求する
KITTI形式の .txt ラベルファイルに変換するスクリプトです。

クラス名の不一致 (例: "person" -> "Pedestrian") をマッピングする機能が含まれています。
出力ディレクトリが既に存在する場合、自動的にナンバリングを行います。
"""

import argparse
import json
from pathlib import Path
import os
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

# --- 1. 引数と設定 ---

parser = argparse.ArgumentParser()
parser.add_argument("-j", "--json", type=str, required=True, help="Your json path.")
parser.add_argument("-t", "--txt", type=str, default='txt', help="Save directory name.")
args = parser.parse_args()

# ★ (A) 入力: JSONディレクトリ
JSON_DIR = Path(args.json)

# ★ (B) 出力: 保存ディレクトリ (自動ナンバリング処理)
# 引数で指定されたパスを元に、重複しないパスを取得します
base_output_dir = Path(args.txt)
OUTPUT_DIR = get_unique_directory(base_output_dir)

# ★ (C) クラス名のマッピング
CLASS_MAPPING = {
    "person": "Pedestrian",
    # "car": "Car",
    # "bicycle": "Cyclist"
}
# ---------------------------------------------------------

def convert_json_to_kitti_txt(json_path, output_path, class_mapping):
    """
    単一のJSONファイルを読み込み、KITTI形式の.txtファイルとして書き出す
    """
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"  [エラー] {json_path.name} の読み込みに失敗: {e}")
        return False

    output_lines = []
    
    # JSON内の各ラベルを処理
    for label in data.get("labels", []):
        
        # --- 1. カテゴリの抽出とマッピング ---
        original_category = label.get("category", "DontCare")
        mapped_category = class_mapping.get(original_category, original_category)

        # --- 2. 3Dボックス情報の抽出 ---
        box3d = label.get("box3d", {})
        
        # 寸法 (h, w, l)
        dim = box3d.get("dimension", {})
        h = dim.get("height", 0.0)
        w = dim.get("width", 0.0)
        l = dim.get("length", 0.0)
        
        # 位置 (x, y, z)
        loc = box3d.get("location", {})
        x = loc.get("x", 0.0)
        y = loc.get("y", 0.0)
        z = loc.get("z", 0.0)
        
        # 回転 (Yaw)
        orientation = box3d.get("orientation", {})
        ry = orientation.get("rotationYaw", 0.0)
        
        # --- 3. KITTI形式の16カラムを作成 ---
        line_data = [
            mapped_category,  # 1. type
            0.0,              # 2. truncated
            0,                # 3. occluded
            -10.0,            # 4. alpha
            0.0, 0.0, 0.0, 0.0, # 5-8. bbox
            h,                # 9. dim_h
            w,                # 10. dim_w
            l,                # 11. dim_l
            x,                # 12. loc_x
            y,                # 13. loc_y
            z,                # 14. loc_z
            ry,               # 15. rotation_y
            1.0               # 16. score
        ]
        
        output_lines.append(" ".join(map(str, line_data)))

    # 変換した内容を.txtファイルに書き込み
    try:
        with open(output_path, 'w') as f:
            f.write("\n".join(output_lines))
        return True
    except Exception as e:
        print(f"  [エラー] {output_path.name} の書き込みに失敗: {e}")
        return False

# --- メインの実行処理 ---
if __name__ == "__main__":
    
    # 1. JSONディレクトリのチェック
    if not JSON_DIR.exists():
        print(f"エラー: 入力ディレクトリが見つかりません: {JSON_DIR}")
        exit(1)
        
    json_files = list(JSON_DIR.glob("*.json"))
    if not json_files:
        print(f"エラー: {JSON_DIR} に .json ファイルが見つかりません。")
        exit(1)

    # 2. 出力ディレクトリの作成 (ここでユニーク化されたパスを使用)
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print(f"TAO PointPillars KITTI形式 変換スクリプト")
    print("-" * 40)
    print(f"入力 (JSON) : {JSON_DIR}")
    print(f"出力 (.txt) : {OUTPUT_DIR}  <-- このフォルダに保存されます")
    print(f"マッピング  : {CLASS_MAPPING}")
    print("-" * 40)

    start_time = time.time()
    print(f"{len(json_files)} 件の .json ファイルを変換します...")
    
    success_count = 0
    for i, json_file_path in enumerate(json_files):
        # 出力ファイル名 (例: 000314.json -> 000314.txt)
        output_file_path = OUTPUT_DIR / json_file_path.with_suffix(".txt").name
        
        # 変換関数を呼び出し
        if convert_json_to_kitti_txt(json_file_path, output_file_path, CLASS_MAPPING):
            success_count += 1
        
        # 50ファイルごと、または最後だけ進捗を表示
        if (i + 1) % 50 == 0 or (i + 1) == len(json_files):
            print(f"  ... {i + 1}/{len(json_files)} 件処理完了")

    end_time = time.time()
    print("-" * 40)
    print(f"変換完了！ (成功: {success_count} / {len(json_files)} 件)")
    print(f"保存先: {OUTPUT_DIR}")
    print(f"所要時間: {end_time - start_time:.2f} 秒")
