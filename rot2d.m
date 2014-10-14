function [ rotMatrix ] = rot2d( angle )
    cosAngle = cos(angle);
    sinAngle = sin(angle);
    rotMatrix = [cosAngle, -sinAngle;
                sinAngle, cosAngle];
end

