#!/usr/bin/env python3
"""Geometric checks only: they do not certify strength, fit or printing results."""
from pathlib import Path
import hashlib
import json
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT/'stl/manifest.json').read_text())
rows=[]
for item in manifest['parts']:
    file=ROOT/item['file']
    mesh=trimesh.load_mesh(file)
    components=mesh.split(only_watertight=False)
    size=mesh.extents
    expected_components=3 if item['part']=='body_plate_380' else 1
    checks={
        'sha256_matches_manifest':hashlib.sha256(file.read_bytes()).hexdigest()==item['sha256'],
        'vertices_finite':bool(np.isfinite(mesh.vertices).all()),
        'watertight':bool(mesh.is_watertight),
        'consistent_winding':bool(mesh.is_winding_consistent),
        'positive_component_volumes':all(m.volume>0 for m in components),
        'expected_connected_components':len(components)==expected_components,
        'flat_base_at_z0':abs(float(mesh.bounds[0,2]))<1e-5,
        'bed_fit_with_5mm_brim':bool(size[0]+10<=220 and size[1]+10<=220 and size[2]<=250),
    }
    row={'file':item['file'],'dimensions_mm':size.round(4).tolist(),
         'triangles':len(mesh.faces),'components':len(components),'checks':checks,
         'passed':all(checks.values())}
    rows.append(row)
report={'scope':'Mesh topology, checksum, components, build-volume fit only; no physical/slicer/load test.',
        'passed':all(x['passed'] for x in rows),'files_checked':len(rows),'results':rows}
(ROOT/'stl/validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
if not report['passed']:
    for row in rows:
        if not row['passed']: print(row)
    raise SystemExit(1)
print(f"PASS: {len(rows)} meshes; watertight, correctly oriented, expected components, Ender 3 Pro fit with 5 mm brim.")
