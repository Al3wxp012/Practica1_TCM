% Cargar datos desde el archivo CSV
data = readtable("data_motor.csv");

% Extraer columnas
t = data{:,2};% Vector de tiemp
u = data{:,3};  % Señal de excitación
y = data{:,4};  % Respuesta del sistema

%-------------------- senal base entrada u salida---------------

% Graficar señales
figure;
plot(t, u, 'b', 'LineWidth', 1.5); hold on;
plot(t, y, 'r', 'LineWidth', 1.5);
grid on;

%----------linea base 100% ------------------------

% Definir línea base (valor estable del sistema)
y_base = mean(y(end-10:end)); % Promedio de últimos valores

% Agregar línea base al gráfico
plot(t, y_base * ones(size(t)), '--k', 'LineWidth', 1.2);

%---------------linea base--------------------




% Agregar línea base al gráfico
plot(t, 0* ones(size(t)), '--k', 'LineWidth', 1.2);

%----------tangentee---------------------------

% Seleccionar dos puntos para la tangente 
p1 = [t(7), y(7)]; 
p2 = [t(20), y(20)];

% Calcular pendiente de la recta tangente
m = (p2(2) - p1(2)) / (p2(1) - p1(1));

% Ecuación de la recta: y-y1 = m(x-x1) -> y = mx +b
b = - m*p1(1) + p1(2);
t_tangente =t; %calcular los 100 puntos
y_tangente = m * t_tangente +b;

% Graficar la recta tangente
plot(t_tangente, y_tangente, '--g', 'LineWidth', 1.5);



%---------------CALCULO DE LOS PUNTOS DE CORTE-------------

t_corte_base = (y_base  -b) / m;  % Punto de corte con la línea 100%
t_corte_0 = -b / m; % Punto de corte con y = 0









% ------------Ganancia del sistema para los 3 metodos.----------------

% Cálculo de la ganancia K (corregido)
y_inicial = y(1);         % Primer valor de la respuesta
y_final = mean(y(end-10:end)); % Promedio de los últimos valores (evita ruido)

u_inicial = u(1);         % Primer valor de la entrada
u_final = max(u);         % Valor final de la entrada 
 
% Calcular ΔY y ΔU
delta_Y = y_final - y_inicial;
delta_U = u_final - u_inicial;

% Calcular K
K = delta_Y / delta_U;

%-----------------------metodo Ziegler & Nichols ---------------------------------

theta = t_corte_0; % Calcular el tiempo de cruce con y = 0 (theta)
tau = t_corte_base - theta;


fprintf("METODO ZIEGLER");
tau
theta
%----------------Funcion de tranferencia-------------

G = tf(K, [tau 1], 'InputDelay', theta);


%---------------simulacion de la respjuesta del sistema------------------

y1 = lsim(G, u, t);
plot(t, y1, 'y', 'LineWidth', 1.5);




% ----------------metodo MILLER ---------------------



theta2 = t_corte_0;


idx_63 = find(y >= y_base * 0.6332, 1, 'first');
t_corte_63 = t(idx_63);
tau2 = t_corte_63 - theta2;


fprintf("METODO MILLER");
theta2
tau2

%----------------Funcion de tranferencia-------------

G2 = tf(K, [tau2 1], 'InputDelay', theta2);


%---------------simulacion de la respjuesta del sistema------------------

y2 = lsim(G2, u, t);
plot(t, y2, 'c', 'LineWidth', 1.5);





%---------------Metodo analitico-----------------------


%encontrar tiempos para el 63.2% y 28.4%


deltay1 = y_base * 0.632; %el 0.6332 de el valor al 100%
deltay2 = y_base * 0.284; %el 0.284 de el valor al 100%


y_63 = y(1) + deltay1;
y_28 = y(1) + deltay2;


% Paso 2: Encontrar tiempos para el 63.2% y el 28.4%
t_63 = find(y >= y_63, 1, 'first');  % Encuentra el primer índice donde y >= 63.2%
t_28 = find(y >= y_28, 1, 'first');  % Encuentra el primer índice donde y >= 28.4%


% Convertir índices a tiempo real
t_63 = t(t_63);
t_28 = t(t_28);



% Paso 3: Resolver para tau y theta
tau3 = (t_63 - t_28) * (3/2);
theta3 = t_63 - tau3;

fprintf("METODO ANAL ITICO");
theta3
tau3 
% Paso 4: Definir la función de transferencia FOTD
G3 = tf(K, [tau3 1], 'InputDelay', theta3);


% Paso 5: Calcular la respuesta del sistema usando lsim
y_M = lsim(G3, u, t);

plot(t, y_M, 'm', 'LineWidth', 1.5);



%----------------configuracion de las graficas -------------
xlabel('Tiempo (s)');
ylabel('Amplitud - Respuesta del sistema y(t)');
title('Señal de Excitación y Respuesta del Sistema');
legend('Excitación u(t)', 'Respuesta y(t)', 'Linea 100%','Linea base', 'Recta tangente', 'Nichols' , 'Miller','Analitico');


