2.%% 导入数据，作分布图
3.options = detectImportOptions('附件.xlsx');
4.options.VariableNamingRule = 'preserve';
5.data = readtable('附件.xlsx', options);
6.x = data.("x坐标 (m)");
7.y = data.("y坐标 (m)");
8.z = 4;
9.% 创建散点图
10.scatter(x, y, 10, "blue", 'filled');
11.hold on;
12.title('定日镜场');
13.xlabel('X 轴');
14.ylabel('Y 轴');
15.% 手动添加坐标原点的红色三角形 
16.plot(0, 0, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'red');
17.
18.
19.%%计算太阳相关参数
20.%太阳赤纬角
21.data1 = readtable('日期D.xlsx');
22.D = data1.D;
23.% 计算 sin(𝛿)
24.delta = sin(2*pi*D./365) * sin(2*pi/360*23.45);
25.cos_delta = sqrt(1 - delta.^2);
26.%太阳高度角三角函数
27.sin_delta =data1.sin;
28.cos_phi =data1.cos;
29.cos_omega = cos(39.4/180*pi);
30.sin_omega =  sin(39.4/180*pi);
31.sin_alpha_s = cos_phi * cos(0*pi) * cos_omega + sin_delta * sin_omega;
32.cos_alpha_s = sqrt(1 - sin_alpha_s.^2);
33.%太阳方位角三角函数
34.cos_gamma_s = (delta - sin_alpha_s * sin_omega) ./ (cos_alpha_s * cos_omega);
35.
36.
37.%%
38.%求角度
39.%太阳高度角
40.data2 = readtable("工作簿2.xlsx");
41.angle = asin(table2array(data2));
42.angle_degrees = rad2deg(angle);
43.disp('反正弦值（弧度）：');
44.disp(angle);
45.disp('反正弦值（度数）：');
46.disp(angle_degrees);
47.%太阳方位角
48.data2 = readtable("方位角度数.xlsx");
49.angle = acos(table2array(data2));
50.angle_degrees = rad2deg(angle);
51.disp('反余弦值（弧度）：');
52.disp(angle);
53.disp('反余弦值（度数）：');
54.disp(angle_degrees);
55.
56.
57.%%
58.%大气透射率
59.% 导入数据
60.options1 = detectImportOptions('附件.xlsx');
61.options1.VariableNamingRule = 'preserve';
62.data1 = readtable('附件.xlsx', options1);
63.h=80;%吸收塔中心高度
64.
65.results = [];
66.for j = 1:size(data1, 1)
67.    % 获取每一行的 x、y、 z 值
68.    x = data1.("x坐标 (m)")(j);  
69.    y = data1.("y坐标 (m)")(j);  
70.    z = data1.("z坐标 (m)")(j);  
71.    
72.    % 计算 dHR
73.    dHR = sqrt(x^2 + y^2 + (h-z)^2);
74.    
75.    % 计算 𝜂at 的值
76.    eta_at = 0.99321 - 0.0001176 * dHR + 1.97e-8 * dHR^2;
77.    
78.
79.    results = [results; eta_at];
80.end
81.
82.disp('每一行的结果：');
83.disp(results);
84.
85.
86.%%
87.%太阳光锥临界
88.angle_in_mrad = 4.65e-3;  % 将4.65 mrad转换为弧度
89.h=250;
90.% 计算正切值
91.tan_value = tan(angle_in_mrad);
92.d =h*tan_value;
93.
94.
95.%%
96.%投影长度
97.% 导入数据
98.options1 = detectImportOptions('附件.xlsx');
99.options1.VariableNamingRule = 'preserve';
100.data1 = readtable('附件.xlsx', options1);
101.
102.results = [];
103.for j = 1:size(data1, 1)
104.    
105.    x = data1.("x坐标 (m)")(j); 
106.    y = data1.("y坐标 (m)")(j);  
107.    z = 4;
108.     % 计算 dHR
109.    dHR = sqrt(x^2 + y^2 + 76^2);
110.      angle_in_mrad = 4.65e-3;  % 将4.65 mrad转换为弧度
111.h=dHR;
112.% 计算正切值
113.tan_value = tan(angle_in_mrad);
114.d =h*tan_value;
115.    s = (d-1)./(d+7);
116.    results = [results; s];
117.end
118.
119.disp('每一行的结果：');
120.disp(results);
121.
122.
123.%%
124.%蒙特卡洛法计算阴影效率
125.% 从两个Excel文件中读取顶点坐标
126.data1 = readtable('全部投影顶点坐标.xlsx');
127.data2 = readtable('重叠区域顶点坐标.xlsx');
128.x1 = data1.x;
129.y1 = data1.y;
130.x2 = data2.x;
131.y2 = data2.y;
132.polygons1 = {[x1, y1]};
133.polygons2 = {[x2, y2]};
134.p = 10000;
135.n = 0;
136.m = 0;
137.hold on;
138.for k = 1:p
139.    xP = rand * 2; % 随机生成点的x坐标
140.    yP = rand * 2; % 随机生成点的y坐标
141.    isInsideAnyPolygon1 = false;
142.    isInsideAnyPolygon2 = false;
143.% 遍历每个多边形并检测点P是否在内部
144.    for i = 1:size(polygons1, 2)
145.        x3 = polygons1{1, i};
146.        y3 = polygons1{2, i};
147.        isInside1 = inpolygon(xP, yP, x3, y3);
148.
149.        if isInside1
150.            isInsideAnyPolygon1 = true;
151.            break;
152.        end
153.    end
154.   for i = 1:size(polygons2, 2)
155.        x4 = polygons2{1, i};
156.        y4 = polygons2{2, i};
157.        isInside2 = inpolygon(xP, yP, x4, y4);
158.
159.        if isInside2
160.            isInsideAnyPolygon2 = true;
161.            break;
162.        end
163.    end
164.  if isInsideAnyPolygon1 && isInsideAnyPolygon2
165.        n = n + 1;
166.    end
167.  if isInsideAnyPolygon1
168.        m = m + 1;
169.    end
170.end
171.axis equal; 
172.P = n / m;
173.disp(['落在两个多边形内部的点的比例：', num2str(P)]);
174.
175.
176.%%
177.%模拟退火法计算最大平均余弦效率
178.%通过随机产生坐标计算约束条件下的最大值
179.r = 8; %正方形边长
180.% 设置坐标点的数量（这里是总点数的一半，因为会生成对称的点）
181.half_num_points = 700;  % 假设总点数是1400，即需要生成700对对称点
182.
183.% 设置坐标值的范围
184.min_value = -350;   % 坐标值的最小范围
185.max_value = 350;    % 坐标值的最大范围
186.fixed_z = 5;        % 固定的 z 坐标
187.
188.% 初始化坐标和温度数组
189.coordinates = zeros(2 * half_num_points, 4);
190.
191.% 模拟退火参数
192.initial_temperature = 1.0; % 初始温度
193.final_temperature = 0.01;  % 最终温度
194.cooling_factor = 0.9;     % 冷却因子
195.
196.% 生成随机初始坐标
197.for i = 1:half_num_points
198.    while true
199.        x = (max_value - min_value) * rand + min_value;
200.        
201.        % 使用概率来生成 y，更有可能生成在正数范围内,即北边
202.        if rand < 0.9
203.            y = rand * max_value;  
204.        else
205.            y = (rand - 1) * max_value;  
206.        end
207.        % 检查是否满足约束条件
208.        distance = sqrt(x^2 + y^2);
209.        
210.        if  distance > 100 && distance < 350 && all(pdist2([x, y], coordinates(:, 1:2)) > (5+r))
211.            
212.            symmetric_point_index = 2 * half_num_points - i + 1;
213.            symmetric_x = -x;
214.            symmetric_y = y;
215.            symmetric_distance = sqrt((x - symmetric_x)^2 + (y - symmetric_y)^2);
216.            if symmetric_distance > (5+r)
217.                temperature = funs(x, y, fixed_z);
218.                
219.                if temperature >= 0.56
220.                    
221.                    coordinates(i, :) = [x, y, fixed_z, temperature];
222.                    coordinates(symmetric_point_index, :) = [symmetric_x, symmetric_y, fixed_z, temperature];
223.                    break;
224.                end
225.            end
226.        end
227.    end
228.end
229.
230.% 初始最优解
231.best_coordinates = coordinates;
232.best_temperature_sum = sum(coordinates(:, 4));
233.best_average_temperature = best_temperature_sum / (2 * half_num_points);
234.
235.while initial_temperature > final_temperature
236.    for i = 1:2 * half_num_points
237.        % 随机选择一个坐标点
238.        idx = randi(2 * half_num_points);
239.        x = coordinates(idx, 1);
240.        y = coordinates(idx, 2);
241.
242.        % 生成随机扰动
243.        dx = (2 * rand - 1) * 10; % 在[-10, 10]范围内生成随机扰动
244.        dy = (2 * rand - 1) * 10;
245.        u = x + dx;
246.        v = y + dy;
247.        
248.        new_distance = sqrt(u^2 + v^2);
249.        
250.        % 检查新坐标是否满足约束条件
251.        if new_distance <= 100 || new_distance >= 350 || any(pdist2([u, v], coordinates(:, 1:2)) <= 5+r)
252.            
253.            continue;
254.        end
255.        
256.        % 计算扰动后的温度
257.        new_temperature = funs(u, v, fixed_z);
258.
259.        % 计算温度变化
260.        delta_temperature = new_temperature - coordinates(idx, 4);
261.
262.        % 如果温度变化为正，或者按概率接受负变化
263.        if delta_temperature >= 0 || rand() < exp(delta_temperature / initial_temperature)
264.            coordinates(idx, 1) = u;
265.            coordinates(idx, 2) = v;
266.            coordinates(idx, 4) = new_temperature;
267.        end
268.    end
269.
270.    % 更新最优解
271.    current_temperature_sum = sum(coordinates(:, 4));
272.    current_average_temperature = current_temperature_sum / (2 * half_num_points);
273.    if current_average_temperature > best_average_temperature
274.        best_coordinates = coordinates;
275.        best_temperature_sum = current_temperature_sum;
276.        best_average_temperature = current_average_temperature;
277.    end
278.
279.    % 冷却温度
280.    initial_temperature = initial_temperature * cooling_factor;
281.end
282.
283.% 最终的坐标和温度
284.x_coords = best_coordinates(:, 1);
285.y_coords = best_coordinates(:, 2);
286.z_coords = best_coordinates(:, 3);
287.temperatures = best_coordinates(:, 4);
288.
289.% 绘制热图
290.figure;
291.scatter(x_coords, y_coords, 10, temperatures, 'filled');
292.xlabel('X 轴');
293.ylabel('Y 轴');
294.title('最优的热图');
295.colorbar;
296.colormap(jet);
297.axis equal;
298.grid on;
299.
300.% 输出最大平均温度和最优坐标数组
301.fprintf('最大平均温度：%f\n', best_average_temperature);
302.fprintf('最优坐标数组：\n');
303.disp(best_coordinates);
304.
305.% % % 继续优化最大平均温度坐标集合
306.additional_iterations = 10000;  % 设定微调迭代次数
307.
308.for iter = 1:additional_iterations
309.    % 随机选择一个坐标点进行微调
310.    idx = randi(2 * half_num_points);
311.    x = best_coordinates(idx, 1);
312.    y = best_coordinates(idx, 2);
313.
314.    % 生成随机扰动
315.    dx = (2 * rand - 1) * 10; % 在[-10, 10]范围内生成随机扰动
316.    dy = (2 * rand - 1) * 10;
317.    u = x + dx;
318.    v = y + dy;
319.
320.    new_distance = sqrt(u^2 + v^2);
321.
322.    % 检查新坐标是否满足约束条件
323.    if new_distance <= 100 || new_distance >= 350 || any(pdist2([u, v], best_coordinates(:, 1:2)) <= 2*r)
324.        
325.        continue;
326.    end
327.
328.    % 计算扰动后的温度
329.    new_temperature = funs(u, v, fixed_z);
330.
331.    % 计算温度变化
332.    delta_temperature = new_temperature - best_coordinates(idx, 4);
333.
334.    % 如果温度变化为正，或者按概率接受负变化
335.    if delta_temperature >= 0 || rand() < exp(delta_temperature / initial_temperature)
336.        best_coordinates(idx, 1) = u;
337.        best_coordinates(idx, 2) = v;
338.        best_coordinates(idx, 4) = new_temperature;
339.
340.        % 更新最优解的平均温度
341.        best_temperature_sum = sum(best_coordinates(:, 4));
342.        best_average_temperature = best_temperature_sum / (2 * half_num_points);
343.    end
344.end
345.
346.% 输出微调后的最大平均温度和坐标数组
347.fprintf('微调后的最大平均温度：%f\n', best_average_temperature);
348.fprintf('微调后的坐标数组：\n');
349.disp(best_coordinates);
350.
351.% 最终的坐标和温度
352.x_coords_final = best_coordinates(:, 1);
353.y_coords_final = best_coordinates(:, 2);
354.z_coords_final = best_coordinates(:, 3);
355.temperatures_final = best_coordinates(:, 4);
356.
357.% 绘制微调后的热图
358.figure;
359.scatter(x_coords_final, y_coords_final, 10, temperatures_final, 'filled');
360.xlabel('X 轴');
361.ylabel('Y 轴');
362.title('微调后的热图');
363.colorbar;
364.colormap(jet);
365.axis equal;
366.grid on;
367.
368.scatter(x_coords_final, y_coords_final, 10, 'filled');
369.hold on;
370.
371.title('定日镜场');
372.xlabel('X 轴');
373.ylabel('Y 轴');
374.
375.% 手动添加坐标原点的红色三角形
376.plot(0, 0, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'red');
377.
378.%%函数temperapute计算余弦效率
379.function  temperapute = funs(x, y, z)
380.    % 输入反射终点的坐标
381.    x1 = x;        % X坐标
382.    y1 = y;        % Y坐标
383.    z1 = z;        % Z坐标
384.
385.    x2 = 0;        % 反射终点的X坐标
386.    y2 = 0;        % 反射终点的Y坐标
387.    z2 = 80;       % 反射终点的Z坐标
388.
389.    % 输入入射光线向量
390.    Vi = [0, -0.634730513, 0.772733573];
391.
392.    % 计算反射光线的单位向量
393.    Vr1 = [x2 - x1, y2 - y1, z2 - z1];
394.    Vr = Vr1 / norm(Vr1);
395.
396.    % 计算点积
397.    cosine_theta = dot(Vi, Vr);
398.
399.    % 计算余弦效率
400.    temperapute = sqrt(0.5 * (1 + cosine_theta));
401.end
402.
403.
404.
405.
406.%%
407.%将xy坐标转换成极坐标
408.% 导入数据
409.options = detectImportOptions('问题二坐标.xlsx');
410.options.VariableNamingRule = 'preserve';
411.data = readtable('问题二坐标.xlsx', options);
412.x = data.x;
413.y = data.y;
414.
415.r = zeros(size(x));
416.theta = zeros(size(x));
417.% 计算每个数据点的极坐标 (r, θ) 使用y轴作为极轴，逆时针方向
418.for i = 1:length(x)
419.    r(i) = sqrt(x(i)^2 + y(i)^2);
420.    theta(i) = mod(2*pi - atan2(x(i), y(i)), 2*pi);  
421.end
422.% 将角度转换为以π为单位
423.theta_pi = theta / pi;
424.
425.for i = 1:length(x)
426.    fprintf('数据点 %d - 直角坐标 (x, y) = (%.2f, %.2f)\n', i, x(i), y(i));
427.    fprintf('数据点 %d - 极坐标 (r, θ) = (%.2f, %.2fπ)\n', i, r(i), theta_pi(i));
428.end
429.
430.
431.
432.%求每个定日镜的高度h
433.% 导入数据
434.options = detectImportOptions('问题二坐标.xlsx');
435.options.VariableNamingRule = 'preserve';
436.data = readtable('问题二坐标.xlsx', options);
437.r = data.r;
438.a = data.pi;
439.
440.h = zeros(size(r));
441.% 计算每个数据点的 h 值
442.for i = 1:size(r)
443.    h(i) = 4 + (r(i) - 100) / 250 + abs(1 - a(i));
444.end
445.
446.for i = 1:size(r)
447.    fprintf('数据点 %d - h = %.2f\n', i, h(i));
448.end
449.
450.
451.%作效果图
452.% 导入数据
453.options = detectImportOptions('问题二坐标.xlsx');
454.options.VariableNamingRule = 'preserve';
455.data = readtable('问题二坐标.xlsx', options);
456.x = data.x;
457.y = data.y;
458.z = data.h;
459.% 根据 h 的不同值设置颜色
460.colors = z;  % 使用 h 的值作为颜色
461.colormap jet;  % 选择颜色映射
462.caxis([min(colors), max(colors)]);  
463.% 创建一个立体图
464.figure;
465.scatter3(x, y, z, 10, colors, 'filled'); 
466.xlabel('X轴');
467.ylabel('Y轴');
468.zlabel('高度');
469.title('定日镜场的立体图');
470.% 添加颜色条
471.cbar = colorbar;  % 获取颜色条的句柄
472.% 设置颜色条的标题
473.cbar.Label.String = '高度';  % 设置颜色条的注释为"高度"
474.% 手动设置 z 轴的上下限
475.zUpperLimit = max(z) + 4;  % 调整上限
476.zLowerLimit = 0;  % 调整下限
477.zlim([zLowerLimit, zUpperLimit]);
478.% 添加平行 z 轴的细线，作为吸收塔
479.hold on;  % 保持图形处于活动状态
480.line([0, 0], [0, 0], [zLowerLimit, zUpperLimit], 'Color', 'r', 'LineWidth', 0.5);  % 添加细线
481.hold off;  % 结束图形的活动状态