from mathutils import Vector
import bpy

def look_at(obj_camera, point):
	loc_camera = obj_camera.matrix_world.to_translation()

	direction = point - loc_camera
	# point the cameras '-Z' and use its 'Y' as up
	rot_quat = direction.to_track_quat('-Z', 'Y')

	# assume we're using euler rotation
	obj_camera.rotation_euler = rot_quat.to_euler()

scene = bpy.context.scene
scene.objects['Camera'].select = True

scene.objects.active = scene.objects['Camera']

bpy.context.object.location = [-5, -8, 10]

world_ori = Vector()

look_at(scene.objects['Camera'], world_ori)
