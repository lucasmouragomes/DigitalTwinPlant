% TUNE PID VIA IMC
%definir tau
%var_ruido = 0.8084;
%erro_tipico_medicao = sqrt(var_ruido);
%ref = 5;
%Tstep = 90;
%Thold = 720;
%Tstepdown = Tstep+Thold;
%Tsim = Tstep+Thold*2;
%ref2 = 10;
%zeroBot = 25;
%cond_inicial = 0;
Ts = 1;
s = tf([1 0],1);

K = 2.7858;
t1 = 25.0620;
t2 = 163.7413;
t3 = 145.2384;
L = 10;
tau = 37;
lambda = 1.5*tau;

Kc = (2*tau + L)/(K*(2*lambda + L));
Ti = tau + L/2;
Td = tau*L/(2*tau + L);

P = Kc;
I = Kc/Ti;
D = Kc*Td;

c1 = pid(P, I, D);

clearvars -except PTQ1 PTQ2 PTQ3 PTQ3mod PTQ4 c1 tf1 tout input loop1 idtf1