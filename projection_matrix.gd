extends Node

func get_fovy(p_fovx,p_aspect):
	return rad2deg(atan(p_aspect * tan(deg2rad(p_fovx) * 0.5)) * 2.0);

func createProjectionMatrix(p_fovy_degrees,p_aspect,p_z_near,p_z_far,p_flip_fov=false):
	if p_flip_fov:
		p_fovy_degrees = get_fovy(p_fovy_degrees, 1.0 / p_aspect)

	var sine : float
	var cotangent : float
	var deltaZ : float
	
	var Math_PI = 3.1415926
	var radians = (p_fovy_degrees / 2.0) * (Math_PI / 180.0)

	deltaZ = p_z_far - p_z_near;
	sine = sin(radians);

	var matrix : Transform = Transform.IDENTITY
	
	if ((deltaZ == 0) || (sine == 0) || (p_aspect == 0)):
		return matrix
	
	cotangent = cos(radians) / sine;

	matrix[0][0] = cotangent / p_aspect;
	matrix[1][1] = cotangent;
	matrix[2][2] = -(p_z_far + p_z_near) / deltaZ;
	#matrix[2][3] = -1;
	matrix[3][2] = -2 * p_z_near * p_z_far / deltaZ;
	#matrix[3][3] = 0;
	
	return matrix
