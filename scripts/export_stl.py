#!/usr/bin/env python3
"""Rebuild prototype STLs using OpenSCAD, preserving errors and file manifests."""
from pathlib import Path
import concurrent.futures
import hashlib
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PARTS = ['toe_long','heel_long','toe_short','heel_short']
PARTS += [f'center{n}' for n in (20,40,60,80,100)]
PARTS += ['liner_long','liner_short'] + [f'liner{n}' for n in (20,40,60,80,100)]
PARTS += ['sole_long','sole_short'] + [f'sole{n}' for n in (20,40,60,80,100)]
PARTS += ['logo_badge','number_badge','fit_coupon','body_plate_380']
OUT = ROOT / 'stl'
OUT.mkdir(exist_ok=True)

def export(part):
    target = OUT / (part + '.stl')
    tmp = OUT / (part + '.tmp.stl')
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen')
    run = subprocess.run(['openscad','--export-format','binstl','-o',str(tmp),'-D',f'part="{part}"',
                          str(ROOT/'cad'/'skate_guard.scad')],
                         capture_output=True,text=True,env=env)
    if run.returncode or 'ERROR:' in run.stderr or not tmp.is_file():
        raise RuntimeError(f'{part}: {run.stdout}\n{run.stderr}')
    tmp.replace(target)
    return {'part':part,'file':str(target.relative_to(ROOT)),
            'bytes':target.stat().st_size,
            'sha256':hashlib.sha256(target.read_bytes()).hexdigest()}

with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    result = list(pool.map(export,PARTS))
(OUT/'manifest.json').write_text(json.dumps({'units':'mm','status':'fit-and-assembly prototype; not load validated','parts':result},ensure_ascii=False,indent=2)+'\n')
print(f'Exported {len(result)} STL files in {OUT}')
