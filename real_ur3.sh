#!/bin/bash


ros2 launch ur_robot_driver ur_control.launch.py ur_type:=ur3e robot_ip:=192.168.0.194 launch_rviz:=true
#ros2 launch ur_moveit_config ur_moveit.launch.py ur_type:=ur3e robot_ip:=192.168.0.194 launch_rviz:=true
