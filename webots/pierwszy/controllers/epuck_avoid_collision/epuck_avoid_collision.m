% MATLAB controller for Webots
% File:          epuck_avoid_collision.m
% Date:
% Description:
% Author:
% Modifications:

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
%desktop;
%keyboard;

TIME_STEP = 64;

% get and enable devices, e.g.:
ps = [];
ps_names = [ "ps0", "ps1", "ps2", "ps3", "ps4", "ps5", "ps6", "ps7" ];

for i = 1:8
  ps(i) = wb_robot_get_device(convertStringsToChars(ps_names(i)));
  wb_distance_sensor_enable(ps(i), TIME_STEP);
end

left_motor = wb_robot_get_device('left wheel motor');
right_motor = wb_robot_get_device('right wheel motor');
wb_motor_set_position(left_motor, inf);
wb_motor_set_position(right_motor, inf);
wb_motor_set_velocity(left_motor, 0.0);
wb_motor_set_velocity(right_motor, 0.0);
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);
%  motor = wb_robot_get_device('motor');

% main loop:
% perform simulation steps of TIME_STEP milliseconds
% and leave the loop when Webots signals the termination
%
while wb_robot_step(TIME_STEP) ~= -1

  % read the sensors, e.g.:
  %  rgb = wb_camera_get_image(camera);
  ps_values = [];
  for i = 1:8
   ps_values(i) = wb_distance_sensor_get_value(ps(i));
  end

  right_obstacle = ps_values(1) > 80.0 | ps_values(2) > 80.0 | ps_values(3) > 80.0;
  left_obstacle = ps_values(6) > 80.0 | ps_values(7) > 80.0 | ps_values(8) > 80.0;
  MAX_SPEED = 6.28;
...
% initialize motor speeds at 50% of MAX_SPEED.
left_speed  = 0.5 * MAX_SPEED;
right_speed = 0.5 * MAX_SPEED;
% modify speeds according to obstacles
if left_obstacle
  % turn right
  left_speed  = 0.5 * MAX_SPEED;
  right_speed = -0.5 * MAX_SPEED;
elseif right_obstacle
  % turn left
  left_speed  = -0.5 * MAX_SPEED;
  right_speed = 0.5 * MAX_SPEED;
end
% write actuators inputs
wb_motor_set_velocity(left_motor, left_speed);
wb_motor_set_velocity(right_motor, right_speed);
  % Process here sensor data, images, etc.

  % send actuator commands, e.g.:
  %  wb_motor_set_postion(motor, 10.0);

  % if your code plots some graphics, it needs to flushed like this:
  drawnow;

end

% cleanup code goes here: write data to files, etc.
