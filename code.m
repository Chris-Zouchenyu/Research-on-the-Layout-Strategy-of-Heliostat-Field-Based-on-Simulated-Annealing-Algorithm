%% 导入数据，作分布图
options = detectImportOptions('附件.xlsx');
options.VariableNamingRule = 'preserve';
data = readtable('附件.xlsx', options);
x = data.("x坐标 (m)");
y = data.("y坐标 (m)");
z = 4;
% 创建散点图
scatter(x, y, 10, "blue", 'filled');
hold on;
title('定日镜场');
xlabel('X 轴');
ylabel('Y 轴');
% 手动添加坐标原点的红色三角形 
plot(0, 0, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'red');


%%计算太阳相关参数
%太阳赤纬角
data1 = readtable('日期D.xlsx');
D = data1.D;
% 计算 sin(𝛿)
delta = sin(2*pi*D./365) * sin(2*pi/360*23.45);
cos_delta = sqrt(1 - delta.^2);
%太阳高度角三角函数
sin_delta =data1.sin;
cos_phi =data1.cos;
cos_omega = cos(39.4/180*pi);
sin_omega =  sin(39.4/180*pi);
sin_alpha_s = cos_phi * cos(0*pi) * cos_omega + sin_delta * sin_omega;
cos_alpha_s = sqrt(1 - sin_alpha_s.^2);
%太阳方位角三角函数
cos_gamma_s = (delta - sin_alpha_s * sin_omega) ./ (cos_alpha_s * cos_omega);


%%
%求角度
%太阳高度角
data2 = readtable("工作簿2.xlsx");
angle = asin(table2array(data2));
angle_degrees = rad2deg(angle);
disp('反正弦值（弧度）：');
disp(angle);
disp('反正弦值（度数）：');
disp(angle_degrees);
%太阳方位角
data2 = readtable("方位角度数.xlsx");
angle = acos(table2array(data2));
angle_degrees = rad2deg(angle);
disp('反余弦值（弧度）：');
disp(angle);
disp('反余弦值（度数）：');
disp(angle_degrees);


%%
%大气透射率
% 导入数据
options1 = detectImportOptions('附件.xlsx');
options1.VariableNamingRule = 'preserve';
data1 = readtable('附件.xlsx', options1);
h=80;%吸收塔中心高度

results = [];
for j = 1:size(data1, 1)
    % 获取每一行的 x、y、 z 值
    x = data1.("x坐标 (m)")(j);  
    y = data1.("y坐标 (m)")(j);  
    z = data1.("z坐标 (m)")(j);  
    
    % 计算 dHR
    dHR = sqrt(x^2 + y^2 + (h-z)^2);
    
    % 计算 𝜂at 的值
    eta_at = 0.99321 - 0.0001176 * dHR + 1.97e-8 * dHR^2;
    

    results = [results; eta_at];
end

disp('每一行的结果：');
disp(results);


%%
%太阳光锥临界
angle_in_mrad = 4.65e-3;  % 将4.65 mrad转换为弧度
h=250;
% 计算正切值
tan_value = tan(angle_in_mrad);
d =h*tan_value;


%%
%投影长度
% 导入数据
options1 = detectImportOptions('附件.xlsx');
options1.VariableNamingRule = 'preserve';
data1 = readtable('附件.xlsx', options1);

results = [];
for j = 1:size(data1, 1)
    
    x = data1.("x坐标 (m)")(j); 
    y = data1.("y坐标 (m)")(j);  
    z = 4;
     % 计算 dHR
    dHR = sqrt(x^2 + y^2 + 76^2);
      angle_in_mrad = 4.65e-3;  % 将4.65 mrad转换为弧度
h=dHR;
% 计算正切值
tan_value = tan(angle_in_mrad);
d =h*tan_value;
    s = (d-1)./(d+7);
    results = [results; s];
end

disp('每一行的结果：');
disp(results);


