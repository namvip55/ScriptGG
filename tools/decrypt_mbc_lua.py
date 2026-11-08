#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Decrypts encrypted Cocos2d-x Lua files (.so) in MBC using XXTEA.
Key discovered in libcocos2dlua.so: 3c883f7813a3ee68
Includes exact original length extraction (inc_len = 1 in xxtea_to_byte_array).
"""

import os
import sys
from pathlib import Path

KEY = b"3c883f7813a3ee68"

def xxtea_to_uint_array(data, include_length):
    length = len(data)
    n = (((length - 1) >> 2) + 1)
    if include_length:
        result = [0] * (n + 1)
        result[n] = length
    else:
        result = [0] * n
    for i in range(length):
        result[i >> 2] |= data[i] << ((i & 3) << 3)
    return result

def xxtea_to_byte_array(data, include_length):
    n = len(data) << 2
    if include_length:
        m = data[-1]
        n -= 4
        if m < n - 3 or m > n:
            return None
        n = m
    result = bytearray(n)
    for i in range(n):
        result[i] = (data[i >> 2] >> ((i & 3) << 3)) & 0xff
    return bytes(result)

def xxtea_decrypt(data, key):
    if not data or len(data) < 8:
        return data
    pad_len = len(data) % 4
    if pad_len != 0:
        data = data + b'\x00' * (4 - pad_len)
    
    v = xxtea_to_uint_array(data, False)
    k = xxtea_to_uint_array(key, False)
    if len(k) < 4:
        k.extend([0] * (4 - len(k)))
    n = len(v)
    DELTA = 0x9E3779B9
    q = 6 + 52 // n
    sum_val = (q * DELTA) & 0xffffffff
    y = v[0]
    while sum_val != 0:
        e = (sum_val >> 2) & 3
        for p in range(n - 1, 0, -1):
            z = v[p - 1]
            v[p] = (v[p] - (((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4)) ^ ((sum_val ^ y) + (k[(p & 3) ^ e] ^ z)))) & 0xffffffff
            y = v[p]
        z = v[n - 1]
        v[0] = (v[0] - (((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4)) ^ ((sum_val ^ y) + (k[(0 & 3) ^ e] ^ z)))) & 0xffffffff
        y = v[0]
        sum_val = (sum_val - DELTA) & 0xffffffff
    
    dec = xxtea_to_byte_array(v, True)
    if dec is None:
        dec = xxtea_to_byte_array(v, False).rstrip(b'\x00')
    return dec

def main():
    base_dir = Path(r"D:\project\GameGuardian\srcgame\mbc")
    assets_dir = base_dir / "assets"
    out_dir = base_dir / "decompiled_lua"
    out_dir.mkdir(parents=True, exist_ok=True)

    count = 0
    err_count = 0

    for path in assets_dir.rglob("*.so"):
        if "lib" in path.parts:
            continue
        rel_path = path.relative_to(assets_dir)
        target_path = out_dir / rel_path.with_suffix(".lua")
        target_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            with open(path, "rb") as f:
                data = f.read()
            dec = xxtea_decrypt(data, KEY)
            with open(target_path, "wb") as f:
                f.write(dec)
            count += 1
        except Exception as e:
            print(f"Error decrypting {path}: {e}")
            err_count += 1

    print(f"Decrypted {count} Lua script files cleanly into {out_dir}")
    if err_count:
        print(f"Encountered {err_count} errors.")

if __name__ == "__main__":
    main()
