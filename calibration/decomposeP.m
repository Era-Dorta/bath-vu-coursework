function [K,R,t] = decomposeP(P)
% Uses RQ to decompose P into K, [R|t]

% Matlab does not implement RQ, so do QR and inverse the result
Q = inv(P(1:3, 1:3));
[R,K] = qr(Q);

%% Make sure focal lenghts are positive
if (K(1,1) < 0)
    S = [-1 0 0;0 1 0;0 0 1];
    R = R*S;
    K = S*K;
end

if (K(2,2) < 0)
    S = [1 0 0;0 -1 0;0 0 1];
    R = R*S;
    K = S*K;
end

% Homogeneous coordinate positive too
if (K(3,3) < 0)
    S = [1 0 0;0 1 0;0 0 -1];
    R = R*S;
    K = S*K;
end

%% Translation vector
t = K*P(1:3,4);

%% Check det(R)=1
if det(R) < 0 
    t = -t;
    R = -R;
end

%% Inverse since we are using QR
R = inv(R);

K = inv(K);
K = K./K(3,3);