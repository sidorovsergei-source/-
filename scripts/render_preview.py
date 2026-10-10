#!/usr/bin/env python3
"""Render the actual mesh assembly; this is not a structural simulation."""
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import trimesh

ROOT=Path(__file__).resolve().parents[1]
fig=plt.figure(figsize=(13,6),facecolor='white')
ax=fig.add_subplot(111,projection='3d')

def draw(mesh,color):
    collection=Poly3DCollection(mesh.triangles,facecolor=color,edgecolor='none',alpha=1)
    ax.add_collection3d(collection)

def load(name,offset=(0,0,0),flip=False):
    mesh=trimesh.load_mesh(ROOT/'stl'/f'{name}.stl')
    if flip:
        # Turn sole over: local y is symmetric about zero.
        matrix=trimesh.transformations.rotation_matrix(3.141592653589793,[1,0,0])
        mesh.apply_transform(matrix)
    mesh.apply_translation(offset)
    return mesh

for name,offset in [('toe_long',0),('center100',150),('heel_long',250)]:
    draw(load(name,(offset,0,0)),'#7e8894')
for name,offset in [('liner_long',10.2),('liner100',150.2),('liner_long',250.2)]:
    draw(load(name,(offset,0,12)),'#239ece')
for name,offset in [('sole_long',0),('sole100',150),('sole_long',250)]:
    draw(load(name,(offset,0,0),True),'#343c45')
for y in [-22.4,22.4]:
    rail=trimesh.creation.box(extents=[376,4,25])
    rail.apply_translation([200,y,20.5])
    draw(rail,'#cbd0d8')
ax.set(xlim=(-5,405),ylim=(-45,45),zlim=(-5,45))
ax.set_box_aspect([410,90,80])
ax.view_init(elev=60,azim=-64)
ax.set_axis_off()
ax.set_title('Actual STL assembly — 380 mm internal / 400 mm external\nPrototype: separate PETG bodies, TPU parts and purchased metal rails',pad=12,fontsize=12)
fig.text(.5,.05,'Fasteners and retention webbing omitted from this preview. Load capacity and skate fit have not been tested.',ha='center',fontsize=9)
fig.savefig(ROOT/'drawings'/'03-stl-assembly-380mm.png',dpi=170,bbox_inches='tight')
print('Rendered STL assembly preview.')