%%
%蒙特卡洛法计算阴影效率
% 从两个Excel文件中读取顶点坐标
data1 = readtable('全部投影顶点坐标.xlsx');
data2 = readtable('重叠区域顶点坐标.xlsx');
x1 = data1.x;
y1 = data1.y;
x2 = data2.x;
y2 = data2.y;
polygons1 = {[x1, y1]};
polygons2 = {[x2, y2]};
p = 10000;
n = 0;
m = 0;
hold on;
for k = 1:p
    xP = rand * 2; % 随机生成点的x坐标
    yP = rand * 2; % 随机生成点的y坐标
    isInsideAnyPolygon1 = false;
    isInsideAnyPolygon2 = false;
% 遍历每个多边形并检测点P是否在内部
    for i = 1:size(polygons1, 2)
        x3 = polygons1{1, i};
        y3 = polygons1{2, i};
        isInside1 = inpolygon(xP, yP, x3, y3);

        if isInside1
            isInsideAnyPolygon1 = true;
            break;
        end
    end
   for i = 1:size(polygons2, 2)
        x4 = polygons2{1, i};
        y4 = polygons2{2, i};
        isInside2 = inpolygon(xP, yP, x4, y4);

        if isInside2
            isInsideAnyPolygon2 = true;
            break;
        end
    end
  if isInsideAnyPolygon1 && isInsideAnyPolygon2
        n = n + 1;
    end
  if isInsideAnyPolygon1
        m = m + 1;
    end
end
axis equal; 
P = n / m;
disp(['落在两个多边形内部的点的比例：', num2str(P)]);


%%
%模拟退火法计算最大平均余弦效率
%通过随机产生坐标计算约束条件下的最大值
r = 8; %正方形边长
% 设置坐标点的数量（这里是总点数的一半，因为会生成对称的点）
half_num_points = 700;  % 假设总点数是1400，即需要生成700对对称点

% 设置坐标值的范围
min_value = -350;   % 坐标值的最小范围
max_value = 350;    % 坐标值的最大范围
fixed_z = 5;        % 固定的 z 坐标

% 初始化坐标和温度数组
coordinates = zeros(2 * half_num_points, 4);

% 模拟退火参数
initial_temperature = 1.0; % 初始温度
final_temperature = 0.01;  % 最终温度
cooling_factor = 0.9;     % 冷却因子

% 生成随机初始坐标
for i = 1:half_num_points
    while true
        x = (max_value - min_value) * rand + min_value;
        
        % 使用概率来生成 y，更有可能生成在正数范围内,即北边
        if rand < 0.9
            y = rand * max_value;  
        else
            y = (rand - 1) * max_value;  
        end
        % 检查是否满足约束条件
        distance = sqrt(x^2 + y^2);
        
        if  distance > 100 && distance < 350 && all(pdist2([x, y], coordinates(:, 1:2)) > (5+r))
            
            symmetric_point_index = 2 * half_num_points - i + 1;
            symmetric_x = -x;
            symmetric_y = y;
            symmetric_distance = sqrt((x - symmetric_x)^2 + (y - symmetric_y)^2);
            if symmetric_distance > (5+r)
                temperature = funs(x, y, fixed_z);
                
                if temperature >= 0.56
                    
                    coordinates(i, :) = [x, y, fixed_z, temperature];
                    coordinates(symmetric_point_index, :) = [symmetric_x, symmetric_y, fixed_z, temperature];
                    break;
                end
            end
        end
    end
end

% 初始最优解
best_coordinates = coordinates;
best_temperature_sum = sum(coordinates(:, 4));
best_average_temperature = best_temperature_sum / (2 * half_num_points);

