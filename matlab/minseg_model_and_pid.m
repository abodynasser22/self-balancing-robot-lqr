clear; clc; close all;

g = 9.8;
b_f = 0;
m_b = 0.381;
l_b = 0.112;
I_b = 0.00616;
m_w = 0.036;
l_w = 0.021;
I_w = 0.00000746;
R_m = 4.4;
L_m = 0;
b_m = 0;
K_e = 0.444;
K_t = 0.470;

gamma11 = I_w / l_w + l_w * m_b + l_w * m_w;
gamma12 = m_b * l_b * l_w;
gamma21 = m_b * l_b;
gamma22 = I_b + m_b * l_b^2;

gamma = [gamma11, gamma12;
        gamma21, gamma22];

alpha11 = 0;
alpha12 = - b_f / l_w - (K_e * K_t) / (R_m * l_w);
alpha13 = 0;
alpha14 = b_f + (K_e * K_t) / R_m;
alpha21 = 0;
alpha22 = b_f / l_w + (K_e * K_t) / (R_m * l_w);
alpha23 = m_b * l_b * g;
alpha24 = - b_f - (K_e * K_t) / R_m;

alpha = [alpha11, alpha12, alpha13, alpha14;
        alpha21, alpha22, alpha23, alpha24];

beta1 = K_t / R_m;
beta2 = -K_t / R_m;

beta = [beta1;
        beta2];

a = gamma \ alpha;
b = gamma \ beta;
A = [0, 1, 0, 0;
        a(1,:);
        0, 0, 0, 1;
        a(2,:)]
B = [0;
        b(1,:);
        0;
        b(2,:)];
C_y = [0 0 1 0];   % vinkel på kroppen
D_y = 0;

% Kontinuerlig plantmodell (motor­spänning -> kroppsvinkel)
G = ss(A, B, C_y, D_y);
G = tf(G);          % överföringsfunktion om du vill se den

%C = [0, 0, 1, 0];
%D = [0;
%        0;
%        0;
%        0];
%I = eye(4);
%syms s
%G = C * (s * I - A)^(-1) * B + D;
%C = eye(4);
%M1 = s*I - A;
%poles = solve(det(M1) == 0, s);

%M2 = [A - s*I, B; C, D]
%zeros = solve(det(M2), s)

%P = I \ A
%Z = -(D*I) \ (B*C - A*D
%SYS = ss(A, B, C, D);
%[T,N] = ss2tf(A,B,C,D)
%pzplot(SYS) % -475, -5.66, 0, 5.72
%eigs = [-475, -5.66, 0, -5.72];
%K = place(A,B,eigs)
%tzero(ss(A,B,C,D))

%[test2, test3] = ss2tf(A, B, C, 0)
%G = minreal(tf(round(test2, 5), round(test3, 5)))

%M1 = [(-475)^2, -475, 1; (-5.66)^2, -5.66, 1; (-5.72)^2, -5.72, 1];
%M2 = [0; 0; -(-5.72/((-5.72+475)*(-5.72+5.66)*(-5.72-5.72)))/(-90)];
%M1 \ M2
s  = tf('s');

Kp = -61.3565;
Ki = -343.0373;
Kd = -0.1270;

N  = 50;                              % derivatfilter, välj t.ex. 10–100
C_pid = Kp + Ki/s + Kd*N*s/(1 + N*s); % nu proper

isproper(C_pid)                       % bör ge 1 (true)

T_cl = feedback(C_pid*G, 1);   % från referens vinkel -> faktisk vinkel

w_b = bandwidth(T_cl);      % [rad/s]
f_b = w_b/(2*pi);           % [Hz] om du vill



N  = 20;                 % antal sampel per bandbreddsperiod
f_s = N*f_b;             % samplingsfrekvens [Hz]
T_s = 1/f_s;             % samplingsperiod [s]



Ts = 0.02;                     % exempel

Cd = c2d(C_pid, Ts, 'zoh');    % nu fungerar det
[numCd, denCd] = tfdata(Cd, 'v');

numCd = numCd/denCd(1);        % normalisera så att denCd(1) = 1
denCd = denCd/denCd(1);

disp(w_b)
disp(f_b)
fprintf('u[k] = %.6f*u[k-1] + %.6f*u[k-2] + %.6f*e[k] + %.6f*e[k-1] + %.6f*e[k-2]\n', ...
        -denCd(2), -denCd(3), numCd(1), numCd(2), numCd(3));
%beta_for_poking = [beta1, l_w; beta2, l_b];

%Bnew = gamma \ beta_for_poking;
%B_for_poking = [0, 0; Bnew(1,:); 0, 0; Bnew(2,:)]
%C_for_full_observability = C
%D_for_full_observability_and_poking = [0, 0; 0, 0; 0, 0; 0, 0]

%SYS = ss(A, B_for_poking, C_for_full_observability, D_for_full_observability_and_poking);
%[T,N] = ss2tf(A, B_for_poking, C_for_full_observability, D_for_full_observability_and_poking)
%pzplot(SYS)

%G = simplify(C_for_full_observability * (s * I - A)^(-1) * B_for_poking + D_for_full_observability_and_poking)
