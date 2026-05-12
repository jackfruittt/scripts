#!/bin/bash

ros2 launch ur_robot_driver ur_control.launch.py ur_type:=ur3e robot_ip:=192.168.0.194 use_fake_hardware:=true launch_rviz:=true