while initial_temperature > final_temperature
    for i = 1:2 * half_num_points
        % 随机选择一个坐标点
        idx = randi(2 * half_num_points);
        x = coordinates(idx, 1);
        y = coordinates(idx, 2);

        % 生成随机扰动
        dx = (2 * rand - 1) * 10; % 在[-10, 10]范围内生成随机扰动
        dy = (2 * rand - 1) * 10;
        u = x + dx;
        v = y + dy;
        
        new_distance = sqrt(u^2 + v^2);
        
        % 检查新坐标是否满足约束条件
        if new_distance <= 100 || new_distance >= 350 || any(pdist2([u, v], coordinates(:, 1:2)) <= 5+r)
            
            continue;
        end
        
        % 计算扰动后的温度
        new_temperature = funs(u, v, fixed_z);

        % 计算温度变化
        delta_temperature = new_temperature - coordinates(idx, 4);

        % 如果温度变化为正，或者按概率接受负变化
        if delta_temperature >= 0 || rand() < exp(delta_temperature / initial_temperature)
            coordinates(idx, 1) = u;
            coordinates(idx, 2) = v;
            coordinates(idx, 4) = new_temperature;
        end
    end

    % 更新最优解
    current_temperature_sum = sum(coordinates(:, 4));
    current_average_temperature = current_temperature_sum / (2 * half_num_points);
    if current_average_temperature > best_average_temperature
        best_coordinates = coordinates;
        best_temperature_sum = current_temperature_sum;
        best_average_temperature = current_average_temperature;
    end

    % 冷却温度
    initial_temperature = initial_temperature * cooling_factor;
end

% 最终的坐标和温度
x_coords = best_coordinates(:, 1);
y_coords = best_coordinates(:, 2);
z_coords = best_coordinates(:, 3);
temperatures = best_coordinates(:, 4);

% 绘制热图
figure;
scatter(x_coords, y_coords, 10, temperatures, 'filled');
xlabel('X 轴');
ylabel('Y 轴');
title('最优的热图');
colorbar;
colormap(jet);
axis equal;
grid on;

% 输出最大平均温度和最优坐标数组
fprintf('最大平均温度：%f\n', best_average_temperature);
fprintf('最优坐标数组：\n');
disp(best_coordinates);

% % % 继续优化最大平均温度坐标集合
additional_iterations = 10000;  % 设定微调迭代次数

for iter = 1:additional_iterations
    % 随机选择一个坐标点进行微调
    idx = randi(2 * half_num_points);
    x = best_coordinates(idx, 1);
    y = best_coordinates(idx, 2);

    % 生成随机扰动
    dx = (2 * rand - 1) * 10; % 在[-10, 10]范围内生成随机扰动
    dy = (2 * rand - 1) * 10;
    u = x + dx;
    v = y + dy;

    new_distance = sqrt(u^2 + v^2);

    % 检查新坐标是否满足约束条件
    if new_distance <= 100 || new_distance >= 350 || any(pdist2([u, v], best_coordinates(:, 1:2)) <= 2*r)
        
        continue;
    end

    % 计算扰动后的温度
    new_temperature = funs(u, v, fixed_z);

    % 计算温度变化
    delta_temperature = new_temperature - best_coordinates(idx, 4);

    % 如果温度变化为正，或者按概率接受负变化
    if delta_temperature >= 0 || rand() < exp(delta_temperature / initial_temperature)
        best_coordinates(idx, 1) = u;
        best_coordinates(idx, 2) = v;
        best_coordinates(idx, 4) = new_temperature;

        % 更新最优解的平均温度
        best_temperature_sum = sum(best_coordinates(:, 4));
        best_average_temperature = best_temperature_sum / (2 * half_num_points);
    end
end

% 输出微调后的最大平均温度和坐标数组
fprintf('微调后的最大平均温度：%f\n', best_average_temperature);
fprintf('微调后的坐标数组：\n');
disp(best_coordinates);

% 最终的坐标和温度
x_coords_final = best_coordinates(:, 1);
y_coords_final = best_coordinates(:, 2);
z_coords_final = best_coordinates(:, 3);
temperatures_final = best_coordinates(:, 4);

% 绘制微调后的热图
figure;
scatter(x_coords_final, y_coords_final, 10, temperatures_final, 'filled');
xlabel('X 轴');
ylabel('Y 轴');
title('微调后的热图');
colorbar;
colormap(jet);
axis equal;
grid on;

