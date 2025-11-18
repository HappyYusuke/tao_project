import argparse
import numpy as np
import os
from pathlib import Path
import time

# --- 1. 引数 ---

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pcd", type=str, help="Your pcd path.")
parser.add_argument("-b", "--bin", type=str, default='bin', help="Save directory name.")
args = parser.parse_args()

# ★ (A) ご自身のJSONラベルが保存されているディレクトリのパス
# (例: /home/demulab-kohei/tao_project/my_dataset_json/train)
JSON_DIR = args.json

# ★ (B) 変換後の.txtファイルを保存するディレクトリのパス
# (TAOが探す '.../train/label' の場所を指定します)
OUTPUT_DIR = args.txt

# ---------------------------------------------------------

def convert_pcd_to_bin(pcd_file, bin_file):
    """
    指定された .pcd (ASCII) ファイルを読み込み、
    KITTI形式の .bin ファイル (float32, 4チャンネル)として書き出す
    """
    points = []
    # .pcd ファイルをテキストモードで開く
    with open(pcd_file, 'r') as f:
        data_started = False
        for line in f:
            if data_started:
                # データ行の場合
                line_parts = line.strip().split(' ')
                if len(line_parts) >= 4:
                    # x, y, z, intensity を float としてリストに追加
                    points.append([float(line_parts[0]), 
                                   float(line_parts[1]), 
                                   float(line_parts[2]), 
                                   float(line_parts[3])])
            
            if line.startswith("DATA ascii"):
                # "DATA ascii" の次の行からデータが始まるとマーク
                data_started = True

    # リストを numpy 配列 (float32) に変換
    # PointPillars (KITTI) は float32 を想定しています
    point_array = np.array(points, dtype=np.float32)
    
    # バイナリファイルとして書き出し
    point_array.tofile(bin_file)

# --- メインの実行処理 ---
if __name__ == "__main__":
    # 出力ディレクトリが存在しない場合は作成
    os.makedirs(BIN_DIR, exist_ok=True)
    
    print(f"PCDディレクトリ: {PCD_DIR}")
    print(f"BINディレクトリ : {BIN_DIR}")
    print("-" * 30)

    start_time = time.time()
    pcd_files = list(PCD_DIR.glob("*.pcd"))
    
    if not pcd_files:
        print(f"エラー: {PCD_DIR} に .pcd ファイルが見つかりません。")
        print("PCD_DIR のパスを確認してください。")
        exit()
        
    print(f"{len(pcd_files)} 件の .pcd ファイルを変換します...")
    
    for i, pcd_file_path in enumerate(pcd_files):
        # 出力ファイル名を .bin に変更してパスを構築
        bin_file_path = BIN_DIR / pcd_file_path.with_suffix(".bin").name
        
        # 変換関数を呼び出し
        convert_pcd_to_bin(pcd_file_path, bin_file_path)
        
        # 進捗を表示
        print(f"[{i+1}/{len(pcd_files)}] {pcd_file_path.name} -> {bin_file_path.name}")

    end_time = time.time()
    print("-" * 30)
    print(f"変換完了！ (所要時間: {end_time - start_time:.2f} 秒)")