scatter(x_coords_final, y_coords_final, 10, 'filled');
hold on;

title('定日镜场');
xlabel('X 轴');
ylabel('Y 轴');

% 手动添加坐标原点的红色三角形
plot(0, 0, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'red');

%%函数temperapute计算余弦效率
function  temperapute = funs(x, y, z)
    % 输入反射终点的坐标
    x1 = x;        % X坐标
    y1 = y;        % Y坐标
    z1 = z;        % Z坐标

    x2 = 0;        % 反射终点的X坐标
    y2 = 0;        % 反射终点的Y坐标
    z2 = 80;       % 反射终点的Z坐标

    % 输入入射光线向量
    Vi = [0, -0.634730513, 0.772733573];

    % 计算反射光线的单位向量
    Vr1 = [x2 - x1, y2 - y1, z2 - z1];
    Vr = Vr1 / norm(Vr1);

    % 计算点积
    cosine_theta = dot(Vi, Vr);

    % 计算余弦效率
    temperapute = sqrt(0.5 * (1 + cosine_theta));
end




%%
%将xy坐标转换成极坐标
% 导入数据
options = detectImportOptions('问题二坐标.xlsx');
options.VariableNamingRule = 'preserve';
data = readtable('问题二坐标.xlsx', options);
x = data.x;
y = data.y;

r = zeros(size(x));
theta = zeros(size(x));
% 计算每个数据点的极坐标 (r, θ) 使用y轴作为极轴，逆时针方向
for i = 1:length(x)
    r(i) = sqrt(x(i)^2 + y(i)^2);
    theta(i) = mod(2*pi - atan2(x(i), y(i)), 2*pi);  
end
% 将角度转换为以π为单位
theta_pi = theta / pi;

for i = 1:length(x)
    fprintf('数据点 %d - 直角坐标 (x, y) = (%.2f, %.2f)\n', i, x(i), y(i));
    fprintf('数据点 %d - 极坐标 (r, θ) = (%.2f, %.2fπ)\n', i, r(i), theta_pi(i));
end



%求每个定日镜的高度h
% 导入数据
options = detectImportOptions('问题二坐标.xlsx');
options.VariableNamingRule = 'preserve';
data = readtable('问题二坐标.xlsx', options);
r = data.r;
a = data.pi;

h = zeros(size(r));
% 计算每个数据点的 h 值
for i = 1:size(r)
    h(i) = 4 + (r(i) - 100) / 250 + abs(1 - a(i));
end

for i = 1:size(r)
    fprintf('数据点 %d - h = %.2f\n', i, h(i));
end


%作效果图
% 导入数据
options = detectImportOptions('问题二坐标.xlsx');
options.VariableNamingRule = 'preserve';
data = readtable('问题二坐标.xlsx', options);
x = data.x;
y = data.y;
z = data.h;
% 根据 h 的不同值设置颜色
colors = z;  % 使用 h 的值作为颜色
colormap jet;  % 选择颜色映射
caxis([min(colors), max(colors)]);  
% 创建一个立体图
figure;
scatter3(x, y, z, 10, colors, 'filled'); 
xlabel('X轴');
ylabel('Y轴');
zlabel('高度');
title('定日镜场的立体图');
% 添加颜色条
cbar = colorbar;  % 获取颜色条的句柄
% 设置颜色条的标题
cbar.Label.String = '高度';  % 设置颜色条的注释为"高度"
% 手动设置 z 轴的上下限
zUpperLimit = max(z) + 4;  % 调整上限
zLowerLimit = 0;  % 调整下限
zlim([zLowerLimit, zUpperLimit]);
% 添加平行 z 轴的细线，作为吸收塔
hold on;  % 保持图形处于活动状态
line([0, 0], [0, 0], [zLowerLimit, zUpperLimit], 'Color', 'r', 'LineWidth', 0.5);  % 添加细线
hold off;  % 结束图形的活动状态
